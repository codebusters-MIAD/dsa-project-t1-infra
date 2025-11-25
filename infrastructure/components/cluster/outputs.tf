# ECS Outputs
output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs.cluster_name
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = module.ecs.cluster_arn
}

output "ecs_service_names" {
  description = "Map of ECS service names"
  value       = module.ecs.service_names
}

# Security Group Outputs
output "security_group_api_id" {
  description = "Security Group ID for API service"
  value       = module.sg_api.security_group_id
}

output "security_group_query_api_id" {
  description = "Security Group ID for Query API service"
  value       = module.sg_query_api.security_group_id
}

output "security_group_mlflow_id" {
  description = "Security Group ID for MLflow service"
  value       = module.sg_mlflow.security_group_id
}

# Instructions to get Public IPs
output "instructions_get_public_ips" {
  description = "Instructions to get the public IPs of the ECS tasks"
  value       = <<-EOT
    To get the public IP addresses of your ECS tasks, run:
    
    # For API service:
    aws ecs list-tasks --cluster ${module.ecs.cluster_name} --service-name ${module.ecs.service_names["api"]} --query 'taskArns[0]' --output text | xargs -I {} aws ecs describe-tasks --cluster ${module.ecs.cluster_name} --tasks {} --query 'tasks[0].attachments[0].details[?name==`networkInterfaceId`].value' --output text | xargs -I {} aws ec2 describe-network-interfaces --network-interface-ids {} --query 'NetworkInterfaces[0].Association.PublicIp' --output text
    
    # For Query API service:
    aws ecs list-tasks --cluster ${module.ecs.cluster_name} --service-name ${module.ecs.service_names["query-api"]} --query 'taskArns[0]' --output text | xargs -I {} aws ecs describe-tasks --cluster ${module.ecs.cluster_name} --tasks {} --query 'tasks[0].attachments[0].details[?name==`networkInterfaceId`].value' --output text | xargs -I {} aws ec2 describe-network-interfaces --network-interface-ids {} --query 'NetworkInterfaces[0].Association.PublicIp' --output text
    
    # For MLflow service:
    aws ecs list-tasks --cluster ${module.ecs.cluster_name} --service-name ${module.ecs.service_names["mlflow"]} --query 'taskArns[0]' --output text | xargs -I {} aws ecs describe-tasks --cluster ${module.ecs.cluster_name} --tasks {} --query 'tasks[0].attachments[0].details[?name==`networkInterfaceId`].value' --output text | xargs -I {} aws ec2 describe-network-interfaces --network-interface-ids {} --query 'NetworkInterfaces[0].Association.PublicIp' --output text
  EOT
}

# IAM Role Outputs
output "iam_execution_role_arn" {
  description = "ARN of the ECS Task Execution Role"
  value       = module.iam_execution_role.role_arn
}

output "iam_task_role_api_arn" {
  description = "ARN of the API Task Role"
  value       = module.iam_task_role_api.role_arn
}

output "iam_task_role_query_api_arn" {
  description = "ARN of the Query API Task Role"
  value       = module.iam_task_role_query_api.role_arn
}

output "iam_task_role_mlflow_arn" {
  description = "ARN of the MLflow Task Role"
  value       = module.iam_task_role_mlflow.role_arn
}
