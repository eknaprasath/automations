resource "aws_iam_role" "iam_rds_for_lambda" {
  name = "lambda_role_rds_stop_start_${var.region}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_policy_rds" {
  name        = "lambda_policy_rds_start_stop_${var.region}"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "rds:DescribeDBInstances",
        "rds:ListTagsForResource",
        "rds:StartDBInstance",
        "rds:StopDBInstance",
        "sns:Publish",
        "kms:Decrypt",
        "kms:Encrypt",
        "kms:RevokeGrant",
        "kms:GenerateDataKey",
        "kms:GenerateDataKeyWithoutPlaintext",
        "kms:DescribeKey",
        "kms:CreateGrant",
        "kms:ListGrants"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "policy_attachement" {
  role       = aws_iam_role.iam_rds_for_lambda.name
  policy_arn = aws_iam_policy.lambda_policy_rds.arn
}