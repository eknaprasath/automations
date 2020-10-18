#provider "aws" {
  #region     = "us-east-1"
  #access_key = 
 # secret_key = 
#}


provider "aws" {
  region    = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_access_key
  assume_role {
    role_arn = "arn:aws:iam::356143132518:role/eknaprasath_padmaraj_cross_account"
  }
 alias = "eknaprasathpadmaraj"

}

module "sns_ekna" {
     source = "./modules/sns"
     providers = {aws = aws.eknaprasathpadmaraj}
}

# module "config_ekna" {
#      source = "./modules/auto_tag_config_rule"
#      providers = {aws = aws.eknaprasathpadmaraj}
#      tag1Key = "eknaprasath"
#      tag1Value = "padmaraj"
#      tag2Key = "LMEntity"
#      tag2Value = "VCZA"
#      tag3Key = "BU"
#      tag3Value = "CIT"
#      tag4Key = "Project"
#      tag4Value = "CIA"
#      tag5Key = "ManagedBy"
#      tag5Value = "Clement.February@vodacom.co.za"
#      tag6Key = "Confidentiality"
#      tag6Value = "C4"
#      tag7Key = "TaggingVersion"
#      tag7Value = "v1.0"
#      tag8Key = "BusinessService"
#      tag8Value = ""
# }

# module "cw_ekna" {
#      source = "./modules/cw_ec2_alarm"
#      providers = {aws = aws.eknaprasathpadmaraj}
#      cw_cpu_threshold = "80"
#      cw_memory_threshold = "80"
#      cw_disk_threshold = "30"
#      sns = module.sns_ekna.sns_arn
# }


# module "cw_rds_ekna" {
#      source = "./modules/cw_rds_alarm"
#      region = "us-east-1"
#      providers = {aws = aws.eknaprasathpadmaraj}
#      cw_cpu_threshold = "80"
#      cw_disk_threshold = "80"
#      cw_memory_threshold = "80"
#      cw_number_of_connections = "30"
#      sns = module.sns_ekna.sns_arn
# }
# module "cw_rds_ekna1" {
#      source = "./modules/cw_rds_alarm"
#      region = "us-west-1"
#      providers = {aws = aws.eknaprasathpadmaraj}
#      cw_cpu_threshold = "80"
#      cw_disk_threshold = "80"
#      cw_memory_threshold = "80"
#      cw_number_of_connections = "30"
#      sns = module.sns_ekna.sns_arn
# }


# module "ec2_stop_start_cis_nonprod" {
#      source = "./modules/ec2_stop_start"
#      providers = {aws = aws.eknaprasathpadmaraj}
#      region = "eu-west-1"
#      sns = module.sns_ekna.sns_arn
# }

 module "rds_stop_start_cis_nonprod" {
      source = "./modules/rds_stop_start"
      providers = {aws = aws.eknaprasathpadmaraj}
      region = "us-east-1"
      sns = module.sns_ekna.sns_arn
 }

#  module "rds_stop_start_cis_nonprod1" {
#       source = "./modules/rds_stop_start"
#       providers = {aws = aws.eknaprasathpadmaraj}
#       region = "us-east-1"
#       sns = module.sns_ekna.sns_arn
#  }