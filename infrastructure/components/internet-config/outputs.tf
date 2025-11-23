output "certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = module.acm_certificate.certificate_arn
}

output "hosted_zone_id" {
  description = "Route 53 Hosted Zone ID"
  value       = var.create_hosted_zone ? module.route53_hosted_zone[0].hosted_zone_id : var.hosted_zone_id
}

output "hosted_zone_name_servers" {
  description = "Route 53 Hosted Zone name servers (to configure in GoDaddy if needed)"
  value       = var.create_hosted_zone ? module.route53_hosted_zone[0].name_servers : []
}

output "internet_gateway_id" {
  description = "Internet Gateway ID (validated)"
  value       = data.aws_internet_gateway.main.id
}

output "domain_name" {
  description = "Root domain name"
  value       = var.domain_name
}

output "certificate_domain_validation_options" {
  description = "Certificate domain validation options (for manual validation if needed)"
  value       = module.acm_certificate.domain_validation_options
  sensitive   = false
}

output "railway_dashboard_fqdn" {
  description = "Fully qualified domain name for Railway dashboard"
  value       = var.railway_enabled ? "${var.railway_subdomain}.${var.domain_name}" : null
}

output "railway_dashboard_cname" {
  description = "CNAME target for Railway dashboard"
  value       = var.railway_enabled ? var.railway_domain : null
}
