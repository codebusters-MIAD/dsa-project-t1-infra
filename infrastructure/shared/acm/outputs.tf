output "certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = aws_acm_certificate.main.arn
}

output "certificate_id" {
  description = "ID of the ACM certificate"
  value       = aws_acm_certificate.main.id
}

output "certificate_status" {
  description = "Status of the ACM certificate"
  value       = aws_acm_certificate.main.status
}

output "domain_validation_options" {
  description = "Domain validation options (for manual validation if needed)"
  value       = aws_acm_certificate.main.domain_validation_options
}

output "certificate_domain_name" {
  description = "Primary domain name of the certificate"
  value       = aws_acm_certificate.main.domain_name
}

output "subject_alternative_names" {
  description = "Subject Alternative Names (SANs) of the certificate"
  value       = aws_acm_certificate.main.subject_alternative_names
}
