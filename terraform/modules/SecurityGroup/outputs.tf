output "SECURITY_GROUP" {
  value       = "${aws_security_group.security_group}"
  description = "security group"
}
output "SECURITY_GROUP_ID" {
  value       = "${aws_security_group.security_group.id}"
  description = "security group id"
}
output "SECURITY_GROUP_NAME" {
  value       = "${aws_security_group.security_group.name}"
  description = "security group name"
}
