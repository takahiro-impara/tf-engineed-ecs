resource "aws_appautoscaling_target" "this" {
  resource_id        = var.resource_id
  scalable_dimension = "ecs:service:DesiredCount"
  role_arn           = data.aws_iam_role.ecs_service_autoscaling.arn
  min_capacity       = 2
  max_capacity       = 4
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "scale_up" {
  name               = "${var.name}_scale_up"
  service_namespace  = "ecs"
  resource_id        = var.resource_id
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

  depends_on = [aws_appautoscaling_target.this]

}

resource "aws_appautoscaling_policy" "scale_down" {
  name               = "${var.name}_scale_down"
  service_namespace  = "ecs"
  resource_id        = var.resource_id
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }

  depends_on = [aws_appautoscaling_target.this]
}

data "aws_iam_role" "ecs_service_autoscaling" {
  name = "ecs_autoscale_role"
}
