variable "lambda_name" {
  type        = string
  default     = "rds-start-stop"
  description = "lamda function name"
}
variable "cloudwatch_event_name" {
  type        = string
  default     = "rds-instance-stop-start"
  description = "cloudwatch event name"
}
variable "cloudwatch_event_description" {
  type        = string
  default     = "cloudwatch event to stoping & starting rds instance"
}
variable "cloudwatch_event_schedule_expression" {
  type        = string
  default     = "rate(5 minutes)"
  description = "cloudwatch trigger for start and stop"
}
variable "region" {
  type        = string
  default     = "eu-west-1"

}
variable "sns" {
  type = string
}