output "APPLICATION_LOAD_BALANCER" {
  description = "Application load balancer outputs"
  value       = aws_lb.alb_this 
}
output "APPLICATION_LOAD_BALANCER_ARN" {
  description = "Application load balancer arn outputs"
  value       = aws_lb.alb_this.arn
}

output "APPLICATION_LOAD_BALANCER_ZONE_ID" {
  description = "Application load balancer ZoneID"
  value       = aws_lb.alb_this.zone_id 
}

output "APPLICATION_LOAD_BALANCER_DNS_NAME" {
  description = "Application load balancer DNS Name"
  value       = aws_lb.alb_this.dns_name 
}

output "ALB_TARGET_GROUPS" {
  description = "Application load balancer Target Groups outputs"
  value       = length(var.ALB_TARGET_GROUPS) > 0 ? aws_lb_target_group.alb_target_groups.* : null
}

output "ALB_TARGET_GROUPS_ARN" {
  description = "Application load balancer Target Groups outputs"
  value       = length(var.ALB_TARGET_GROUPS) > 0 ? aws_lb_target_group.alb_target_groups.*.arn : null
}