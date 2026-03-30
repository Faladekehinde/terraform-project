terraform {
  backend "s3" {
    bucket         = "falade-state-bucket"
    key            = "environments/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

