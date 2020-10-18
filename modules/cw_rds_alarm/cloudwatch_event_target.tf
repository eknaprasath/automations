resource "aws_cloudwatch_event_target" "CW-Target" {
  target_id = "CW-Alarm-Creation-RDS"
  rule      = aws_cloudwatch_event_rule.RDS-Alarm-Creation.name
  arn       = aws_lambda_function.CW-Alarm-Creation-RDS.arn
}

resource "aws_cloudwatch_event_rule" "RDS-Alarm-Creation" {
  name        = "RDS-Alarm-Creation"
  description = "RDS-Alarm-Creation"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.rds"
  ],
  "detail-type": [
    "AWS API Call via CloudTrail"
  ],
  "detail": {
    "eventSource": [
      "rds.amazonaws.com"
    ],
    "eventName": [
      "CreateDBInstance"
    ]
  }
}
PATTERN
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.CW-Alarm-Creation-RDS.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.RDS-Alarm-Creation.arn
}