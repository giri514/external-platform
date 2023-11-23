variable "cluster_id" {
  type        = string
  description = "The ID of the eks cluster"
}

variable "environment" {
  type        = string
  description = "Execution environment"
}

variable "cert_arn" {
  type        = string
  description = "The ARN of the cert used by AWS Load Balancer Controller"
}

variable "name" {
  type        = string
  description = "the name of the stack"
  default     = "external"
}

variable "availability_zones" {
  type        = any
  description = "Availability zones used for k8s / vpc"
}
