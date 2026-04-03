variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

#variable "servers" {
#  description = "Map of servers with instancs types"
#  type        = map(string)

 # default = {
   # web   = "t3.micro"
   # api   =" t3.small"
   # db    = "t3.medium"
  #}
#}

variable "cluster_name" {
  description = "Name used for all resources"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
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
  default     = "t3.micro"
}

variable "min_size" {
  type    = number
  default = 2
}

variable "max_size" {
  type    = number
  default = 4
}

variable "enable_autoscaling" {
  type    = bool
  default = true 
}

variable "repo_url" {
  type    = string
  default = "https://github.com/CeeyIT-Solutions/food3.git"
}


 