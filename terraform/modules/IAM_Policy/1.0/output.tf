
output "IAM_POLICY" {
  description = "iam policy"
  value       = "${aws_iam_policy.this}"
}
output "IAM_POLICY_ARN" {
  description = "iam policy arn"
  value       = "${aws_iam_policy.this.arn}"
}
output "IAM_POLICY_NAME" {
  description = "iam policy name"
  value       = "${aws_iam_policy.this.name}"
}
