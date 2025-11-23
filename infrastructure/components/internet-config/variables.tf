variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "filmlens"
}

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  default     = "production"
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "domain_name" {
  description = "Root domain name (e.g., atesorapp.com)"
  type        = string
}

variable "subdomains" {
  description = "List of subdomains to include in the SSL certificate"
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "VPC ID where Internet Gateway should exist"
  type        = string
}

variable "internet_gateway_id" {
  description = "Internet Gateway ID to validate (optional, will be discovered if not provided)"
  type        = string
  default     = ""
}

variable "create_hosted_zone" {
  description = "Whether to create a new Route 53 Hosted Zone (true) or use existing one (false)"
  type        = bool
  default     = true
}

variable "hosted_zone_id" {
  description = "Existing Route 53 Hosted Zone ID (required if create_hosted_zone = false)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Railway Dashboard Configuration
variable "railway_enabled" {
  description = "Whether to create a Route 53 record for Railway dashboard"
  type        = bool
  default     = false
}

variable "railway_subdomain" {
  description = "Subdomain for Railway dashboard (e.g., 'filmlens' will create filmlens.atesorapp.com)"
  type        = string
  default     = "filmlens"
}

variable "railway_domain" {
  description = "Railway production domain (e.g., beautiful-generosity-production.up.railway.app)"
  type        = string
  default     = ""
}
