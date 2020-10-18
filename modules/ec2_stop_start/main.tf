# data "aws_sns_topic" "sns" {
#   name = "cloudwatch_alarm"
# }

resource "aws_lambda_function" "test_lambda" {
  description = "Lambda function to stop start EC2 instances"
  filename      = "modules/ec2_stop_start/files/ec2-stop-start.zip"
  function_name = var.lambda_name
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "ec2-stop-start.lambda_handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256("modules/ec2_stop_start/files/ec2-stop-start.zip")

  runtime = "python3.8"
  memory_size =  "128"
  timeout = "300"
  environment {
    variables = {
      sns_arn = var.sns,
      region_name = var.region
    }

}
 
}
resource "aws_cloudwatch_event_rule" "cwevent" {
  name        = var.cloudwatch_event_name
  description = var.cloudwatch_event_description
  schedule_expression = var.cloudwatch_event_schedule_expression
}

resource "aws_cloudwatch_event_target" "cwtarget" {
  rule      = aws_cloudwatch_event_rule.cwevent.name
  target_id = "server-stop"
  arn       = aws_lambda_function.test_lambda.arn
}
