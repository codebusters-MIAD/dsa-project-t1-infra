variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for ECS tasks"
  type        = list(string)
}

variable "services" {
  description = "List of ECS services to create"
  type = list(object({
    name                  = string
    image                 = string
    cpu                   = string
    memory                = string
    container_port        = number
    desired_count         = number
    execution_role_arn    = string
    task_role_arn         = string
    security_group_id     = string
    target_group_arn      = string
    command               = optional(list(string))
    cpu_architecture      = optional(string, "X86_64")
    environment_variables = list(object({
      name  = string
      value = string
    }))
    secrets = list(object({
      name      = string
      valueFrom = string
    }))
    health_check = optional(object({
      command     = list(string)
      interval    = number
      timeout     = number
      retries     = number
      startPeriod = number
    }))
  }))
}

variable "enable_container_insights" {
  description = "Enable Container Insights for the ECS cluster"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch Logs retention in days"
  type        = number
  default     = 7
}

variable "alb_listener_arn" {
  description = "ARN of the ALB listener (optional - for depends_on when using ALB)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags to apply to ECS resources"
  type        = map(string)
  default     = {}
}
