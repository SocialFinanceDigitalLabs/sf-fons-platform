variable "project_name" {
  type    = string
  default = "Dagster"
}

/*variable "dagster_database_cluster_endpoint" {
  type        = string
  description = "Endpoint Address for the Database"
}*/

/*variable "db_password" {
  type        = string
  description = "Password to use with the database"
}*/

variable "input_location" {
  type        = string
  description = "The standard location to look for files to ingest into the pipelines. For s3, this must be a ROOT path, no folders. Example: s3://my-bucket-name"
}

variable "output_location" {
  type        = string
  description = "The standard output location for pipeline files. For s3, this must be a ROOT path, no folders."
}

variable "organisation_name" {
  type    = string
  default = "org"
}

variable "environment" {
  type        = string
  description = "The name for the environment. Expected values are dev, staging, prod"
}

variable "daemon_cpu" {
  type        = string
  default     = "256"
  description = "CPU to use for Daemon"
}

variable "dagit_cpu" {
  type        = string
  default     = "256"
  description = "CPU to use for Dagit"
}

variable "code_server_cpu" {
  type        = string
  default     = "256"
  description = "CPU to use for Code Server"
}

variable "daemon_memory" {
  type        = string
  default     = "1024"
  description = "Memory to use for Daemon"
}

variable "dagit_memory" {
  type        = string
  default     = "1024"
  description = "Memory to use for Dagit"
}

variable "code_server_memory" {
  type        = string
  default     = "1024"
  description = "CPU to use for the Code Server"
}

variable "daemon_image_path" {
  type        = string
  default     = ""
  description = "Docker hub image:Version or ECR URL in format aws_account_id.dkr.ecr.region.amazonaws.com/my-repository:latest"
}

variable "dagit_image_path" {
  type        = string
  default     = ""
  description = "Docker hub image:Version or ECR URL in format aws_account_id.dkr.ecr.region.amazonaws.com/my-repository:latest"
}

variable "user_code1_image_path" {
  type        = string
  default     = ""
  description = "Docker hub image:Version or ECR URL in format aws_account_id.dkr.ecr.region.amazonaws.com/my-repository:latest"
}

variable "daemon_launch_type" {
  type        = string
  default     = "FARGATE"
  description = "Either FARGATE or EC2 type can be used"
}

variable "dagit_launch_type" {
  type        = string
  default     = "FARGATE"
  description = "Either FARGATE or EC2 type can be used"
}

variable "code_server_launch_type" {
  type        = string
  default     = "FARGATE"
  description = "Either FARGATE or EC2 type can be used"
}

variable "health_check_grace_period_seconds" {
  type        = string
  default     = "30"
  description = "??"
}

variable "code_server_pipeline_folder" {
  type        = string
  default     = "pipeline"
  description = "What folder the repo exists in on the code server"
}

variable "code_server_pipeline_repo_location" {
  type        = string
  default     = "repository.py"
  description = "Location of the repo.py file that controls the repository"
}

variable "db_storage_size" {
  type        = number
  default     = 20
  description = "How many GB the db should be allocated for storage"
}

variable "db_instance_class" {
  type        = string
  default     = "db.serverless"
  description = "Type of resources for the database to use. See https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Concepts.DBInstanceClass.html#Concepts.DBInstanceClass.Types.serverless-v2"
}

variable "db_engine" {
  type        = string
  default     = "aurora-postgresql"
  description = "Type of database to run. Suggested postgres or aurora-postgresql"
}

variable "db_storage_type" {
  type        = string
  default     = "gp2"
  description = "Type of storage to run the database on (standard or gp2 are the usual options)"
}

variable "db_name" {
  type        = string
  default     = "postgres"
  description = "The name to be used for the database"
}

variable "db_port" {
  type        = string
  default     = "3306"
  description = "The port to use to connect to the database"
}

variable "db_username" {
  type        = string
  default     = "postgres"
  description = "Username to use with the database"
}

variable "db_min_capacity" {
  type        = string
  default     = "0.5"
  description = "Minimum capacity is 0.5"
}

variable "db_max_capacity" {
  type        = string
  default     = "1"
  description = "Minimum capacity is 0.5"
}

/*variable "database_subnet_group" {
  type        = string
  description = "Database Subnet Group ID"
}

variable "daemon_security_group" {
  type        = string
  description = "Security Group ARN to use for the Daemon"
}

variable "dagit_security_group" {
  type        = string
  description = "Security Group ARN to use for the Dagit Interface"
}

variable "code_server_security_group" {
  type        = string
  description = "Security Group ARN to use for the Code Servers"
}*/

variable "private_service_discovery_namespace" {
  type        = string
  default     = "fons-namespace.local"
  description = "Namespace for private network."
}

variable "dagit_sg_cidr" {
  description = "CIDR block for Dagit's security group. All zeros mean can be accessed by anyone."
  type        = string
  default     = "0.0.0.0/0"
}

variable "vpc_cidr" {
  description = "Please enter the IP range (CIDR notation) for this VPC"
  type        = string
  default     = "10.192.0.0/16"
}

variable "public_subnet1_cidr" {
  description = "Please enter the IP range (CIDR notation) for the public subnet in the first Availability Zone"
  type        = string
  default     = "10.192.10.0/24"
}

variable "public_subnet2_cidr" {
  description = "Please enter the IP range (CIDR notation) for the public subnet in the second Availability Zone"
  type        = string
  default     = "10.192.11.0/24"
}

variable "private_subnet1_cidr" {
  description = "Please enter the IP range (CIDR notation) for the private subnet in the first Availability Zone"
  type        = string
  default     = "10.192.20.0/24"
}

variable "private_subnet2_cidr" {
  description = "Please enter the IP range (CIDR notation) for the private subnet in the second Availability Zone"
  type        = string
  default     = "10.192.21.0/24"
}

variable "dagit_host_port" {
  type        = string
  default     = "3000"
  description = "Port the dagit Instance is hosted"
}

variable "code_server_port" {
  type        = string
  default     = "4000"
  description = "Port the code server is running on."
}

variable "database_subnet_cidr1" {
  type        = string
  default     = "10.192.30.0/24"
  description = "CIDR Block for the database subnet"
}

variable "database_subnet_cidr2" {
  type        = string
  default     = "10.192.31.0/24"
  description = "CIDR Block for the database subnet"
}

variable "database_port" {
  type        = string
  default     = "3306"
  description = "Port to connect to the database"
}

variable "data_store_bucket" {
  type        = string
  description = "Arn of the Data store s3 bucket"
}

variable "workspace_bucket" {
  type        = string
  description = "Arn of the Workspace s3 bucket"
}

variable "shared_bucket" {
  type        = string
  description = "Arn of the Shared s3 bucket"
}