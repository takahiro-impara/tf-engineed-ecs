resource "aws_iam_role" "ecs_autoscale_role" {
  name               = "ecs_autoscale_role"
  assume_role_policy = file("../../policies/autoscale.json")
}

resource "aws_iam_policy" "ecs_autoscale_role" {
  name        = "AWSApplicationAutoscalingECSService_Policy"
  description = "AWSApplicationAutoscalingECSService_Policy"
  policy      = file("../../policies/autoacaling-ecservice.json")
}

resource "aws_iam_role_policy_attachment" "ecs_autoscale_role_attach" {
  role       = aws_iam_role.ecs_autoscale_role.name
  policy_arn = aws_iam_policy.ecs_autoscale_role.arn
}
