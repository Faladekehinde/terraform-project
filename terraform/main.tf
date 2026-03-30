provider "aws" {
  region = var.aws_region
}

# -------------------------------
# DATA SOURCES
# -------------------------------

data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

data "aws_ami" "ubuntu_22_04" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# -------------------------------
# NETWORKING
# -------------------------------

resource "aws_vpc" "lab_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
     Name       = "${var.vpc_name}-${terraform.workspace}"#HERE
    Environment = terraform.workspace
    Terraform   = "true"
    Region      = data.aws_region.current.id
  }
}

resource "aws_subnet" "subnet_1" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = var.subnet_1_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "subnet_2" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = var.subnet_2_cidr
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = var.subnet_2_auto_ip

  tags = {
    Name = "public-subnet-2"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.lab_vpc.id

  tags = {
    Name = "lab-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.lab_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "subnet_1_assoc" {
  subnet_id      = aws_subnet.subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "subnet_2_assoc" {
  subnet_id      = aws_subnet.subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

# -------------------------------
# SECURITY GROUPS
# -------------------------------

resource "aws_security_group" "web_sg" {
  name   = "web-sg-${terraform.workspace}"#HERE
  vpc_id = aws_vpc.lab_vpc.id

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

  tags = {
    Name = "web-sg-${terraform.workspace}"
  }
}

resource "aws_security_group" "alb_sg" {
  name   = "alb-sg-${terraform.workspace}" #HERE
  vpc_id = aws_vpc.lab_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg-${terraform.workspace}" #HERE
  }
}

# -------------------------------
# LAUNCH TEMPLATE
# -------------------------------

resource "aws_launch_template" "web" {
  name_prefix   = "web-template"
  image_id      = data.aws_ami.ubuntu_22_04.id
  instance_type = var.instance_type[terraform.workspace]#HERE

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -e

    apt update -y
    apt install -y apache2 git

    systemctl start apache2
    systemctl enable apache2

    rm -rf /var/www/html/*
    git clone ${var.repo_url} /var/www/html

    chown -R www-data:www-data /var/www/html
    chmod -R 755 /var/www/html
  EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "web-server-${terraform.workspace}" #HERE
    }
  }
}

# -------------------------------
# LOAD BALANCER
# -------------------------------

resource "aws_lb" "web" {
  name               = "web-alb-${terraform.workspace}"#HERE
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]
  security_groups    = [aws_security_group.alb_sg.id]
}

resource "aws_lb_target_group" "web" {
  name        = "web-tg-${terraform.workspace}"
  port        = var.server_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.lab_vpc.id
  target_type = "instance"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
  }
}

resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.web.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

# -------------------------------
# AUTO SCALING GROUP
# -------------------------------

resource "aws_autoscaling_group" "web" {
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = 2
  vpc_zone_identifier       = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]
  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.web.arn]
}

# -------------------------------
# OUTPUT
# -------------------------------

output "alb_dns_name" {
  value = aws_lb.web.dns_name
}

terraform {
  backend "s3" {
    bucket         = "falade-state-bucket"
    key            = "project/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}