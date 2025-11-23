# Data source: Validate Internet Gateway exists
data "aws_internet_gateway" "main" {
  filter {
    name   = "attachment.vpc-id"
    values = [var.vpc_id]
  }

  filter {
    name   = var.internet_gateway_id != "" ? "internet-gateway-id" : "attachment.state"
    values = var.internet_gateway_id != "" ? [var.internet_gateway_id] : ["available"]
  }
}

# Data source: Get VPC information
data "aws_vpc" "main" {
  id = var.vpc_id
}
