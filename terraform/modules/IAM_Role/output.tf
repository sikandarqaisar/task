
output "IAM_ROLE" {
  description = "iam role"
  value       = aws_iam_role.this
}
output "IAM_ROLE_ARN" {
  description = "iam role arn"
  value       = aws_iam_role.this.arn
}

output "IAM_ROLE_NAME" {
  description = "iam role"
  value       = aws_iam_role.this.name
}
output "IAM_INSTANCE_PROFILE" {
  description = "iam instance profile"
  value       = aws_iam_instance_profile.this
}

output "IAM_INSTANCE_PROFILE_ARN" {
  description = "iam instance profile arn"
  value       = aws_iam_instance_profile.this.*.arn
}

output "IAM_INSTANCE_PROFILE_NAME" {
  description = "iam instance profile name"
  value       = aws_iam_instance_profile.this.*.name
}