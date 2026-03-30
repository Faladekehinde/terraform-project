variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "cluster_name" {
  description = "Name used for all resources"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.1.0.0/16"
}

variable "subnet_1_cidr" {
  type    = string
  default = "10.1.1.0/24"
}

variable "subnet_2_cidr" {
  type    = string
  default = "10.1.2.0/24"
}

variable "server_port" {
  type    = number
  default = 80
}

variable "ssh_port" {
  type    = number
  default = 22
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 2
}

variable "repo_url" {
  type    = string
  default = "https://github.com/CeeyIT-Solutions/ecomm-3.git"
}


