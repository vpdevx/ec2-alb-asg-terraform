resource "aws_launch_template" "this" {
  name  = var.lt_name_prefix != "" ? "${var.lt_name_prefix}-${var.lt_name}" : var.lt_name
  image_id      = var.lt_image_id
  instance_type = var.lt_instance_type
  key_name      = var.lt_key_name
  user_data     = var.lt_user_data

  network_interfaces {
    associate_public_ip_address = var.lt_public_ip_enabled
    security_groups = var.lt_security_groups
  }

  tags = var.lt_tags
}

resource "aws_autoscaling_group" "this" {
  name                 = var.asg_prefix_name != "" ? "${var.asg_prefix_name}-${var.asg_name}" : var.asg_name
  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }
  min_size             = var.asg_min_size
  max_size             = var.asg_max_size
  desired_capacity     = var.asg_desired_capacity
  vpc_zone_identifier  = var.asg_subnets
  target_group_arns    = var.asg_target_group_arn
//  health_check_type    = var.asg_health_check_type
//  health_check_grace_period = var.asg_health_check_grace_period
//  termination_policies = var.asg_termination_policies
  dynamic "tag" {
    for_each = var.asg_tags
    content {
      key                 = tag.value.key
      propagate_at_launch = tag.value.propagate_at_launch
      value               = tag.value.value
    }
  }
}

resource "aws_autoscaling_policy" "this" {
  count                  = length(var.asg_policies)
  name                   = var.asg_policies[count.index].name
  autoscaling_group_name = aws_autoscaling_group.this.name
  adjustment_type        = var.asg_policies[count.index].adjustment_type
  scaling_adjustment     = var.asg_policies[count.index].scaling_adjustment
  cooldown               = var.asg_policies[count.index].cooldown
}

