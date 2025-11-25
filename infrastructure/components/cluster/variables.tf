variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "MIAD"
}

variable "environment" {
  description = "Environment name (development, staging, production)"
  type        = string
  default     = "development"
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

# VPC and Networking
variable "vpc_id" {
  description = "VPC ID where resources will be created"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for ECS tasks"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ALB"
  type        = list(string)
}

# Database
variable "db_secret_arn" {
  description = "ARN of the Secrets Manager secret containing DATABASE_URL"
  type        = string
}

# Docker Images
variable "api_image" {
  description = "Docker image URI for API service"
  type        = string
}

variable "query_api_image" {
  description = "Docker image URI for Query API service"
  type        = string
}

variable "mlflow_image" {
  description = "Docker image URI for MLflow service"
  type        = string
}

# MLflow Configuration
variable "mlflow_backend_store_uri" {
  description = "PostgreSQL connection string para MLflow backend store (formato: postgresql://user:pass@host:port/db)"
  type        = string
  sensitive   = true
}

variable "mlflow_s3_artifact_bucket" {
  description = "Nombre del bucket S3 para artifacts de MLflow"
  type        = string
}

# Tags
variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
