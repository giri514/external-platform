variable "environment" {
  type        = string
  description = "Execution environment"
  default     = "dev"
}

variable "root_zone_id" {
  type        = string
  description = "The hosted zone id of the load balancer and dns records"
}

variable "lb_arn_max_api" {
  type        = string
  description = "The arn of the load balancer created by the module alb-ingress for max api"
}

variable "lb_grafana_name" {
  type        = string
  description = "The DNS name of the load balancer created by the module prometheus for Grafana UI"
}
variable "lb_grafana_zone" {
  type        = string
  description = "The zone ID of the load balancer created by the module prometheus for Grafana UI"
}

variable "cloudfront_dns" {
  type        = string
  description = "The dns of the public ui cloudfront distribution"
}

variable "cloudfront_hosted_zone" {
  type        = string
  description = "AWS has one static zone for all of cloudfront: Z2FDTNDATAQYW2"
  default     = "Z2FDTNDATAQYW2"
}

variable "is_prod" {
  type        = bool
  description = "if true, will create ns records to point to the test domain in the test env"
  default     = false
}

variable "domain" {
  type        = string
  description = "eg: reecedev.us for the dev env"
}

variable "lb_arn_mobile_bff" {
  type        = string
  description = "lb_arn_mobile_bff"
}