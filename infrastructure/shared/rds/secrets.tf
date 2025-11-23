# Secret para almacenar las credenciales de la base de datos
resource "aws_secretsmanager_secret" "db_credentials" {
  name_prefix             = "${var.db_identifier}-credentials-"
  description             = "Credenciales de base de datos PostgreSQL para ${var.db_identifier}"
  recovery_window_in_days = 0  # 0 = borrado inmediato (útil para dev/testing)
  
  tags = merge(
    var.tags,
    {
      Name        = "${var.db_identifier}-credentials"
      ManagedBy   = "terraform"
      DatabaseId  = var.db_identifier
    }
  )
}

# Versión del secret con las credenciales en formato JSON
resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  
  secret_string = jsonencode({
    username            = aws_db_instance.this.username
    password            = random_password.master_password.result
    engine              = "postgres"
    host                = aws_db_instance.this.address
    port                = aws_db_instance.this.port
    dbname              = aws_db_instance.this.db_name
    dbInstanceIdentifier = aws_db_instance.this.identifier
    # Connection strings útiles
    connectionString    = "postgresql://${aws_db_instance.this.username}:${random_password.master_password.result}@${aws_db_instance.this.address}:${aws_db_instance.this.port}/${aws_db_instance.this.db_name}"
    jdbcUrl            = "jdbc:postgresql://${aws_db_instance.this.address}:${aws_db_instance.this.port}/${aws_db_instance.this.db_name}"
  })
  
  lifecycle {
    ignore_changes = [
      # Evitar updates innecesarios si el secret no cambia
      secret_string
    ]
  }
}
