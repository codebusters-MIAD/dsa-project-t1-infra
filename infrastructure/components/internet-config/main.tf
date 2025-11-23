# Module: Route 53 Hosted Zone (create new or use existing)
module "route53_hosted_zone" {
  count  = var.create_hosted_zone ? 1 : 0
  source = "../../shared/route53"

  project_name = var.project_name
  domain_name  = var.domain_name
  tags         = var.tags
}

# Local variables for hosted zone ID
locals {
  hosted_zone_id = var.create_hosted_zone ? module.route53_hosted_zone[0].hosted_zone_id : var.hosted_zone_id
  
  # Prepare certificate domain list
  # Primary domain + subdomains
  certificate_domains = concat(
    [var.domain_name],
    var.subdomains
  )
  
  # Extract SANs (all domains except the primary)
  subject_alternative_names = slice(local.certificate_domains, 1, length(local.certificate_domains))
}

# Module: ACM Certificate with DNS validation
module "acm_certificate" {
  source = "../../shared/acm"

  project_name              = var.project_name
  domain_name               = var.domain_name
  subject_alternative_names = local.subject_alternative_names
  hosted_zone_id            = local.hosted_zone_id
  # Only auto-create if we manage the hosted zone
  create_dns_records        = var.create_hosted_zone  
  tags                      = var.tags
}

# Route 53 Record: CNAME for Railway Dashboard
resource "aws_route53_record" "railway_dashboard" {
  count   = var.railway_enabled ? 1 : 0
  zone_id = local.hosted_zone_id
  name    = "${var.railway_subdomain}.${var.domain_name}"
  type    = "CNAME"
  ttl     = 300
  
  records = [var.railway_domain]
  
  depends_on = [
    module.route53_hosted_zone
  ]
}
