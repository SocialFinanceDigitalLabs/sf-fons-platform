variable "FrontendRepoUri" {
  description = "The ECR or Docker Repo server to pull the image from (e.g. 840503653997.dkr.ecr.eu-west-2.amazonaws.com)"
  type        = string
}

variable "FrontendRepoName" {
  description = "The ECR or Docker Repo name to pull the image from (e.g. fons-frontend-staging)"
  type        = string
}

variable "FrontendRepoVersion" {
  description = "The version of the repo image to pull (e.g. latest)"
  type        = string
  default     = "latest"
}

variable "FrontendVpcCIDR" {
  description = "CIDR block for the Frontend VPC"
  type        = string
  default     = "10.0.0.0/16" # Replace with your desired CIDR block
}

variable "PublicSubnet1CIDR" {
  description = "CIDR block for the Frontend Public Subnet 1"
  type        = string
  default     = "10.0.1.0/24" # Replace with your desired CIDR block
}

variable "PublicSubnet2CIDR" {
  description = "CIDR block for the Frontend Public Subnet 2"
  type        = string
  default     = "10.0.2.0/24" # Replace with your desired CIDR block
}

variable "Environment" {
  description = "Environment name"
  type        = string
  default     = "Production" # Replace with your environment name
}

variable "FrontendEC2Image" {
  description = "AMI ID for the Frontend EC2 instance"
  type        = string
  default     = "ami-06f4d01597a96dac8" # Replace with your desired AMI ID
}

variable "FonsSSLCertificateARN" {
  description = "ARN of the SSL certificate for HTTPS"
  type        = string
  default     = "arn:aws:acm:region:account-id:certificate/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" # Replace with your SSL certificate ARN
}

variable "CognitoUserPoolId" {
  description = "ID of the Cognito User Pool"
  type        = string
  default     = "your-cognito-user-pool-id" # Replace with your Cognito User Pool ID
}

variable "CognitoAppClientId" {
  description = "ID of the Cognito App Client"
  type        = string
  default     = "your-cognito-app-client-id" # Replace with your Cognito App Client ID
}

variable "CognitoAppDomain" {
  description = "Domain of the Cognito App"
  type        = string
  default     = "your-cognito-app-domain" # Replace with your Cognito App Domain
}

variable "SecretKey" {
  description = "Django Secret Key"
  type        = string
  default     = "your-django-secret-key" # Replace with your Django Secret Key
}

variable "DataStoreLocation" {
  description = "Storage location for data"
  type        = string
  default     = "your-data-store-location" # Replace with your desired data store location
}