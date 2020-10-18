# data "aws_sns_topic" "sns_ec2" {
#   name = "cloudwatch_alarm"
# }


resource "aws_lambda_function" "CW-Alarm-Creation-linux" {
  description = "Lambda function to create cloudwatch alarms"
  filename      = "modules/cw_ec2_alarm/files/cloudwatch_linux.zip"
  function_name = var.lambda_name_linux
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "cloudwatch_linux.lambda_handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256("modules/cw_ec2_alarm/files/cloudwatch_linux.zip")

  runtime = "python3.8"
  memory_size =  "128"
  timeout = "300"

  environment {
    variables = {
      sns_arn = var.sns,
      cw_disk_threshold = var.cw_disk_threshold,
      cw_cpu_threshold = var.cw_cpu_threshold,
      cw_memory_threshold = var.cw_memory_threshold
    }
  }
}

resource "aws_lambda_function" "CW-Alarm-Creation-windows" {
  description = "Lambda function to create cloudwatch alarms"
  filename      = "modules/cw_ec2_alarm/files/cloudwatch_windows.zip"
  function_name = var.lambda_name_windows
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "cloudwatch_windows.lambda_handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256("modules/cw_ec2_alarm/files/cloudwatch_windows.zip")

  runtime = "python3.8"
  memory_size =  "128"
  timeout = "300"

  environment {
    variables = {
      sns_arn = var.sns,
      cw_disk_threshold = var.cw_disk_threshold,
      cw_cpu_threshold = var.cw_cpu_threshold,
      cw_memory_threshold = var.cw_memory_threshold
    }
  }
}

