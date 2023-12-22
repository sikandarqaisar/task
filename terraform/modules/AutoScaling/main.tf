resource "aws_launch_template" "launch_template" {
  name = var.TEMPLATE_NAME
  description = "LaunchTemplate for a applications"
  image_id = var.IMAGE_ID
  instance_type = var.INSTANCE_TYPE
  iam_instance_profile {
    name = var.ASG_IAM_INSTANCE_PROFILE_NAME
  }

  vpc_security_group_ids = var.ASG_SECURITY_GROUP_IDS
  user_data = filebase64("${path.module}/app1-install.sh")
  ebs_optimized = var.EBS_OPTIMIZED
  update_default_version = true

    dynamic "block_device_mappings" {
            for_each = var.ASG_EBS_BLOCK_DEVICE
            content {

        device_name  = lookup(block_device_mappings.value, "device_name", null)
        no_device    = lookup(block_device_mappings.value, "no_device", false)
        virtual_name = lookup(block_device_mappings.value, "virtual_name", "")
        dynamic "ebs" {
            for_each = [block_device_mappings.value["ebs"]]
            content {
            delete_on_termination = lookup(ebs.value, "delete_on_termination", true)
            encrypted             = true
            iops                  = lookup(ebs.value, "iops", null)
            kms_key_id            = lookup(ebs.value, "kms_key_id", "")
            snapshot_id           = lookup(ebs.value, "snapshot_id", null)
            volume_size           = lookup(ebs.value, "volume_size", 30)
            volume_type           = lookup(ebs.value, "volume_type", "gp2")
            }
        }
        }
    }
  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(
      {
        "Name" = format("%s%s", var.TEMPLATE_NAME, "-Volume")
      },
      var.COMMON_TAGS,
      var.TAGS,
    )
  }
  tag_specifications {
    resource_type = "instance"
    tags = merge(
      {
        "Name" = format("%s%s", var.TEMPLATE_NAME, "-Instance")
      },
      var.COMMON_TAGS,
      var.TAGS,
    )
  }
  tags = merge(
    {
        "Name" = format("%s", var.TEMPLATE_NAME)
    },
     var.COMMON_TAGS,
     var.TAGS,
  )
}


# Autoscaling Group Resource
resource "aws_autoscaling_group" "autoscaling_group" {
  name_prefix = var.ASG_NAME
  desired_capacity   = var.ASG_DESIRED_CAPACITY
  max_size           = var.ASG_MAX_SIZE
  min_size           = var.ASG_MIN_SIZE
  vpc_zone_identifier  = var.ASG_SUBNET_IDS
  target_group_arns = var.ASG_TARGET_GROUP_ARNS
  health_check_type = "EC2"
  launch_template {
    id      = aws_launch_template.launch_template.id
    version = aws_launch_template.launch_template.latest_version
  }
   dynamic "tag" {
    for_each = var.COMMON_TAGS
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = false
    }
  }
  
  dynamic "tag" {
      for_each = var.INSTANCE_TAGS
      content {
      key               = tag.key
      value             = tag.value
      propagate_at_launch = true
      }
  }
}
