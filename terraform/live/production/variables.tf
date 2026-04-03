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

variable "subnets" {
  type         = map(object({
    cidr_block = string
    az_index   = number
  }))
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
  default     = "t3.medium"
}

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 2
}

variable "enable_autoscaling" {
  type    = bool
  default = true 
}

variable "repo_url" {
  type    = string
  default = "https://github.com/CeeyIT-Solutions/ecomm-3.git"
}


