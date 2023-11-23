data "aws_alb" "max_portal_lb" {
  arn = var.max_portal_lb_arn
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {}

resource "aws_cloudfront_distribution" "web_driver_distribution" {
  aliases = var.alternate_domain_names

  origin {
    domain_name = data.aws_alb.max_portal_lb.dns_name
    origin_id   = data.aws_alb.max_portal_lb.name

    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  origin {
    domain_name = "reece-mcfadyen-cro.vercel.app" # Replace with your Vercel app URL
    origin_id   = "VercelApp"

    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  web_acl_id          = (var.WAF_enabled ? var.WAF_id : null)
  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = data.aws_alb.max_portal_lb.name

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.redirect_domains_lower.arn
    }
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.cert_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1"
  }

  ordered_cache_behavior {
    path_pattern     = "/homepage/*"
    target_origin_id = "VercelApp"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
  }
}

resource "aws_cloudfront_function" "redirect_domains_lower" {
  name    = "redirect_domains_lower"
  runtime = "cloudfront-js-1.0"
  publish = true
  code    = file("${path.module}/functions/redirects.js")
}
