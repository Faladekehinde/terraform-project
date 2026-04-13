# -------------------------------
# DATA SOURCES
# -------------------------------

data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

data "aws_secretsmanager_secret" "db_credentials" {
  name = "${var.environment}/db/credentials"
}
data "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = data.aws_secretsmanager_secret.db_credentials.id
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

data "aws_vpc" "existing" {
  count = var.use_existing_vpc ? 1 : 0

  default = true
}


# -------------------------------
# NETWORKING
# -------------------------------

resource "aws_vpc" "lab" {
  count      = var.use_existing_vpc ? 0 : 1
  cidr_block = var.vpc_cidr

  tags = {
    Name        = "${local.name_prefix}-vpc"
    Environment = var.environment
  }
}

resource "aws_subnet" "subnets" {
  for_each = var.subnets

  vpc_id                  = local.vpc_id
  cidr_block              = each.value.cidr_block
  availability_zone       = data.aws_availability_zones.available.names[each.value.az_index]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${local.name_prefix}-${each.key}"
    Environment = var.environment
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id =  local.vpc_id

  tags = {
    Name = "${local.name_prefix}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id =  local.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "subnets" {
  for_each      = aws_subnet.subnets
  
  subnet_id     = each.value.id
  route_table_id = aws_route_table.public.id
}
  

# -------------------------------
# SECURITY GROUPS
# -------------------------------

resource "aws_security_group" "sg" {
  name   = "${local.name_prefix}-sg"
  vpc_id =  local.vpc_id

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# -------------------------------
# LAUNCH TEMPLATE
# -------------------------------

resource "aws_launch_template" "lt" {
  name_prefix   = "${var.cluster_name}-lt-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = local.instance_type

  vpc_security_group_ids = [aws_security_group.sg.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    apt update -y
    apt install -y apache2 git
    systemctl start apache2
    systemctl enable apache2
    rm -rf /var/www/html/*
    cat > /var/www/html/index.html <<EOT
    <h1>${var.server_text}</h1>
    <p>Environment: ${var.environment}</p>
    EOT
    
  EOF
  )

    lifecycle {
    create_before_destroy = true
  }

  tags = {
      version = var.server_text
    }

}

# -------------------------------
# LOAD BALANCER
# -------------------------------

resource "aws_lb" "alb" {
  name               = "${local.name_prefix}-alb"
  load_balancer_type = "application"
  subnets            = values(aws_subnet.subnets)[*].id
  security_groups    = [aws_security_group.sg.id]
}

resource "aws_lb_target_group" "tg" {
  name     = "${local.name_prefix}-tg" 
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = local.vpc_id

  # Connection Draining: Wait 30s for active requests to finish 
  # before fully terminating the instance.
  deregistration_delay = 30

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}
#GREEN
resource "aws_lb_target_group" "green" {
  name        = "${var.cluster_name}-green"
  port        = var.server_port
  protocol    = "HTTP"
  vpc_id      = local.vpc_id

  deregistration_delay = 30

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  } 
}


resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = var.active_environment == "blue" ?  aws_lb_target_group.tg.arn : aws_lb_target_group.green.arn 
  }
}

# -------------------------------
# AUTO SCALING GROUP
# -------------------------------

resource "random_id" "server" {
  keepers = {
    # A new random ID is generated when the launch configuration changes
    ami_id = data.aws_ami.ubuntu.id
  }
  byte_length = 8
}

resource "aws_autoscaling_group" "asg" {
  count = var.enable_autoscaling ? 1 : 0

  name_prefix         = "${var.cluster_name}-asg"
  min_size            = local.min_size
  max_size            = local.max_size
  desired_capacity    = local.min_size
  vpc_zone_identifier = values(aws_subnet.subnets)[*].id

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
  }

  instance_refresh {
    strategy = "Rolling"
    triggers = ["launch_template"]
    
    preferences {
      min_healthy_percentage = 100
    }
  }

  tag {
    key                 = "My-server"
    value               = "${var.environment}-asg"
    propagate_at_launch = true
  }

  target_group_arns = [aws_lb_target_group.tg.arn]
  health_check_type = "ELB"
}


resource "aws_autoscaling_group" "green" {
  count = var.enable_autoscaling ? 1 : 0

  name_prefix         = "${var.cluster_name}-asg"
  min_size            = local.min_size
  max_size            = local.max_size
  desired_capacity    = local.min_size
  vpc_zone_identifier = values(aws_subnet.subnets)[*].id

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
  }

  instance_refresh {
    strategy = "Rolling"
    triggers = ["launch_template"]
    
    preferences {
      min_healthy_percentage = 100
    }
  }

  tag {
    key                 = "My-server"
    value               = "${var.environment}-asg"
    propagate_at_launch = true
  }

  target_group_arns = [aws_lb_target_group.green.arn]
  health_check_type = "ELB"
}


resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  count = local.enable_monitoring ? 1 : 0

  alarm_name         = "${var.environment}-high-cpu"
  comparison_operator      = "GreaterThanThreshold"
  evaluation_periods       = 2
  metric_name              = "CPUUtilization" 
  namespace                = "AWS/EC2"
  period                   = 120
  statistic                = "Average"
  threshold                = 80

  alarm_description = "CPU usage too high"
}

resource "aws_db_instance" "appdb" {
  engine              = "mysql"
  engine_version      = "8.0"
  instance_class      = "db.t3.micro"
  db_name             = "appdb"

  allocated_storage = 10
  skip_final_snapshot = true

  username = local.db_credentials["username"]
  password = local.db_credentials["password"]
}

