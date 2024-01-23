remote_state {
  backend = "s3"
  config = {
    bucket         = "fons-staging-la-terraform-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "eu-west-2"
    encrypt        = true
    # dynamodb_table = "my-lock-table"
  }
}

#providers {
#  aws = {
#    region = "us-east-1"
#    assume_role {
#      role_arn = "arn:aws:iam::ACCOUNT_ID:role/ROLE_NAME"
#      web_identity_token_file = "/path/to/web_identity_token.jwt"
#    }
#  }
#}