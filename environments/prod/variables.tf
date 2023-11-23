variable "aws_region" {
  type        = string
  description = "The region where the AWS Resources will be configured."
  default     = "us-east-1"
}

variable "aws_credentials_file" {
  type        = string
  description = "The path to where the credentials are stored when running `aws configure`."
  default     = "$HOME/.aws/credentials"
}

variable "aws_credentials_profile" {
  type        = string
  description = "The profile configured when running `aws configure`."
  default     = "" # Leave blank. Terraform will use "default" unless a shell environment variable for AWS_PROFILE is set.
}

variable "kubeconfig_path" {
  type        = string
  description = "Path where the config file for kubectl should be written to"
  default     = "~/.kube"
}
