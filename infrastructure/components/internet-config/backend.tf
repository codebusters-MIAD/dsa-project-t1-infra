terraform {
  backend "s3" {
    bucket = "redpillconfig"
    key    = "terraform/terraform-internet-config.tfstate"
    region = "us-east-1"
  }
  
  required_version = ">= 1.11.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Component   = "internet-config"
    }
  }
}
