variable "environment" {
  type        = string
  description = "Execution environment"
  default     = "dev"
}

variable "domain" {
  type        = string
  description = "The root domain being used for routes"
  default     = "reecedev.us"
}

variable "subject_alternative_names" {
  type        = list(string)
  description = "The alternate domains covered by the cert e.g.: *.domain, *.internal.domain"
}
