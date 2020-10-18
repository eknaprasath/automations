# data "aws_sns_topic" "sns_rds" {
#   name = "cloudwatch_alarm"
# }


resource "aws_lambda_function" "CW-Alarm-Creation-RDS-for-existing-instances" {
  description = "Lambda function to create cloudwatch alarms for RDS"
  filename      = "modules/cw_rds_alarm/files/cloudwatch_rds_for_existing.zip"
  function_name = var.lambda_name_rds_for_existing_rds_alarm
  role          = aws_iam_role.iam_for_lambda_cw_rds.arn
  handler       = "cloudwatch_rds_for_existing.lambda_handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  #source_code_hash = filebase64sha256("cw_rds_alarm/files/cloudwatch_rds_for_existing.zip")

  runtime = "python3.8"
  memory_size =  "128"
  timeout = "300"

  environment {
    variables = {
      sns_arn = var.sns,
      #cw_number_of_connections = var.cw_number_of_connections,
      cw_cpu_threshold = var.cw_cpu_threshold,
      cw_memory_threshold = var.cw_memory_threshold,
      cw_disk_threshold = var.cw_disk_threshold
    }
  }
}