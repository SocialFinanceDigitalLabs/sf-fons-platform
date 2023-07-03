variable "platform_name" {
  description = "Name of the platform"
  type        = string
  default     = "sfdata-platform"
}

variable "environment" {
  description = "The type of environment being deployed: dev/staging/prod"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "The AWS Region to deploy to"
  type        = string
  default     = "eu-west-2"
}

variable "vpc_cidr" {
  description = "The IP range (CIDR notation) for this VPC"
  type        = string
  default     = "10.192.0.0/16"
}

variable "public_subnet_1_cidr" {
  description = "The IP range (CIDR notation) for the public subnet in the first Availability Zone"
  type        = string
  default     = "10.192.10.0/24"
}

variable "public_subnet_2_cidr" {
  description = "The IP range (CIDR notation) for the public subnet in the second Availability Zone"
  type        = string
  default     = "10.192.11.0/24"
}

variable "private_subnet_1_cidr" {
  description = "The IP range (CIDR notation) for the private subnet in the first Availability Zone"
  type        = string
  default     = "10.192.20.0/24"
}

variable "private_subnet_2_cidr" {
  description = "The IP range (CIDR notation) for the private subnet in the second Availability Zone"
  type        = string
  default     = "10.192.21.0/24"
}

variable "security_group_cidr" {
  description = "The IP range (CIDR notation) for the security group"
  type        = string
  default     = "127.0.0.1/32"
}

variable "log_retention" {
  description = "How long (in days) to keep the logs stored for"
  type        = string
  default     = "14"
}

variable "state_bucket_name" {
  description = "AWS Location for tfstate in S3"
  type        = string
}