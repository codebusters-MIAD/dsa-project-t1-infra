# SECURITY GROUPS

# Security Group: API Service (Direct Internet Access)
module "sg_api" {
  source = "../../shared/security-groups"

  project_name = var.project_name
  name         = "api"
  description  = "Security group for API service with direct internet access"
  vpc_id       = var.vpc_id

  ingress_rules = [
    {
      from_port   = 8000
      to_port     = 8000
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTP traffic from internet on port 8000"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTPS traffic from internet"
    }
  ]

  egress_rules = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = [data.aws_vpc.main.cidr_block]
      description = "Allow traffic to RDS PostgreSQL"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTPS outbound for AWS services"
    }
  ]

  tags = var.tags
}

# Security Group: Query API Service (Direct Internet Access)
module "sg_query_api" {
  source = "../../shared/security-groups"

  project_name = var.project_name
  name         = "query-api"
  description  = "Security group for Query API service with direct internet access"
  vpc_id       = var.vpc_id

  ingress_rules = [
    {
      from_port   = 8001
      to_port     = 8001
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTP traffic from internet on port 8001"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTPS traffic from internet"
    }
  ]

  egress_rules = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = [data.aws_vpc.main.cidr_block]
      description = "Allow traffic to RDS PostgreSQL"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTPS outbound for AWS services"
    }
  ]

  tags = var.tags
}


# IAM ROLES


# IAM Role: ECS Task Execution Role (para pull de imagenes ECR y Secrets Manager)
module "iam_execution_role" {
  source = "../../shared/iam"

  project_name = var.project_name
  role_name    = "ecs-execution-role"
  role_type    = "execution"

  custom_policies = [
    {
      name = "secrets-manager-access"
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "secretsmanager:GetSecretValue"
            ]
            Resource = var.db_secret_arn
          }
        ]
      })
    }
  ]

  tags = var.tags
}

# IAM Role: Task Role for API Service
module "iam_task_role_api" {
  source = "../../shared/iam"

  project_name = var.project_name
  role_name    = "ecs-task-role-api"
  role_type    = "task"

  custom_policies = [
    {
      name = "api-permissions"
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "secretsmanager:GetSecretValue"
            ]
            Resource = var.db_secret_arn
          }
        ]
      })
    }
  ]

  tags = var.tags
}

# IAM Role: Task Role for Query API Service
module "iam_task_role_query_api" {
  source = "../../shared/iam"

  project_name = var.project_name
  role_name    = "ecs-task-role-query-api"
  role_type    = "task"

  custom_policies = [
    {
      name = "query-api-permissions"
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "secretsmanager:GetSecretValue"
            ]
            Resource = var.db_secret_arn
          }
        ]
      })
    }
  ]

  tags = var.tags
}

# IAM Role: Task Role for MLflow Service
module "iam_task_role_mlflow" {
  source = "../../shared/iam"

  project_name = var.project_name
  role_name    = "ecs-task-role-mlflow"
  role_type    = "task"

  custom_policies = [
    {
      name = "mlflow-s3-and-secrets"
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "s3:PutObject",
              "s3:GetObject",
              "s3:DeleteObject",
              "s3:ListBucket"
            ]
            Resource = [
              "arn:aws:s3:::${var.mlflow_s3_artifact_bucket}",
              "arn:aws:s3:::${var.mlflow_s3_artifact_bucket}/*"
            ]
          },
          {
            Effect = "Allow"
            Action = [
              "secretsmanager:GetSecretValue"
            ]
            Resource = var.db_secret_arn
          }
        ]
      })
    }
  ]

  tags = var.tags
}

# Security Group: MLflow Service (Direct Internet Access)
module "sg_mlflow" {
  source = "../../shared/security-groups"

  project_name = var.project_name
  name         = "mlflow"
  description  = "Security group for MLflow tracking server with direct internet access"
  vpc_id       = var.vpc_id

  ingress_rules = [
    {
      from_port   = 5000
      to_port     = 5000
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTP traffic from internet on port 5000"
    }
  ]

