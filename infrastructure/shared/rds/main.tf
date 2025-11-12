resource "random_password" "master_password" {
  length  = 16
  special = false
}

resource "aws_db_instance" "this" {
  identifier             = var.db_identifier
  engine                 = "postgres"
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  allocated_storage      = var.allocated_storage
  storage_type           = "gp3"
  storage_encrypted      = true
  
  db_name  = var.database_name
  username = var.master_username
  password = random_password.master_password.result
  
  publicly_accessible    = var.publicly_accessible
  skip_final_snapshot    = var.skip_final_snapshot
  deletion_protection    = var.deletion_protection
  
  db_subnet_group_name   = aws_db_subnet_group.this.name
  
  backup_retention_period = var.backup_retention_period
  backup_window          = var.backup_window
  maintenance_window     = var.maintenance_window
  
  vpc_security_group_ids = length(var.vpc_security_group_ids) > 0 ? var.vpc_security_group_ids : [aws_security_group.postgres.id]
  
  performance_insights_enabled = false
  
  tags = var.tags
}
