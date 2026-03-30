module "webserver_cluster" {
  source = "github.com/Faladekehinde/terraform-project.git//terraform/modules/services/webserver-cluster?ref=v0.0.1"
  # production stays pinned to the stable version
  cluster_name = var.cluster_name
  environment  = var.environment
  aws_region   = var.aws_region

  instance_type = var.instance_type
  min_size      = var.min_size
  max_size      = var.max_size

  vpc_cidr      = var.vpc_cidr
  subnet_1_cidr = var.subnet_1_cidr
  subnet_2_cidr = var.subnet_2_cidr

  repo_url = var.repo_url
}

