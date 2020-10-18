resource "aws_sns_topic" "cloudwatch_sns" {
  name = "cloudwatch_alarm"
}

output "sns_arn" {
  value = aws_sns_topic.cloudwatch_sns.arn
}
