# PROJECT CONFIGURATION
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "MIAD"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "development"
  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "Environment must be one of: development, staging, production."
  }
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}


# NETWORKING - Variables REQUERIDAS para RDS privada
variable "vpc_id" {
  description = "VPC ID donde se desplegará la RDS (debe ser la misma VPC donde están los servicios ECS)"
  type        = string
}

variable "db_subnet_ids" {
  description = "IDs de las subnets PRIVADAS para RDS (mínimo 2 en diferentes AZs). Ejemplo: ['subnet-abc123', 'subnet-def456']"
  type        = list(string)
  validation {
    condition     = length(var.db_subnet_ids) >= 2
    error_message = "Se requieren al menos 2 subnets en diferentes Availability Zones para RDS."
  }
}


# SECURITY - Control de acceso a la base de datos
variable "allowed_security_group_ids" {
  description = "Lista de Security Group IDs permitidos para acceder a RDS (ej: SG de ECS API y Query-API). Se debe actualizar después de crear los servicios ECS."
  type        = list(string)
  default     = []
}

variable "allowed_cidr_blocks" {
  description = "Lista de CIDR blocks permitidos para acceder a RDS (ej: VPN, Bastion). Dejar vacío para máxima seguridad. Solo usar si necesitas acceso desde fuera de ECS."
  type        = list(string)
  default     = []
}


# DATABASE CONFIGURATION
variable "db_identifier" {
  description = "Database identifier"
  type        = string
  default     = "filmlens-postgres"
}

variable "database_name" {
  description = "Name of the database"
  type        = string
  default     = "filmlens"
}

variable "instance_class" {
  description = "RDS instance class (db.t3.micro para dev, db.t3.small+ para prod)"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}
