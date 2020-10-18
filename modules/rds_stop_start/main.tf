resource "aws_lambda_function" "rds_stop_start" {
  description = "Lambda function to stop start RDS instances"
  filename      = "modules/rds_stop_start/files/rds-stop-start.zip"
  function_name = var.lambda_name
  role          = aws_iam_role.iam_rds_for_lambda.arn
  handler       = "rds_stop_start.lambda_handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256("modules/rds_stop_start/files/rds-stop-start.zip")

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
resource "aws_cloudwatch_event_rule" "cwevent_rds" {
  name        = var.cloudwatch_event_name
  description = var.cloudwatch_event_description
  schedule_expression = var.cloudwatch_event_schedule_expression
}

resource "aws_cloudwatch_event_target" "cwtarget_rds" {
  rule      = aws_cloudwatch_event_rule.cwevent_rds.name
  target_id = "rds-stop"
  arn       = aws_lambda_function.rds_stop_start.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rds_stop_start.function_name
  principal     = "events.amazonaws.com"
  source_arn    =  aws_cloudwatch_event_rule.cwevent_rds.arn
}