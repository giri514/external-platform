variable "environment" {
  type        = string
  description = "Execution environment"
}

variable "contact_emails" {
  type        = string
  description = "Contact emails (the people who set up most of this stuff)"
}

variable "public_subnet" {
  type        = string
  description = "ID of public subnet for bastion host."
}

variable "private_subnet" {
  type        = string
  description = "ID of private subnet for private host."
}

variable "vpc" {
  type        = string
  description = "ID of VPC for instances,"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC that can access private instance."
}

variable "bastion_key_pair_name" {
  type        = string
  description = "SSH key name for bastion. Should be manually created in console."
  default     = "bastion_dev"
}

variable "private_host_key_pair_name" {
  type        = string
  description = "SSH key name for private host. Should be manually created in console."
  default     = "private_host"
}
