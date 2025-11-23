# Data source: Get outputs from internet-config component (PASO 1)
data "terraform_remote_state" "internet_config" {
  backend = "s3"
  config = {
    bucket = "redpillconfig"
    key    = "terraform/terraform-internet-config.tfstate"
    region = "us-east-1"
  }
}

# Data source: VPC
data "aws_vpc" "main" {
  id = var.vpc_id
}

# Data source: Private subnets (for ECS tasks)
data "aws_subnet" "private" {
  for_each = toset(var.private_subnet_ids)
  id       = each.value
}

# Data source: Public subnets (for ALB)
data "aws_subnet" "public" {
  for_each = toset(var.public_subnet_ids)
  id       = each.value
}
