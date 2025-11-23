variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "domain_name" {
  description = "Primary domain name for the certificate"
  type        = string
}

variable "subject_alternative_names" {
  description = "Additional domain names to include in the certificate (SANs)"
  type        = list(string)
  default     = []
}

variable "hosted_zone_id" {
  description = "Route 53 Hosted Zone ID for DNS validation (required if create_dns_records = true)"
  type        = string
  default     = ""
}

variable "create_dns_records" {
  description = "Whether to automatically create DNS validation records in Route 53"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to the certificate"
  type        = map(string)
  default     = {}
}
