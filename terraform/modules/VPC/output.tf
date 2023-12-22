output "VPC" {
  description = "The complete output of VPC"
  value       = "${aws_vpc.this}"
}
output "VPC_ID" {
  description = "The ID of the VPC"
  value       = "${aws_vpc.this.id}"
}
output "VPC_CIDR" {
  description = "The cidr of the VPC"
  value       = "${aws_vpc.this.cidr_block}"
}
output "PUBLIC_SUBNETS" {
  description = "complete output of public subnets"
  value       = "${aws_subnet.public.*}"
}
output "PUBLIC_SUBNET_IDS" {
  description = "List of IDs of public subnets"
  value       = "${aws_subnet.public.*.id}"
}
output "PUBLIC_SUBNETS_CIDR" {
  description = "List of cidr of public subnets"
  value       = "${aws_subnet.public.*.cidr_block}"
}

output "PRIVATE_SUBNETS" {
  description = "complete output of private subnets"
  value       = "${aws_subnet.private.*}"
}
output "PRIVATE_SUBNET_IDS" {
  description = "List of IDs of private subnets"
  value       = "${aws_subnet.private.*.id}"
}
output "PRIVATE_SUBNETS_CIDR" {
  description = "List of cidr of private subnets"
  value       = "${aws_subnet.private.*.cidr_block}"
}

output "PRIVATE_SUBNETS_WITHOUT_NG" {
  description = "complete output of private subnets without natgateway"
  value       = "${aws_subnet.private_without_nat_gateway.*}"
}
output "PRIVATE_SUBNETS_WITHOUT_NG_IDS" {
  description = "List of IDs of private subnets without natgateway"
  value       = "${aws_subnet.private_without_nat_gateway.*.id}"
}
output "PRIVATE_SUBNETS_WITHOUT_NG_CIDR" {
  description = "List of cidr of private subnets without natgateway"
  value       = "${aws_subnet.private_without_nat_gateway.*.cidr_block}"
}
