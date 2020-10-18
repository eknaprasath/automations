# variable "iam_role" {
#   type        = string
#   # default     = "arn:aws:iam::356143132518:role/lambda_iam_role"
#   description = "Lambda IAM Role"
# }
variable "lambda_name_windows" {
  type        = string
  default     = "CW-Alarm-Creation-windows"
  description = "lamda function name"
}
variable "lambda_name_linux" {
  type        = string
  default     = "CW-Alarm-Creation-linux"
  description = "lamda function name"
}

variable "cw_cpu_threshold" {
  type        = number
  default     = "80"
  description = "Threshold for CPU Utilization"
}
variable "cw_memory_threshold" {
  type        = number
  default     = "80"
  description = "Threshold for Memory Utilization"
}
variable "cw_disk_threshold" {
  type        = number
  default     = "30"
  description = "Disk Utilization available free space threshold"
}
variable "sns" {
  type        = string
  # default     = "arn:aws:sns:us-east-1:356143132518:cloudwatch_alarm"
  description = "SNS ARN which will be used to trigger notification by CloudWatch"
}
variable "region" { 
   description = "resource region"
   }