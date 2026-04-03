variable "cluster_name" {
  description = "Name used for all resources"
  type        = string
}

variable "environment" {
  description = "Environment name (dev or production)"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "min_size" {
  description = "Minimum number of instances"
  type        = number
  default     = 2 
}

variable "max_size" {
  description = "Maximum number of instances"
  type        = number
  default     = 4
}

variable "server_port" {
  description = "HTTP port"
  type        = number
  default     = 80
}

variable "ssh_port" {
  description = "SSH port"
  type        = number
  default     = 22
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "subnets" {
  type = map(object({
    cidr_block = string
    az_index   = number
  }))
}

variable "enable_autoscaling" {
  type    = bool
  default = false 
}


variable "repo_url" {
  description = "GitHub repo for web app"
  type        = string
}