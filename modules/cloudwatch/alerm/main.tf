resource "aws_cloudwatch_metric_alarm" "up" {
  alarm_name          = "${var.name}_cpu_utilization_high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "60"

  dimensions = {
    ClusterName = var.ClusterName
    ServiceName = var.ServiceName
  }

  alarm_actions = [var.aws_appautoscaling_policy_up_arn]
}

resource "aws_cloudwatch_metric_alarm" "down" {
  alarm_name          = "${var.name}_cpu_utilization_low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "30"

  dimensions = {
    ClusterName = var.ClusterName
    ServiceName = var.ServiceName
  }

  alarm_actions = [var.aws_appautoscaling_policy_down_arn]
}
