module "webserver_cluster" {
  source = "../../modules/services/webserver-cluster"
  # production stays pinned to the stable version
  cluster_name = var.cluster_name
  environment  = var.environment
  aws_region   = var.aws_region
  enable_autoscaling = true

  instance_type = local.instance_type
  min_size      = var.min_size
  max_size      = var.max_size

  vpc_cidr      = var.vpc_cidr
  subnets       = var.subnets

  repo_url = var.repo_url
}

