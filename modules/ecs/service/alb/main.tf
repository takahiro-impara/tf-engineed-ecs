
resource "aws_ecs_service" "this" {
  name            = var.name
  cluster         = var.cluster
  launch_type     = "FARGATE"
  task_definition = var.task_definition
  desired_count   = var.desired_count
  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }
  network_configuration {
    subnets          = var.subnets
    security_groups  = var.security_groups
    assign_public_ip = var.assign_public_ip
  }
  tags = var.tagNames
  depends_on = [
    aws_lb_listener_rule.forward
  ]
}

resource "aws_lb_listener_rule" "forward" {
  listener_arn = var.listener_arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = var.target_group_arn
  }

  condition {
    http_header {
      http_header_name = "User-agent"
      values           = ["Amazon CloudFront"]
    }
  }
  condition {
    path_pattern {
      values = ["*"]
    }
  }
}
