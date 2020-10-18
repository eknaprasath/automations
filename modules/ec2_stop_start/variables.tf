variable "lambda_name" {
  type        = string
  default     = "ec2-start-stop"
  description = "lamda function name"
}
variable "cloudwatch_event_name" {
  type        = string
  default     = "ec2-instance-stop-start"
  description = "cloudwatch event name"
}
variable "cloudwatch_event_description" {
  type        = string
  default     = "cloudwatch event to stoping & starting ec2 instance"
}
variable "cloudwatch_event_schedule_expression" {
  type        = string
  default     = "rate(5 minutes)"
  description = "cloudwatch trigger for start and stop"
}

variable "sns" {
  type = string
}
variable "region" { 
   description = "resource region"
   }