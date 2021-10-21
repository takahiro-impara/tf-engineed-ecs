resource "aws_s3_bucket" "this" {
  bucket = "${var.tagNames["Name"]}-${var.env}"
  acl    = var.acl
  tags   = var.tagNames
  versioning {
    enabled    = false
    mfa_delete = false
  }
  policy = file(var.policy)
  provisioner "local-exec" {
    when    = create
    command = "aws sts assume-role --role-arn arn:aws:iam::974783918237:role/EngineedExam00122 --role-session-name Testing --output json > test.json && export AWS_ACCESS_KEY_ID=`jq -r '.Credentials.AccessKeyId' test.json` && export AWS_SECRET_ACCESS_KEY=`jq -r '.Credentials.SecretAccessKey' test.json` && export AWS_SESSION_TOKEN=`jq -r '.Credentials.SessionToken' test.json` && aws sts get-caller-identity && aws s3 sync ../../assets/s3/images/ s3://eng-exam-container-develop/assets/images/; aws s3 cp ../../assets/s3/events.json s3://eng-exam-container-develop&& rm test.json &&unset AWS_SESSION_TOKEN&& unset AWS_ACCESS_KEY_ID && unset AWS_SECRET_ACCESS_KEY"

  }
}
