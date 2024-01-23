

resource "aws_cognito_user_pool" "cognito_user_pool" {
  name = format("%s-%s-User-Pool-%s", var.application_name, var.organisation_name, var.environment_name)

  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_uppercase = true
    require_symbols   = true
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_LINK"
  }
}

resource "aws_cognito_user_pool_client" "cognito_user_pool_client" {
  name          = format("%s-%s-App-Client-%s", var.application_name, var.organisation_name, var.environment_name)
  user_pool_id  = aws_cognito_user_pool.cognito_user_pool.id
  generate_secret = true
}

resource "aws_cognito_user_pool_domain" "user_pool_domain" {
  domain      = format("%s-%s-%s", var.application_name, var.organisation_name, var.environment_name)
  user_pool_id = aws_cognito_user_pool.cognito_user_pool.id
}

resource "aws_cognito_identity_pool" "cognito_identity_pool" {
  identity_pool_name = "MyIdentityPool"

  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id     = aws_cognito_user_pool_client.cognito_user_pool_client.id
    provider_name = "cognito-idp.${data.aws_region.current}.amazonaws.com/${aws_cognito_user_pool.cognito_user_pool.id}"
  }


  openid_connect_provider_arns = ["arn:aws:oidc:${data.aws_region.current}:${var.account_id}:${aws_cognito_user_pool.cognito_user_pool.id}"]
}

data "aws_region" "current" {}
