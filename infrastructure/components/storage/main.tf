module "postgres_db" {
  source = "../../shared/rds"

  db_identifier       = var.db_identifier
  database_name       = var.database_name
  instance_class      = var.instance_class
  allocated_storage   = var.allocated_storage
  
  publicly_accessible = true
  skip_final_snapshot = true
  deletion_protection = false
  
  backup_retention_period = 7
  
  tags = merge(
    local.common_tags,
    {
      Name    = var.db_identifier
      Purpose = "PostgreSQL Predictions Database"
    }
  )
}
