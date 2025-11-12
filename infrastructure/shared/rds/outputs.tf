output "db_instance_endpoint" {
  description = "Database endpoint"
  value       = aws_db_instance.this.endpoint
}

output "db_instance_address" {
  description = "Database address"
  value       = aws_db_instance.this.address
}

output "db_instance_port" {
  description = "Database port"
  value       = aws_db_instance.this.port
}

output "db_instance_name" {
  description = "Database name"
  value       = aws_db_instance.this.db_name
}

output "db_master_username" {
  description = "Master username"
  value       = aws_db_instance.this.username
  sensitive   = true
}

output "db_master_password" {
  description = "Master password"
  value       = random_password.master_password.result
  sensitive   = true
}

output "db_instance_id" {
  description = "Database instance ID"
  value       = aws_db_instance.this.id
}
