variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "cluster_name" {
  description = "Name used for all resources"
  type        = string
}

variable "environment" {
  description = "dev, staging, or production"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Evironment must be dev, staging, or production."
  }
}

variable "active_environment" {
  description = "which environment receives the traffic"
  type        =  string
  default     = "blue"
  
}


variable "create_dns_record" {
  type    = bool
  default = false
}

variable "use_existing_vpc" {
  type    = bool
  default = false
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "server_text" {
  description = "Text to display on the server (v1/v2)"
  type        = string
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
  default = true 
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID"
  type        = string
  default     = "null"
}


variable "repo_url" {
  description = "GitHub repo for web app"
  type        = string
}