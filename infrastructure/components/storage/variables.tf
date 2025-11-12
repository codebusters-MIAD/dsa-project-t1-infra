variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "MIAD"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "development"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "db_identifier" {
  description = "Database identifier"
  type        = string
  default     = "filmlens-postgres"
}

variable "database_name" {
  description = "Name of the database"
  type        = string
  default     = "filmlens"
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t4g.small"
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}
