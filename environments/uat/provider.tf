# Configure the AWS Provider
provider "aws" {
  region = var.aws_region

  # credentials
  shared_credentials_files = [var.aws_credentials_file]
  profile                  = var.aws_credentials_profile
}
