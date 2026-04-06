cluster_name = "web-prod"
environment  = "production"
aws_region   = "us-east-2"
enable_autoscaling = true

vpc_cidr      = "10.1.0.0/16"

subnets = {
    subnet-1 = {
        cidr_block = "10.1.1.0/24"
        az_index   = 0
    }
    subnet-2 = {
        cidr_block = "10.1.2.0/24"
        az_index   = 1
    }
}
repo_url = "https://github.com/CeeyIT-Solutions/ecomm-3.git"

instance_type = "t3.medium"
min_size      = 2
max_size      = 6