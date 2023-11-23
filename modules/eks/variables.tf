variable "name" {
  type        = string
  description = "the name of the stack"
  default     = "external"
}

variable "environment" {
  type        = string
  description = "Execution environment"
}

variable "aws_region" {
  type        = string
  description = "the AWS region"
}

variable "vpc_id" {
  type        = string
  description = "The VPC the cluster should be created in"
}

variable "private_subnets" {
  type        = any
  description = "List of private subnet IDs"
}

variable "public_subnets" {
  type        = any
  description = "List of public subnet IDs"
}

variable "kubeconfig_path" {
  type        = string
  description = "Path where the config file for kubectl should go"
}

variable "contact_emails" {
  type        = string
  description = "Contact emails (the people who set up most of this stuff)"
}

variable "availability_zones" {
  type        = any
  description = "Availability zones used for k8s / vpc"
}

variable "kubernetes_version" {
  type        = string
  description = "The current cluster version"
}
