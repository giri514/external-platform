variable "name" {
  type        = string
  default     = "external"
  description = "Name of the type of apps this environment is supporting"
}

variable "environment" {
  type        = string
  description = "Execution environment"
}

variable "contact_emails" {
  type        = string
  description = "Contact emails (the people who set up most of this stuff)"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC."
}

variable "public_subnets" {
  type        = any
  description = "CIDR block for the Public Subnet."
}

variable "private_subnets" {
  type        = any
  description = "CIDR blocks for the Private Subnet."
}

variable "availability_zones" {
  type        = any
  description = "List of availability zones"
  default     = ["us-east-1a", "us-east-1b"]
}

variable "transit_gateway_id" {
  type        = string
  description = "ID of manually created transit gateway"
}
