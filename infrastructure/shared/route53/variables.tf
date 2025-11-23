variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "domain_name" {
  description = "Root domain name for the hosted zone"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the hosted zone"
  type        = map(string)
  default     = {}
}
