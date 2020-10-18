# resource "aws_config_config_rule" "require-tags" {
#   name             = "require-tags"
#   description      = "Checks whether your resources have the tags that you specify. For example, you can check whether your EC2 instances have the 'CostCenter' tag. Separate multiple values with commas."
#   input_parameters = "${data.template_file.aws_config_require_tags.rendered}"

#   source {
#     owner             = "AWS"
#     source_identifier = "REQUIRED_TAGS"
#   }

#   depends_on = ["aws_config_configuration_recorder.main"]
# }

 #"{\"tag1Key\": \"Name\",\"tag2Key\": \"Description\",\"tag3Key\": \"BudgetCode\",\"tag4Key\": \"Owner\"}"

resource "aws_config_config_rule" "ConfigRule-1" {
  name = "required-tags-1"
  description = "A Config rule that checks whether your resources have the tags that you specify. For example, you can check whether your EC2 instances have the 'CostCenter' tag. Separate multiple values with commas."
  input_parameters = jsonencode({"tag1Key"=var.tag1Key,"tag1Value"=var.tag1Value,"tag2Key"=var.tag2Key,"tag2Value"=var.tag2Value,"tag3Key"=var.tag3Key,tag3Value=var.tag3Value,"tag4Key"=var.tag4Key,"tag4Value"=var.tag4Value,"tag5Key"=var.tag5Key,tag5Value=var.tag5Value,"tag6Key"=var.tag6Key,"tag6Value"=var.tag6Value})
  
    source {
    owner = "AWS"
    source_identifier = "REQUIRED_TAGS"
  }
  scope {
    compliance_resource_types = ["AWS::EC2::Instance","AWS::ElasticLoadBalancing::LoadBalancer","AWS::ElasticLoadBalancingV2::LoadBalancer","AWS::RDS::DBInstance","AWS::RDS::DBSnapshot"]
  }
}

resource "aws_config_config_rule" "ConfigRule-2" {
  name = "required-tags-2"
  description = "A Config rule that checks whether your resources have the tags that you specify. For example, you can check whether your EC2 instances have the 'CostCenter' tag. Separate multiple values with commas."
  input_parameters = jsonencode({"tag1Key"=var.tag7Key,"tag2Key"=var.tag8Key})
  
    source {
    owner = "AWS"
    source_identifier = "REQUIRED_TAGS"
  }
  scope {
    compliance_resource_types = ["AWS::EC2::Instance","AWS::ElasticLoadBalancing::LoadBalancer","AWS::ElasticLoadBalancingV2::LoadBalancer","AWS::RDS::DBInstance","AWS::RDS::DBSnapshot"]
  }
}