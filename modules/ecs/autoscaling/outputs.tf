output "aws_appautoscaling_policy_up_arn" {
  value = aws_appautoscaling_policy.scale_up.arn
}

output "aws_appautoscaling_policy_down_arn" {
  value = aws_appautoscaling_policy.scale_down.arn
}
