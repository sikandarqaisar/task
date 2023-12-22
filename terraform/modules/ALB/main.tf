###########################
# Application Load Balancer
###########################
resource "aws_lb" "alb_this" {
  name                             = var.ALB_NAME
  load_balancer_type               = "application"
  internal                         = false
  security_groups                  = var.ALB_SECURITY_GROUP_IDS
  subnets                          = var.ALB_SUBNET_IDS

  dynamic "subnet_mapping" {
    for_each = var.ALB_SUBNET_MAPPING

    content {
      subnet_id     = subnet_mapping.value.subnet_id
      allocation_id = lookup(subnet_mapping.value, "allocation_id", null)
    }
  }

  tags = merge(
    var.COMMON_TAGS,
    var.TAGS,
    {
      Name = var.ALB_NAME != null ? var.ALB_NAME : "Application-LoadBalancer"
    },
  )
}


resource "aws_lb_target_group" "alb_target_groups" {
  count = length(var.ALB_TARGET_GROUPS) > 0 ? length(var.ALB_TARGET_GROUPS) : 0

  name = lookup(var.ALB_TARGET_GROUPS[count.index], "name", null)

  vpc_id      = var.ALB_VPC_ID
  port        = lookup(var.ALB_TARGET_GROUPS[count.index], "backend_port", null)
  protocol    = lookup(var.ALB_TARGET_GROUPS[count.index], "backend_protocol", null) != null ? upper(lookup(var.ALB_TARGET_GROUPS[count.index], "backend_protocol")) : null
  target_type = lookup(var.ALB_TARGET_GROUPS[count.index], "target_type", "instance")

  deregistration_delay               = lookup(var.ALB_TARGET_GROUPS[count.index], "deregistration_delay", null)
  slow_start                         = lookup(var.ALB_TARGET_GROUPS[count.index], "slow_start", null)
  proxy_protocol_v2                  = lookup(var.ALB_TARGET_GROUPS[count.index], "proxy_protocol_v2", false)
  lambda_multi_value_headers_enabled = lookup(var.ALB_TARGET_GROUPS[count.index], "lambda_multi_value_headers_enabled", false)
  load_balancing_algorithm_type      = lookup(var.ALB_TARGET_GROUPS[count.index], "load_balancing_algorithm_type", null)

  dynamic "health_check" {
    for_each = length(keys(lookup(var.ALB_TARGET_GROUPS[count.index], "health_check", {}))) == 0 ? [] : [lookup(var.ALB_TARGET_GROUPS[count.index], "health_check", {})]

    content {
      enabled             = lookup(health_check.value, "enabled", null)
      interval            = lookup(health_check.value, "interval", null)
      path                = lookup(health_check.value, "path", null)
      port                = lookup(health_check.value, "port", "traffic-port")
      healthy_threshold   = lookup(health_check.value, "healthy_threshold", null)
      unhealthy_threshold = lookup(health_check.value, "unhealthy_threshold", null)
      timeout             = lookup(health_check.value, "timeout", null)
      protocol            = lookup(health_check.value, "protocol", null)
      matcher             = lookup(health_check.value, "matcher", null)
    }
  }

  dynamic "stickiness" {
    for_each = length(keys(lookup(var.ALB_TARGET_GROUPS[count.index], "stickiness", {}))) == 0 ? [] : [lookup(var.ALB_TARGET_GROUPS[count.index], "stickiness", {})]

    content {
      enabled         = lookup(stickiness.value, "enabled", null)
      cookie_duration = lookup(stickiness.value, "cookie_duration", null)
      type            = lookup(stickiness.value, "type", null)
    }
  }

  tags = merge(
    var.COMMON_TAGS,
    var.TAGS,
    lookup(var.ALB_TARGET_GROUPS[count.index], "tags", {}),
    {
      "Name" = lookup(var.ALB_TARGET_GROUPS[count.index], "name", lookup(var.ALB_TARGET_GROUPS[count.index], "name_prefix", ""))
    },
  )

  depends_on = [aws_lb.alb_this]

}


resource "aws_lb_listener" "alb_listener_frontend_http_tcp" {
  count = length(var.ALB_HTTP_TCP_LISTENERS)

  load_balancer_arn = aws_lb.alb_this.arn

  port     = var.ALB_HTTP_TCP_LISTENERS[count.index]["port"]
  protocol = var.ALB_HTTP_TCP_LISTENERS[count.index]["protocol"]

  default_action {
    type = "forward"
    forward {
      target_group {
        arn = aws_lb_target_group.alb_target_groups[0].id
        weight = 1
      }

      target_group {
        arn = aws_lb_target_group.alb_target_groups[1].id
        weight = 4
      }

      stickiness {
        enabled  = true
        duration = 1
      }
    }
  }
}
