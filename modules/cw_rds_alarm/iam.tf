resource "aws_iam_role" "iam_for_lambda_cw_rds" {
  name = "lambda_role_cw_rds_alarm_${var.region}"

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

resource "aws_iam_policy" "lambda_policy_cw_rds_alarm" {
  name        = "lambda_policy_cw_rds_alarm_${var.region}"
  path        = "/"
  description = "IAM policy for logging from a lambda and create cw alarm for rds"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "ec2:DescribeTags",
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceStatus",
        "ec2:DescribeInstanceTypes",
        "rds:ListTagsForResource",
        "rds:AddTagsToResource",
        "rds:DescribeDBClusters",
        "rds:DescribeDBInstances",
        "rds:RemoveTagsFromResource",
        "sns:Publish",
        "cloudwatch:DeleteAlarms",
        "cloudwatch:DescribeAlarms",
        "cloudwatch:PutMetricAlarm",
        "cloudwatch:PutMetricData"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda_cw_rds.name
  policy_arn = aws_iam_policy.lambda_policy_cw_rds_alarm.arn
}