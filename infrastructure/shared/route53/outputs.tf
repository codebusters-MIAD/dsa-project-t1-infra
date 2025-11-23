output "hosted_zone_id" {
  description = "The Hosted Zone ID"
  value       = aws_route53_zone.main.zone_id
}

output "name_servers" {
  description = "Name servers for the hosted zone"
  value       = aws_route53_zone.main.name_servers
}

output "hosted_zone_arn" {
  description = "ARN of the hosted zone"
  value       = aws_route53_zone.main.arn
}

output "domain_name" {
  description = "Domain name of the hosted zone"
  value       = aws_route53_zone.main.name
}
