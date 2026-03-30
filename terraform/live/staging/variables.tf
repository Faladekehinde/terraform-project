variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_name" {
  description = "VPC name"
  type        = string
  default     = "lab-vpc"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_1_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "subnet_2_cidr" {
  type    = string
  default = "10.0.2.0/24"
}

variable "subnet_2_auto_ip" {
  type    = bool
  default = true
}

variable "server_port" {
  type    = number
  default = 80
}

variable "ssh_port" {
  type    = number
  default = 22
}

#variable "instance_type" {
#  description = "EC2 instance type"
#  type        = string
#  default     = "t3.micro"
#}

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 1
}

variable "repo_url" {
  type    = string
  default = "https://github.com/CeeyIT-Solutions/ecomm-3.git"
}


variable "instance_type" {
  type = map(string)
  default = {
    dev        = "t3.micro"
   staging    = "t3.small"
    production = "t3.medium"
  }
}