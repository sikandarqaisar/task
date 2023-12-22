resource "aws_security_group" "security_group" {
  name = "${var.SG_NAME}"
  vpc_id = "${var.VPC_ID}"
  description = var.SG_DESCRIPTION
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  dynamic "ingress" {
    for_each = var.SG_INGRESS
    content {
      from_port = lookup(ingress.value, "sg_ingress_from_port", null)
      description = lookup(ingress.value, "sg_ingress_description", null)
      to_port   = lookup(ingress.value, "sg_ingress_to_port", null)
      protocol = lookup(ingress.value, "sg_ingress_protocol", null)
      self = lookup(ingress.value, "sg_ingress_self", null)
      cidr_blocks = lookup(ingress.value, "sg_ingress_cidr_blocks", null)
      security_groups = lookup(ingress.value, "sg_ingress_security_groups", null)
      prefix_list_ids = lookup(ingress.value, "prefix_list_ids", null)
      ipv6_cidr_blocks = lookup(ingress.value, "ipv6_cidr_blocks", null)
    }
  }
  tags = merge(
    var.COMMON_TAGS,
    var.TAGS,    
    {
      Name = var.SG_NAME
    },
  )
}
