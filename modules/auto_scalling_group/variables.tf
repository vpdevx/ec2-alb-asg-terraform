variable "lt_name_prefix" {
  description = "The prefix of the launch template name"
  type        = string
  default     = ""
}

variable "lt_name" {
  description = "The name of the launch template"
  type        = string
  default     = "lt-terraform"
}

variable "lt_image_id" {
  description = "The ID of the AMI to use for the launch template"
  type        = string
  default     = "ami-01816d07b1128cd2d"
}

variable "lt_instance_type" {
  description = "The instance type to use for the launch template"
  type        = string
  default     = "t3.micro"
}

variable "lt_key_name" {
  description = "The key name to use for the launch template"
  type        = string
}

variable "lt_user_data" {
  description = "The user data to use for the launch template"
  type        = string
  default     = filebase64("${path.module}/files/nginx-setup.sh")
}

variable "lt_public_ip_enabled" {
  description = "Whether to enable public IP for the launch template"
  type        = bool
  default     = false
}

variable "lt_security_groups" {
  description = "A list of security groups to attach to the launch template"
  type        = list(string)
  default     = []
}

variable "asg_min_size" {
  description = "The minimum size of the autoscaling group"
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "The maximum size of the autoscaling group"
  type        = number
  default     = 3
}

variable "asg_desired_capacity" {
  description = "The desired capacity of the autoscaling group"
  type        = number
  default     = 1
}

variable "asg_subnets" {
  description = "A list of subnets to attach the autoscaling group to"
  type        = list(string)
  default     = []
}

variable "asg_target_group_arn" {
  description = "The ARN of the target group to attach to the autoscaling group"
  type        = list(string)
}

variable "asg_policies" {
  description = "A list of policies to attach to the autoscaling group"
  type        = list(object({
    name              = string
    adjustment_type   = string
    scaling_adjustment = number
    cooldown          = number
    autoscalling_group_name = string
  }))
  default = [
        {
        name = "${var.asg_prefix_name}-${var.asg_name}-policy-scale-up"
        scaling_adjustment = 1
        adjustment_type = "ChangeInCapacity"
        cooldown = 300
        autoscaling_group_name = "${var.asg_prefix_name}-${var.asg_name}"
        },
        {
        name = "${var.asg_prefix_name}-${var.asg_name}-policy-scale-down"
        scaling_adjustment = -1
        adjustment_type = "ChangeInCapacity"
        cooldown = 300
        autoscaling_group_name = "${var.asg_prefix_name}-${var.asg_name}"
        }
    ]
}

variable "asg_name" {
  description = "The name of the autoscaling group"
  type        = string
  default     = "asg"
}

variable "asg_prefix_name" {
  description = "The prefix of the autoscaling group name"
  type        = string
}

variable "asg_tags" {
  description = "A map of tags to add to the autoscaling group"
  type        = list(object({
    key                = string
    value               = string
    propagate_at_launch = bool
  }))
  // default as foo bar
  default = [
    {
      key                 = "tag"
      value               = "test"
      propagate_at_launch = true
    }
  ]
}