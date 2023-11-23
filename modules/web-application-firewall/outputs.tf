output "WAF_id" {
  description = "The id of the web application firewall"
  value       = aws_waf_web_acl.waf_acl.id
}