  egress_rules = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = [data.aws_vpc.main.cidr_block]
      description = "Allow traffic to RDS PostgreSQL"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTPS to S3 and AWS services"
    }
  ]

  tags = var.tags
}


# ECS CLUSTER AND SERVICES (Direct Public IP Access - No ALB)
module "ecs" {
  source = "../../shared/ecs"

  project_name       = var.project_name
  aws_region         = var.aws_region
  private_subnet_ids = var.public_subnet_ids  # Using public subnets for direct internet access
  alb_listener_arn   = null                   # No ALB

  services = [
    {
      name               = "api"
      image              = var.api_image
      cpu                = "1024"
      memory             = "2048"
      container_port     = 8000
      desired_count      = 1
      execution_role_arn = module.iam_execution_role.role_arn
      task_role_arn      = module.iam_task_role_api.role_arn
      security_group_id  = module.sg_api.security_group_id
      target_group_arn   = null  # No target group
      command            = ["python", "-m", "uvicorn", "src.api.main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "2"]
      cpu_architecture   = "ARM64"

      environment_variables = [
        {
          name  = "AWS_USE_IAM_ROLE"
          value = "true"
        },
        {
          name  = "RDS_SECRET_MANAGER_ARN"
          value = var.db_secret_arn
        },
        {
          name  = "ENVIRONMENT"
          value = var.environment
        },
        {
          name  = "PYTHONPATH"
          value = "/app:/app/src"
        },
        {
          name  = "DEBUG"
          value = "true"
        },
        {
          name  = "LOG_LEVEL"
          value = "INFO"
        },
        {
          name  = "PORT"
          value = "8000"
        }
      ]

      secrets = []

      health_check = null
    },
    {
      name               = "query-api"
      image              = var.query_api_image
      cpu                = "512"
      memory             = "1024"
      container_port     = 8001
      desired_count      = 1
      execution_role_arn = module.iam_execution_role.role_arn
      task_role_arn      = module.iam_task_role_query_api.role_arn
      security_group_id  = module.sg_query_api.security_group_id
      target_group_arn   = null  # No target group
      cpu_architecture   = "ARM64"

      environment_variables = [
        {
          name  = "AWS_USE_IAM_ROLE"
          value = "true"
        },
        {
          name  = "RDS_SECRET_MANAGER_ARN"
          value = var.db_secret_arn
        },
        {
          name  = "ENVIRONMENT"
          value = var.environment
        },
        {
          name  = "PYTHONPATH"
          value = "/app:/app/src"
        },
        {
          name  = "DEBUG"
          value = "true"
        },
        {
          name  = "LOG_LEVEL"
          value = "INFO"
        },
        {
          name  = "PORT"
          value = "8001"
        }
      ]

      secrets = []

      health_check = null
    },
    {
      name               = "mlflow"
      image              = var.mlflow_image
      cpu                = "1024"
      memory             = "2048"
      container_port     = 5000
      desired_count      = 0
      execution_role_arn = module.iam_execution_role.role_arn
      task_role_arn      = module.iam_task_role_mlflow.role_arn
      security_group_id  = module.sg_mlflow.security_group_id
      target_group_arn   = null
      cpu_architecture   = "ARM64"
      command            = [
        "mlflow", "server",
        "--backend-store-uri", var.mlflow_backend_store_uri,
        "--default-artifact-root", "s3://${var.mlflow_s3_artifact_bucket}",
        "--serve-artifacts",
        "--artifacts-destination", "s3://${var.mlflow_s3_artifact_bucket}",
        "--host", "0.0.0.0",
        "--port", "5000"
      ]

      environment_variables = [
        {
          name  = "MLFLOW_BACKEND_STORE_URI"
          value = var.mlflow_backend_store_uri
        },
        {
          name  = "MLFLOW_DEFAULT_ARTIFACT_ROOT"
          value = "s3://${var.mlflow_s3_artifact_bucket}"
        },
        {
          name  = "AWS_DEFAULT_REGION"
          value = var.aws_region
        }
      ]

      secrets = []

      health_check = null
    }
  ]

  enable_container_insights = true
  log_retention_days        = 7
  tags                      = var.tags
}
