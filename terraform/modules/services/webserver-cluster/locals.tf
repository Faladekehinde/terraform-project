locals {
  name_prefix = lower(replace(var.cluster_name, "_", "-"))
}


locals {
  is_production = var.environment =="production"

  instance_type       = local.is_production ? "t3yes.micro" : "t3.micro"
  min_size            = local.is_production ? 3 : 1
  max_size            = local.is_production ? 10 : 3
  enable_autoscaling  = local.is_production
  enable_monitoring   = local.is_production ? true : false
  deletion_policy     = local.is_production  ? "Retain" : "Delete"
}

locals {
  vpc_id = var.use_existing_vpc ? data.aws_vpc.existing[0].id : aws_vpc.lab[0].id
}