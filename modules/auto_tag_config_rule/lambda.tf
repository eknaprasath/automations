resource "aws_iam_role" "iam_for_lambda" {
  name = "lambda_role_tagging_${var.region}"

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

resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda_policy_tagging_${var.region}"
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
        "rds:AddTagsToResource",
        "config:GetComplianceDetailsByConfigRule",
        "elasticloadbalancing:RemoveTags",
        "ec2:DeleteTags",
        "ec2:CreateTags",
        "elasticloadbalancing:AddTags",
        "ec2:DescribeTags",
        "ec2:DescribeInstances",
        "rds:DescribeDBInstances",
        "rds:DescribeDBSnapshots",
        "rds:RemoveTagsFromResource"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_lambda_function" "test_lambda" {
  filename      = "modules/auto_tag_config_rule/function.zip"
  function_name = "Auto_tagging"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "tag_resources_based_on_config_rule.lambda_handler"

  runtime = "python3.8"
  memory_size =  "128"
  timeout = "300"

  environment {
    variables = {
      tag1Key = var.tag1Key,
      tag2Key = var.tag2Key,
      tag3Key = var.tag3Key,
      tag4Key = var.tag4Key,
      tag5Key = var.tag5Key,
      tag6Key = var.tag6Key,
      tag7Key = var.tag7Key,
      tag8Key = var.tag8Key,
      tag1Value = var.tag1Value,
      tag2Value = var.tag2Value,
      tag3Value = var.tag3Value,
      tag4Value = var.tag4Value,
      tag5Value = var.tag5Value,
      tag6Value = var.tag6Value,
      tag7Value = var.tag7Value,
      tag8Value = var.tag8Value
    }
  }
}