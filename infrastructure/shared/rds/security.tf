# DB Subnet Group - Usa subnets privadas proporcionadas por el usuario
resource "aws_db_subnet_group" "this" {
  name       = "${var.db_identifier}-subnet-group"
  subnet_ids = var.db_subnet_ids

  tags = merge(
    var.tags,
    {
      Name = "${var.db_identifier}-subnet-group"
    }
  )
}

# Security Group para RDS - Solo permite tráfico desde fuentes específicas
resource "aws_security_group" "postgres" {
  name        = "${var.db_identifier}-sg"
  description = "Security group for PostgreSQL RDS instance - Private access only"
  vpc_id      = var.vpc_id

  # Regla dinámica: permite tráfico desde Security Groups específicos (ECS, etc)
  dynamic "ingress" {
    for_each = var.allowed_security_group_ids
    content {
      from_port       = 5432
      to_port         = 5432
      protocol        = "tcp"
      security_groups = [ingress.value]
      description     = "PostgreSQL access from ${ingress.value}"
    }
  }

  # Regla opcional: permite tráfico desde CIDRs específicos (VPN, bastion, etc)
  dynamic "ingress" {
    for_each = length(var.allowed_cidr_blocks) > 0 ? [1] : []
    content {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = var.allowed_cidr_blocks
      description = "PostgreSQL access from specific CIDR blocks"
    }
  }

  # Egress: No es necesario para RDS (solo responde a conexiones entrantes)
  # Pero se deja abierto para actualizaciones de patches si es necesario
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow outbound for patches and updates"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.db_identifier}-sg"
    }
  )
}
