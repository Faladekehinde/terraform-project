locals {
    instance_type = var.instance_type != "" ? var.instance_type : (
    var.environment == "dev" ? "t3.medium" : "t2.micro"
    )
}