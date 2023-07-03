locals {
  # Parse the file path we're in to read the env name: e.g., env
  # will be "dev" in the dev folder, "stage" in the stage folder,
  # etc.
  parsed = regex(".*/live/(?P<env>.*?)/.*", get_terragrunt_dir())
  env    = local.parsed.env
}

# Configure S3 as a backend
remote_state {
  backend = "s3"
  config = {
    bucket = "sfdata-platform-${local.env}"
    region = "eu-west-2"
    key    = "${path_relative_to_include()}/terraform.tfstate"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}