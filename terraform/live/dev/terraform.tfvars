cluster_name       = "web-dev"
environment        = "dev"
aws_region         = "us-east-1"


vpc_cidr      = "10.0.0.0/16"

subnets = {
  subnet-1 = {
    cidr_block = "10.0.1.0/24"
    az_index   = 0
  }
  subnet-2 = {
    cidr_block = "10.0.2.0/24"
    az_index   = 1
  }
}
repo_url = "https://github.com/CeeyIT-Solutions/food3.git"

instance_type = "t3.micro"
min_size      = 2
max_size      = 4