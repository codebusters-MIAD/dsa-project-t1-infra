# ECS Cluster
resource "aws_ecs_cluster" "this" {
  name = "${var.project_name}-cluster"

  setting {
    name  = "containerInsights"
    value = var.enable_container_insights ? "enabled" : "disabled"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-cluster"
    }
  )
}

# CloudWatch Log Group for ECS Tasks
resource "aws_cloudwatch_log_group" "this" {
  for_each = { for service in var.services : service.name => service }

  name              = "/ecs/${var.project_name}/${each.value.name}"
  retention_in_days = var.log_retention_days

  tags = merge(
    var.tags,
    {
      Name    = "/ecs/${var.project_name}/${each.value.name}"
      Service = each.value.name
    }
  )
}

# ECS Task Definitions
resource "aws_ecs_task_definition" "this" {
  for_each = { for service in var.services : service.name => service }

  family                   = "${var.project_name}-${each.value.name}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = each.value.cpu
  memory                   = each.value.memory
  execution_role_arn       = each.value.execution_role_arn
  task_role_arn            = each.value.task_role_arn

  container_definitions = jsonencode([
    {
      name      = each.value.name
      image     = each.value.image
      essential = true

      portMappings = [
        {
          containerPort = each.value.container_port
          protocol      = "tcp"
        }
      ]

      environment = each.value.environment_variables

      secrets = each.value.secrets

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.this[each.key].name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }

      healthCheck = try(each.value.health_check, null)
    }
  ])

  tags = merge(
    var.tags,
    {
      Name    = "${var.project_name}-${each.value.name}"
      Service = each.value.name
    }
  )
}

# ECS Services
resource "aws_ecs_service" "this" {
  for_each = { for service in var.services : service.name => service }

  name            = "${var.project_name}-${each.value.name}-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this[each.key].arn
  desired_count   = each.value.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [each.value.security_group_id]
    assign_public_ip = true  # Enable public IP for direct internet access
  }

  # Only add load_balancer block if target_group_arn is provided
  dynamic "load_balancer" {
    for_each = each.value.target_group_arn != null ? [1] : []
    content {
      target_group_arn = each.value.target_group_arn
      container_name   = each.value.name
      container_port   = each.value.container_port
    }
  }

  tags = merge(
    var.tags,
    {
      Name    = "${var.project_name}-${each.value.name}-service"
      Service = each.value.name
    }
  )
}
