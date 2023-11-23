####
# Load Balancer Definitions

# maX graphql api load balancer
data "aws_lb" "max_api_external_lb" {
  arn = var.lb_arn_max_api
}

#Mobile BFF load balancer
data "aws_lb" "mobile_bff_external_lb" {
  arn = var.lb_arn_mobile_bff
}

####
# DNS Hosted Zone
####

## Create the hosted zone for DNS
resource "aws_route53_zone" "dev" {
  name = "external-${var.environment}.reecedev.us"

  tags = {
    Environment = var.environment
  }
}

####
# DNS A Records for Subdomains
####

## Public GraphQL API
resource "aws_route53_record" "public_api" {
  zone_id = aws_route53_zone.dev.zone_id
  name    = "api"
  type    = "A"

  alias {
    name                   = data.aws_lb.max_api_external_lb.dns_name
    zone_id                = data.aws_lb.max_api_external_lb.zone_id
    evaluate_target_health = true
  }
}

## maX Frontend
resource "aws_route53_record" "maX" {
  zone_id = aws_route53_zone.dev.zone_id
  name    = "app"
  type    = "A"

  alias {
    name                   = var.cloudfront_dns
    zone_id                = var.cloudfront_hosted_zone // There is one static zone on aws for this
    evaluate_target_health = true
  }
}

# Mobile BFF
resource "aws_route53_record" "mobile_bff" {
  zone_id = aws_route53_zone.dev.zone_id
  name    = "mobile-bff"
  type    = "A"
  alias {
    name                   = data.aws_lb.mobile_bff_external_lb.dns_name
    zone_id                = data.aws_lb.mobile_bff_external_lb.zone_id
    evaluate_target_health = true
  }
}

# Grafana (monitoring UI)
resource "aws_route53_record" "grafana" {
 zone_id = aws_route53_zone.dev.zone_id
 name    = "grafana"
 type    = "A"

 alias {
   name                   = var.lb_grafana_name
   zone_id                = var.lb_grafana_zone
   evaluate_target_health = true
 }
}



## white labeling URLs for maX subdomains
resource "aws_route53_record" "www" {
  count   = var.is_prod ? 0 : 1
  zone_id = aws_route53_zone.dev.zone_id
  name    = "www."
  type    = "CNAME"
  records = ["app.${var.domain}"]
  ttl     = "300"
}
resource "aws_route53_record" "fortiline" {
  count   = var.is_prod ? 0 : 1
  zone_id = aws_route53_zone.dev.zone_id
  name    = "fortiline."
  type    = "CNAME"
  records = ["app.${var.domain}"]
  ttl     = "300"
}
resource "aws_route53_record" "morrisonsupply" {
  count   = var.is_prod ? 0 : 1
  zone_id = aws_route53_zone.dev.zone_id
  name    = "morrisonsupply."
  type    = "CNAME"
  records = ["app.${var.domain}"]
  ttl     = "300"
}
resource "aws_route53_record" "morscohvacsupply" {
  count   = var.is_prod ? 0 : 1
  zone_id = aws_route53_zone.dev.zone_id
  name    = "morscohvacsupply."
  type    = "CNAME"
  records = ["app.${var.domain}"]
  ttl     = "300"
}
resource "aws_route53_record" "murraysupply" {
  count   = var.is_prod ? 0 : 1
  zone_id = aws_route53_zone.dev.zone_id
  name    = "murraysupply."
  type    = "CNAME"
  records = ["app.${var.domain}"]
  ttl     = "300"
}
resource "aws_route53_record" "fwcaz" {
  count   = var.is_prod ? 0 : 1
  zone_id = aws_route53_zone.dev.zone_id
  name    = "fwcaz."
  type    = "CNAME"
  records = ["app.${var.domain}"]
  ttl     = "300"
}
resource "aws_route53_record" "expresspipe" {
  count   = var.is_prod ? 0 : 1
  zone_id = aws_route53_zone.dev.zone_id
  name    = "expresspipe."
  type    = "CNAME"
  records = ["app.${var.domain}"]
  ttl     = "300"
}
resource "aws_route53_record" "devoreandjohnson" {
  count   = var.is_prod ? 0 : 1
  zone_id = aws_route53_zone.dev.zone_id
  name    = "devoreandjohnson."
  type    = "CNAME"
  records = ["app.${var.domain}"]
  ttl     = "300"
}
resource "aws_route53_record" "toddpipe" {
  count   = var.is_prod ? 0 : 1
  zone_id = aws_route53_zone.dev.zone_id
  name    = "toddpipe."
  type    = "CNAME"
  records = ["app.${var.domain}"]
  ttl     = "300"
}
resource "aws_route53_record" "wholesalespecialties" {
  count   = var.is_prod ? 0 : 1
  zone_id = aws_route53_zone.dev.zone_id
  name    = "wholesalespecialties."
  type    = "CNAME"
  records = ["app.${var.domain}"]
  ttl     = "300"
}
resource "aws_route53_record" "expressionshomegallery" {
  count   = var.is_prod ? 0 : 1
  zone_id = aws_route53_zone.dev.zone_id
  name    = "expressionshomegallery."
  type    = "CNAME"
  records = ["app.${var.domain}"]
  ttl     = "300"
}
resource "aws_route53_record" "landbpipe" {
  count   = var.is_prod ? 0 : 1
  zone_id = aws_route53_zone.dev.zone_id
  name    = "landbpipe."
  type    = "CNAME"
  records = ["app.${var.domain}"]
  ttl     = "300"
}

resource "aws_route53_record" "irvinepipe" {
  count   = var.is_prod ? 0 : 1
  zone_id = aws_route53_zone.dev.zone_id
  name    = "irvinepipe."
  type    = "CNAME"
  records = ["app.${var.domain}"]
  ttl     = "300"
}

resource "aws_route53_record" "schumacherseiler" {
  count   = var.is_prod ? 0 : 1
  zone_id = aws_route53_zone.dev.zone_id
  name    = "schumacherseiler."
  type    = "CNAME"
  records = ["app.${var.domain}"]
  ttl     = "300"
}
