# NETWORKING - Variables requeridas para arquitectura privada
variable "vpc_id" {
  description = "VPC ID donde se desplegará la RDS (debe ser la misma VPC donde están los servicios ECS)"
  type        = string
}

variable "db_subnet_ids" {
  description = "IDs de las subnets PRIVADAS donde se desplegará la RDS (mínimo 2 en diferentes AZs)"
  type        = list(string)
  validation {
    condition     = length(var.db_subnet_ids) >= 2
    error_message = "Se requieren al menos 2 subnets en diferentes Availability Zones para RDS."
  }
}


# SECURITY - Control de acceso a la base de datos
variable "allowed_security_group_ids" {
  description = "Lista de Security Group IDs permitidos para acceder a RDS (ej: SG de ECS API y Query-API)"
  type        = list(string)
  default     = []
}

variable "allowed_cidr_blocks" {
  description = "Lista de CIDR blocks permitidos para acceder a RDS (ej: VPN, Bastion). Dejar vacío para máxima seguridad."
  type        = list(string)
  default     = []
}

variable "vpc_security_group_ids" {
  description = "Lista opcional de Security Group IDs adicionales para asociar a la RDS"
  type        = list(string)
  default     = []
}


# DATABASE CONFIGURATION
variable "db_identifier" {
  description = "Database identifier"
  type        = string
}

variable "engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "15.7"
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "database_name" {
  description = "Name of the database to create"
  type        = string
}

variable "master_username" {
  description = "Master username for the database"
  type        = string
  default     = "filmlens_user"  
}

variable "publicly_accessible" {
  description = "Whether the database is publicly accessible - DEBE SER FALSE para producción"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on deletion"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = true
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment for high availability"
  type        = bool
  default     = false
}


# BACKUP & MAINTENANCE
variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Backup window"
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "Maintenance window"
  type        = string
  default     = "mon:04:00-mon:05:00"
}


# TAGGING
variable "tags" {
  description = "Tags to apply to the database"
  type        = map(string)
  default     = {}
}
