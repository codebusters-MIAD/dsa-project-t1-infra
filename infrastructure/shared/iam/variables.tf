variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "role_name" {
  description = "Name for the IAM role (will be prefixed with project_name)"
  type        = string
}

variable "role_type" {
  description = "Type of role: 'execution' for ECS Task Execution Role, 'task' for ECS Task Role"
  type        = string
  validation {
    condition     = contains(["execution", "task"], var.role_type)
    error_message = "role_type must be either 'execution' or 'task'"
  }
}

variable "custom_policies" {
  description = "List of custom inline policies to attach to the role"
  type = list(object({
    name   = string
    policy = string
  }))
  default = []
}

variable "additional_policy_arns" {
  description = "List of additional managed policy ARNs to attach"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags to apply to the IAM role"
  type        = map(string)
  default     = {}
}
