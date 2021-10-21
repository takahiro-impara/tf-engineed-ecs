
resource "aws_ecs_service" "this" {
  name            = var.name
  cluster         = var.cluster
  launch_type     = "FARGATE"
  task_definition = var.task_definition
  desired_count   = var.desired_count
  network_configuration {
    subnets          = var.subnets
    security_groups  = var.security_groups
    assign_public_ip = var.assign_public_ip
  }
  tags = var.tagNames
  service_registries {
    registry_arn = aws_service_discovery_service.ecs.arn
  }
}

resource "aws_service_discovery_private_dns_namespace" "internal" {
  name        = "internal.local"
  description = "internal.local"
  vpc         = var.vpc_id
}

resource "aws_service_discovery_service" "ecs" {
  name = "ecs-${var.name}"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.internal.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}
