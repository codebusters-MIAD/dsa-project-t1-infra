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

# S3 Bucket variables
variable "s3_bucket_name" {
  description = "Name of the S3 bucket for MLFlow artifacts"
  default     = "filmlens-mlflow-artifacts"
  type        = string
}
  