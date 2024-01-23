terraform {
  backend "s3" {}
}

provider "aws" {}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

module "sso" {
  source = "../../../modules/sso"

  environment_name  = var.environment
  account_id        = data.aws_caller_identity.current.account_id
  application_name  = var.app_name
  organisation_name = var.organisation_name
  aws_region        = data.aws_region.current
}

module "frontend" {
  source = "../../../modules/frontend"

  FrontendRepoUri       = var.frontend_docker_repo_path
  FrontendRepoName      = var.frontend_docker_repo_name
  FrontendRepoVersion   = var.frontend_docker_repo_version
  Environment           = var.environment
  FonsSSLCertificateARN = var.ssl_certificate_arn
  CognitoUserPoolId     = module.sso
  CognitoAppClientId    = module.sso
  CognitoAppDomain      = module.sso
  SecretKey             = var.django_secret_key
  DataStoreLocation     = module.storage.data_store_bucket_name
}

module "dagster" {
  source = "../../../modules/dagster"

  project_name          = var.app_name
  input_location        = "s3://${module.storage.data_store_bucket_name}"
  output_location       = "s3://${module.storage.workspace_bucket_name}"
  organisation_name     = var.organisation_name
  environment           = var.environment
  daemon_image_path     = var.daemon_docker_repo_path
  dagit_image_path      = var.dagit_docker_repo_path
  user_code1_image_path = var.user_code_docker_repo_path
  data_store_bucket     = module.storage.data_store_bucket_name
  workspace_bucket      = module.storage.workspace_bucket_name
  shared_bucket         = module.storage.shared_bucket_name
}

module "storage" {
  source = "../../../modules/storage"

  environment                   = var.environment
  app_name                      = var.app_name
  organisation_name             = var.organisation_name
  auto_file_deletion            = "true"
  website_connection_origin_url = var.website_connection_origin_url
  org_user_account_arn          = var.org_user_account_arn
  enable_cross_account_access   = var.enable_cross_account_access
}

module "intrusion_detection" {
  source = "../../../modules/ids"

  guard_duty_email = "matthew.pugh@socialfinance.org.uk"
}