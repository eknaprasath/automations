resource "aws_cloudwatch_event_rule" "every_30_minutes" {
  name                = "every-30-minutes-auto-tagging"
  description         = "Fires every 30 minutes and trigger lambda function to check tag enforcement"
  schedule_expression = "rate(30 minutes)"
}

resource "aws_cloudwatch_event_target" "check_every_30_minute" {
  rule      = aws_cloudwatch_event_rule.every_30_minutes.name
  target_id = "lambda"
  arn       =  aws_lambda_function.test_lambda.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_30_minutes.arn
}