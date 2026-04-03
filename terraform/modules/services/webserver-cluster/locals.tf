locals {
  name_prefix = lower(replace(var.cluster_name, "_", "-"))
}

locals {
    instance_type = var.environment == "production" ? "t3.small" : "t3.micro"
}

