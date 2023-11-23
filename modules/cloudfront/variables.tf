variable "environment" {
  type        = string
  description = "Execution environment"
}

variable "WAF_id" {
  type        = string
  description = "The id of the web application firewall"
  default     = null
}

variable "cert_arn" {
  type        = string
  description = "The certificate being used for the cloudfront distribution"
}

variable "WAF_enabled" {
  type        = bool
  description = "is the firewall with the ip whitelist enabled"
  default     = true
}

variable "alternate_domain_names" {
  type        = list(string)
  description = "list of alternate UI domains"
}

variable "max_portal_lb_arn" {
  type        = string
  description = "the arn for the alb created for the max portal"
}
