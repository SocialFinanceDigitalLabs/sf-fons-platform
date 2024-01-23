variable "environment" {
  type        = string
  description = "The name for the environment (e.g. dev, staging, prod). LOWER CASE, NO SPACES"
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

variable "auto_file_deletion" {
  type        = number
  default     = 2190
  description = "How long before files are automatically deleted (default 6 years)"
}

variable "website_connection_origin_url" {
  type        = string
  default     = "*"
  description = "Url of the website that will be accessing this bucket (e.g. from a frontend implementation). Connection is only allowed from an ec2/ecs resource on the same account."
}

variable "org_user_account_arn" {
  type        = string
  description = "ARN of the organisation user who can access this bucket"
}

variable "enable_cross_account_access" {
  type        = bool
  default     = true
  description = "Enable cross-account access to the shared S3 bucket"
}