resource "aws_lb" "this" {
  name               = var.tagNames["Name"]
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.securitygroups
  subnets            = var.subnets
  tags               = var.tagNames
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not authorized"
      status_code  = "403"
    }
  }
}

resource "aws_lb_target_group" "this" {
  name        = var.targetname
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    interval            = 10
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}
