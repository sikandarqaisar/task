output "LAUNCH_TEMPLATE" {
  description = "launch template outputs"
  value       = aws_launch_template.launch_template
}
output "LAUNCH_TEMPLATE_ARN" {
  description = "launch template outputs"
  value       = aws_launch_template.launch_template.arn
}
output "LAUNCH_TEMPLATE_ID" {
  description = "launch template outputs"
  value       = aws_launch_template.launch_template.id
}

output "AUTOSCALING_GROUP" {
  description = "autoscaling group outputs"
  value       = aws_autoscaling_group.autoscaling_group
}

output "AUTOSCALING_GROUP_NAME" {
  description = "autoscaling group outputs"
  value       = aws_autoscaling_group.autoscaling_group.name
}

output "AUTOSCALING_GROUP_ARN" {
  description = "autoscaling group outputs"
  value       = aws_autoscaling_group.autoscaling_group.arn
}