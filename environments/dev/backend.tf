terraform {
  backend "s3" {
    bucket         = "reece-external-terraform-state-dev"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "external-terraform-locks"
    encrypt        = true
  }
}
