terraform {
  backend "s3" {
    bucket         = "reece-external-terraform-state-test"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "external-terraform-locks"
    encrypt        = true
  }
}
