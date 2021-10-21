resource "aws_iam_policy" "this" {
  name        = "koichi-ecs-exec"
  description = "koichi-ecs-exec"
  policy      = file("../../policies/ecs-ssm.json")
}

resource "aws_iam_role_policy_attachment" "adachin-ecstaskexecutionrole-attach" {
  role       = "ecsTaskExecutionRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "adachin-ecstaskexecutionrole-ecs-exec-attach" {
  role       = "ecsTaskExecutionRole"
  policy_arn = aws_iam_policy.this.arn
}
