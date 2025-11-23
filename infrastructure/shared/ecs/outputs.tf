output "cluster_id" {
  description = "ID of the ECS cluster"
  value       = aws_ecs_cluster.this.id
}

output "cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.this.arn
}

output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.this.name
}

output "service_names" {
  description = "Map of service names to ECS service names"
  value       = { for k, v in aws_ecs_service.this : k => v.name }
}

output "task_definition_arns" {
  description = "Map of service names to task definition ARNs"
  value       = { for k, v in aws_ecs_task_definition.this : k => v.arn }
}

output "log_group_names" {
  description = "Map of service names to CloudWatch Log Group names"
  value       = { for k, v in aws_cloudwatch_log_group.this : k => v.name }
}
