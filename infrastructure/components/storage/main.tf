module "postgres_db" {
  source = "../../shared/rds"

  db_identifier = var.db_identifier
  database_name = var.database_name
  

  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  

  vpc_id         = var.vpc_id
  db_subnet_ids  = var.db_subnet_ids
  
  allowed_security_group_ids = var.allowed_security_group_ids
  allowed_cidr_blocks        = var.allowed_cidr_blocks
  
  publicly_accessible = true  
  skip_final_snapshot = var.environment != "production" ? true : false
  deletion_protection = var.environment == "production" ? true : false
  multi_az            = var.environment == "production" ? true : false
  
  # Backup
  backup_retention_period = 7
  
  tags = merge(
    local.common_tags,
    {
      Name        = var.db_identifier
      Purpose     = "FilmLens PostgreSQL Database"
      Description = "Base de datos privada para servicios API y Query-API"
    }
  )
}
