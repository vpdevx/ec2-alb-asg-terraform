resource "aws_lb" "this" {
  name               = var.lb_name
  internal           = var.is_lb_internal
  load_balancer_type = "application"
  security_groups    = var.lb_security_groups
  subnets            = var.lb_subnets
}

resource "aws_lb_target_group" "this" {
  name     = var.lb_tg_name
  port     = var.lb_tg_port
  protocol = var.lb_tg_protocol
  vpc_id   = var.lb_tg_vpc_id
  target_type = var.lb_tg_target_type
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.lb_listener_port
  protocol          = var.lb_listener_protocol

  default_action {
    type             = var.lb_listener_default_action_type
    target_group_arn = aws_lb_target_group.this.arn
  }
}