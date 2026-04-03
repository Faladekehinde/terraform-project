locals {
    instance_type = var.instance_type != "" ? var.instance_type : (
    var.environment == "production" ? "t3.medium" : "t3.micro"
    )
}