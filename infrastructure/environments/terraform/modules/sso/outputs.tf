output "identifier_entity_id" {
  value = format("urn:amazon:cognito:sp:%s", aws_cognito_user_pool.cognito_user_pool.id)
}

output "reply_url" {
  value = format("https://%s-%s-%s.auth.${var.aws_region}.amazoncognito.com/saml2/idpresponse", var.application_name, var.organisation_name, var.environment_name)
}