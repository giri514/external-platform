resource "aws_acm_certificate" "cert" {
  domain_name               = var.domain
  subject_alternative_names = var.subject_alternative_names
  validation_method         = "DNS"

  tags = {
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}
