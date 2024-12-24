variable "lb_name" {
  description = "The name of the load balancer"
  type        = string
  default    = "asg-lb"
}

variable "is_lb_internal" {
  description = "Boolean flag to determine if the load balancer is internal or external"
  type        = bool
  default    = false
}

variable "lb_security_groups" {
  description = "The security groups to attach to the load balancer"
  type        = list(string)
  default    = []
}

variable "lb_subnets" {
  description = "The subnets to attach to the load balancer"
  type        = list(string)
  default    = []
}

variable "lb_tg_name" {
  description = "The name of the target group"
  type        = string
  default    = "alb-tg"
}

variable "lb_tg_port" {
  description = "The port the target group will listen on"
  type        = number
  default    = 80
}

variable "lb_tg_protocol" {
  description = "The protocol the target group will listen on"
  type        = string
  default    = "HTTP"
}

variable "lb_tg_vpc_id" {
  description = "The VPC ID to attach the target group to"
  type        = string
}

variable "lb_tg_target_type" {
  description = "The type of target that the target group will use"
  type        = string
  default    = "instance"
}

variable "lb_listener_port" {
  description = "The port the listener will listen on"
  type        = number
  default    = 80
}

variable "lb_listener_protocol" {
  description = "The protocol the listener will listen on"
  type        = string
  default    = "HTTP"
}

variable "lb_listener_default_action_type" {
  description = "The default action type for the listener"
  type        = string
  default    = "forward"
}

