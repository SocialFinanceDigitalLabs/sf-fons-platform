output "data_store_bucket_name" {
  value       = aws_s3_bucket.data_store_bucket.bucket
  description = "Name of the sample Amazon S3 bucket with a lifecycle configuration."
}

output "data_store_role_arn" {
  value       = aws_iam_role.data_store_storage_role.arn
  description = "ARN of the role used to access the data store bucket"
}

output "workspace_bucket_name" {
  value       = aws_s3_bucket.workspace_bucket.bucket
  description = "Name of the sample Amazon S3 bucket with a lifecycle configuration."
}

output "workspace_role_arn" {
  value       = aws_iam_role.workspace_storage_role.arn
  description = "ARN of the role used to access the workspace bucket"
}

output "shared_bucket_name" {
  value       = aws_s3_bucket.shared_bucket.bucket
  description = "Name of the sample Amazon S3 bucket with a lifecycle configuration."
}

output "shared_role_arn" {
  value       = aws_iam_role.shared_storage_role[0].arn
  description = "ARN of the role used to access the shared bucket"
}