output "db_endpoint" {
  description = "Database endpoint"
  value       = module.postgres_db.db_instance_endpoint
}

output "db_name" {
  description = "Database name"
  value       = module.postgres_db.db_instance_name
}

output "db_username" {
  description = "Database username"
  value       = module.postgres_db.db_master_username
  sensitive   = true
}

output "db_password" {
  description = "Database password"
  value       = module.postgres_db.db_master_password
  sensitive   = true
}

output "connection_string" {
  description = "Database connection string"
  value       = "postgresql://${module.postgres_db.db_master_username}:${module.postgres_db.db_master_password}@${module.postgres_db.db_instance_address}:${module.postgres_db.db_instance_port}/${module.postgres_db.db_instance_name}"
  sensitive   = true
}

# SECRETS MANAGER OUTPUTS
output "db_secret_arn" {
  description = "ARN del secret en AWS Secrets Manager (usar en ECS task definitions)"
  value       = module.postgres_db.db_secret_arn
}

output "db_secret_name" {
  description = "Nombre del secret en AWS Secrets Manager"
  value       = module.postgres_db.db_secret_name
}

output "db_secret_id" {
  description = "ID del secret en AWS Secrets Manager"
  value       = module.postgres_db.db_secret_id
}
