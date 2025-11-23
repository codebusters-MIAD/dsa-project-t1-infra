
# PASSWORD GENERATION - Genera contraseña aleatoria segura
resource "random_password" "master_password" {
  length  = 32
  special = true
  # Caracteres especiales seguros para PostgreSQL
  override_special = "!#$%&*()-_=+[]{}<>:?"
}


# RDS INSTANCE - PostgreSQL en subnets privadas
resource "aws_db_instance" "this" {
  # Identificación
  identifier = var.db_identifier
  
  # Motor de base de datos
  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class
  
  # Almacenamiento
  allocated_storage = var.allocated_storage
  storage_type      = "gp3"
  storage_encrypted = true
  
  # Credenciales
  db_name  = var.database_name
  username = var.master_username
  password = random_password.master_password.result
  
  # Networking - PRIVADA según arquitectura del .md
  publicly_accessible    = var.publicly_accessible  # DEBE SER false
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = concat(
    [aws_security_group.postgres.id],
    var.vpc_security_group_ids
  )
  
  # Alta disponibilidad
  multi_az = var.multi_az  # Recomendado true en producción
  
  # Protección y snapshots
  skip_final_snapshot = var.skip_final_snapshot
  deletion_protection = var.deletion_protection
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.db_identifier}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  
  # Backup y mantenimiento
  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window
  
  # Monitoreo
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  performance_insights_enabled    = false  # Cambiar a true si se necesita
  
  # Auto minor version upgrade
  auto_minor_version_upgrade = true
  
  # Parámetros adicionales para optimización
  parameter_group_name = "default.postgres${split(".", var.engine_version)[0]}"
  
  tags = merge(
    var.tags,
    {
      Name        = var.db_identifier
      Environment = lookup(var.tags, "Environment", "production")
      ManagedBy   = "terraform"
    }
  )
  
  # Lifecycle para evitar reemplazos innecesarios
  lifecycle {
    ignore_changes = [
      final_snapshot_identifier,
      password  # Evitar cambios de contraseña accidentales
    ]
  }
}
