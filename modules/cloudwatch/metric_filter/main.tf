resource "aws_cloudwatch_log_metric_filter" "this" {
  name           = var.name
  pattern        = var.pattern
  log_group_name = var.log_group_name

  metric_transformation {
    name      = "${var.name}-${var.pattern}"
    namespace = "LogMetrics-${var.name}"
    value     = "1"
  }
}
