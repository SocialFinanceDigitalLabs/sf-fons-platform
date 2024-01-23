variable "environment_name" {
  type        = string
  description = "An environment name that is prefixed to resource names"
}

variable "account_id" {
  type = string
  description = "The account ID"
}

variable "application_name" {
  type        = string
  description = "The name of the application (No Spaces)"
}

variable "organisation_name" {
  type        = string
  description = "The name of the organisation or la (No Spaces)"
}

variable "aws_region" {
  type = string
  description = "region of aws account"
  default = "eu-west-2"
}