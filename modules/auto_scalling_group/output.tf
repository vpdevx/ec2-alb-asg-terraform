output "asg_name" {
  value = aws_autoscaling_group.this.name
}

output "asg_id" {
  value = aws_autoscaling_group.this.id
}

output "asg_arn" {
  value = aws_autoscaling_group.this.arn
}

output "asg_policies" {
  value = aws_autoscaling_policy.this[*].name
}

// ID of the policy
output "asg_policy_arn" {
  value = aws_autoscaling_policy.this[*].arn
}