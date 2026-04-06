module "webserver_cluster" {
  source      = "../../modules/services/webserver-cluster"
  
  cluster_name = var.cluster_name
  environment  = var.environment
  aws_region   = var.aws_region

  create_dns_record   = false
  use_existing_vpc    = false

  instance_type = local.instance_type
  
  min_size      = var.min_size
  max_size      = var.max_size

  vpc_cidr      = var.vpc_cidr
  subnets       = var.subnets
  
  repo_url = var.repo_url
}

