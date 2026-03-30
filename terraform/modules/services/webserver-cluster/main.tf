# -------------------------------
# DATA SOURCES
# -------------------------------

data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

locals {
  name_prefix = lower(replace(var.cluster_name, "_", "-"))
}
# -------------------------------
# NETWORKING
# -------------------------------

resource "aws_vpc" "lab" {
  cidr_block = var.vpc_cidr

  tags = {
    Name        = "${local.name_prefix}-vpc"
    Environment = var.environment
  }
}

resource "aws_subnet" "subnet_1" {
  vpc_id                  = aws_vpc.lab.id
  cidr_block              = var.subnet_1_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${local.name_prefix}-subnet-1"
    Environment = var.environment
  }
}

resource "aws_subnet" "subnet_2" {
  vpc_id                  = aws_vpc.lab.id
  cidr_block              = var.subnet_2_cidr
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${local.name_prefix}-subnet-2"
    Environment = var.environment
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.lab.id

  tags = {
    Name = "${local.name_prefix}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.lab.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "subnet_1" {
  subnet_id      = aws_subnet.subnet_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "subnet_2" {
  subnet_id      = aws_subnet.subnet_2.id
  route_table_id = aws_route_table.public.id
}

# -------------------------------
# SECURITY GROUPS
# -------------------------------

resource "aws_security_group" "sg" {
  name   = "${local.name_prefix}-sg"
  vpc_id = aws_vpc.lab.id

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
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.sg.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    apt update -y
    apt install -y apache2 git
    systemctl start apache2
    systemctl enable apache2
    rm -rf /var/www/html/*
    git clone ${var.repo_url} /var/www/html
  EOF
  )
}

# -------------------------------
# LOAD BALANCER
# -------------------------------

resource "aws_lb" "alb" {
  name               = "${local.name_prefix}-alb"
  load_balancer_type = "application"
  subnets            = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]
  security_groups    = [aws_security_group.sg.id]
}

resource "aws_lb_target_group" "tg" {
  name     = "${local.name_prefix}-tg" 
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.lab.id
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# -------------------------------
# AUTO SCALING GROUP
# -------------------------------

resource "aws_autoscaling_group" "asg" {
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.min_size
  vpc_zone_identifier = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.tg.arn]
}

