# Create S3 Bucket for MLflow artifacts storage
module "s3_bucket" {
  source = "../../shared/s3"

  bucket_name       = var.s3_bucket_name
  enable_versioning = true

  tags = merge(
    local.common_tags,
    {
      Name    = var.s3_bucket_name
      Purpose = "MLflow Artifacts Storage"
    }
  )
}