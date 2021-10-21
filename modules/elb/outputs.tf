output "alb_dns_name" {
  value = aws_lb.this.dns_name
}

output "aws_lb_target_group" {
  value = aws_lb_target_group.this
}

output "aws_lb_listener_arn" {
  value = aws_lb_listener.this.arn
}
