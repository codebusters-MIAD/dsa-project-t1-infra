# Security Group Resource
resource "aws_security_group" "this" {
  name_prefix = "${var.project_name}-${var.name}-"
  description = var.description
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.name}"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Ingress Rules
resource "aws_security_group_rule" "ingress" {
  for_each = { for idx, rule in var.ingress_rules : idx => rule }

  type              = "ingress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  security_group_id = aws_security_group.this.id

  # Source can be CIDR blocks or another Security Group
  cidr_blocks              = try(each.value.cidr_blocks, null)
  source_security_group_id = try(each.value.source_security_group_id, null)

  description = try(each.value.description, "Managed by Terraform")
}

# Egress Rules
resource "aws_security_group_rule" "egress" {
  for_each = { for idx, rule in var.egress_rules : idx => rule }

  type              = "egress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  security_group_id = aws_security_group.this.id

  # Destination can be CIDR blocks or another Security Group
  cidr_blocks              = try(each.value.cidr_blocks, null)
  source_security_group_id = try(each.value.destination_security_group_id, null)

  description = try(each.value.description, "Managed by Terraform")
}
