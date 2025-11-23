# DATABASE INSTANCE OUTPUTS
output "db_instance_endpoint" {
  description = "Database endpoint (formato: hostname:port)"
  value       = aws_db_instance.this.endpoint
}

output "db_instance_address" {
  description = "Database hostname (sin puerto)"
  value       = aws_db_instance.this.address
}

output "db_instance_port" {
  description = "Database port"
  value       = aws_db_instance.this.port
}

output "db_instance_arn" {
  description = "ARN de la instancia RDS"
  value       = aws_db_instance.this.arn
}

output "db_instance_id" {
  description = "Database instance ID"
  value       = aws_db_instance.this.id
}

output "db_instance_resource_id" {
  description = "Resource ID de la instancia RDS"
  value       = aws_db_instance.this.resource_id
}


# DATABASE CONFIGURATION OUTPUTS
output "db_instance_name" {
  description = "Nombre de la base de datos"
  value       = aws_db_instance.this.db_name
}

output "db_master_username" {
  description = "Master username"
  value       = aws_db_instance.this.username
  sensitive   = true
}

output "db_master_password" {
  description = "Master password (almacenar en Secrets Manager)"
  value       = random_password.master_password.result
  sensitive   = true
}


# CONNECTION STRING OUTPUTS
output "db_connection_string" {
  description = "Connection string completa para PostgreSQL (sin contraseña)"
  value       = "postgresql://${aws_db_instance.this.username}:PASSWORD@${aws_db_instance.this.address}:${aws_db_instance.this.port}/${aws_db_instance.this.db_name}"
  sensitive   = true
}


# SECURITY OUTPUTS
output "db_security_group_id" {
  description = "ID del Security Group de la RDS (para permitir acceso desde ECS)"
  value       = aws_security_group.postgres.id
}

output "db_security_group_arn" {
  description = "ARN del Security Group de la RDS"
  value       = aws_security_group.postgres.arn
}

output "db_subnet_group_name" {
  description = "Nombre del DB Subnet Group"
  value       = aws_db_subnet_group.this.name
}

output "db_subnet_group_arn" {
  description = "ARN del DB Subnet Group"
  value       = aws_db_subnet_group.this.arn
}


# SECRETS MANAGER OUTPUTS
output "db_secret_arn" {
  description = "ARN del secret en AWS Secrets Manager con las credenciales de la base de datos"
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "db_secret_name" {
  description = "Nombre del secret en AWS Secrets Manager"
  value       = aws_secretsmanager_secret.db_credentials.name
}

output "db_secret_id" {
  description = "ID del secret en AWS Secrets Manager"
  value       = aws_secretsmanager_secret.db_credentials.id
}
