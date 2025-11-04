
# S3 Bucket Outputs
output "s3_bucket_name" {
  description = "Name of the S3 bucket for MLflow artifacts storage"
  value       = module.s3_bucket.bucket_name
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = module.s3_bucket.bucket_arn
}

output "s3_bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = module.s3_bucket.bucket_domain_name
}

# MLflow Configuration
output "mlflow_artifact_uri" {
  description = "MLflow artifact store URI for configuration"
  value       = "s3://${module.s3_bucket.bucket_name}"
}

output "mlflow_s3_endpoint_url" {
  description = "S3 endpoint URL for MLflow configuration"
  value       = "https://s3.${var.aws_region}.amazonaws.com"
}
