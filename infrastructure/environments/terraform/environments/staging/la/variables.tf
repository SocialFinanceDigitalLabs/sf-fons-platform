variable "daemon_docker_repo_path" {
  type        = string
  description = "Docker repo path for the Dagster Daemon"
  default = "mathewpugh/fons-dagster:latest"
}

variable "dagit_docker_repo_path" {
  type        = string
  description = "Docker repo path for the Dagit Service"
  default = "mathewpugh/fons-dagster:latest"
}

variable "user_code_docker_repo_path" {
  type        = string
  description = "Docker repo path for the User Code Server"
  default = "mathewpugh/fons-code-server:latest"
}

variable "environment" {
  type        = string
  description = "The name for the environment (e.g. dev, staging, prod). LOWER CASE, NO SPACES"
  default = "staging"
}

variable "app_name" {
  type        = string
  default     = "sfdata"
  description = "The name for the application or instance. LOWER CASE, NO SPACES"
}

variable "organisation_name" {
  type        = string
  description = "The name for the organisation this is for (to make sure naming is unique). LOWER CASE, NO SPACES"
}

variable "website_connection_origin_url" {
  type        = string
  default     = "*"
  description = "Url of the website that will be accessing this bucket (e.g. from a frontend implementation). Connection is only allowed from an ec2/ecs resource on the same account."
}

variable "org_user_account_arn" {
  type        = string
  description = "ARN of the organisation user who can access the shared bucket"
  default = "*"
}

variable "enable_cross_account_access" {
  type        = bool
  default     = true
  description = "Enable cross-account access to the shared S3 bucket"
}