# IAM Role
resource "aws_iam_role" "this" {
  name               = "${var.project_name}-${var.role_name}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.role_name}"
      Type = var.role_type
    }
  )
}

# Assume Role Policy for ECS Tasks
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# Attach AWS managed policy for ECS Task Execution (for execution roles)
resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  count = var.role_type == "execution" ? 1 : 0

  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Custom inline policies
resource "aws_iam_role_policy" "custom" {
  for_each = { for idx, policy in var.custom_policies : policy.name => policy }

  name   = each.value.name
  role   = aws_iam_role.this.id
  policy = each.value.policy
}

# Attach additional managed policy ARNs
resource "aws_iam_role_policy_attachment" "additional" {
  for_each = toset(var.additional_policy_arns)

  role       = aws_iam_role.this.name
  policy_arn = each.value
}
