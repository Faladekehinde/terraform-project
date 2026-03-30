cluster_name = "web-prod"
environment  = "prod"
aws_region   = "us-east-2"

vpc_cidr      = "10.1.0.0/16"
subnet_1_cidr = "10.1.1.0/24"
subnet_2_cidr = "10.1.2.0/24"

repo_url = "https://github.com/CeeyIT-Solutions/ecomm-3.git"

instance_type = "t3.small"
min_size      = 1
max_size      = 2