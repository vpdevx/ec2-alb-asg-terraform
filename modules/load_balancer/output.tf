output "lb_dns_name" {
  value = aws_lb.this.dns_name
}

output "lb_tg_arn" {
  value = aws_lb_target_group.this.arn
}

output "lb_id" {
  value = aws_lb.this.id
}