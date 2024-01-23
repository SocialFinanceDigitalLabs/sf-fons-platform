


resource "aws_s3_bucket" "data_store_bucket" {
  bucket = format("%s-data-store-%s-%s", var.app_name, var.organisation_name, var.environment)
}

resource "aws_s3_bucket_cors_configuration" "data_store_bucket_cors" {
  bucket = aws_s3_bucket.data_store_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "POST", "PUT", "DELETE"]
    allowed_origins = [var.website_connection_origin_url]
    id              = "DataStoreRule"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "data_store_bucket_lifecycle" {
  bucket = aws_s3_bucket.data_store_bucket.id

  rule {
    id     = "AutoDeleteContent"
    status = "Enabled"

    expiration {
      days = var.auto_file_deletion
    }
  }

  rule {
    id     = "AbortIncompleteMultipartUpload"
    status = "Enabled"

    noncurrent_version_expiration {
      days = var.auto_file_deletion
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data_store_bucket_encrypt_config" {
  bucket = aws_s3_bucket.data_store_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_acl" "data_store_bucket_acl" {
  bucket = aws_s3_bucket.data_store_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket" "workspace_bucket" {
  bucket = format("%s-workspace-%s-%s", var.app_name, var.organisation_name, var.environment)
}

resource "aws_s3_bucket_lifecycle_configuration" "workspace_bucket_lifecycle" {
  bucket = aws_s3_bucket.workspace_bucket.id

  rule {
    id     = "AutoDeleteContent"
    status = "Enabled"

    expiration {
      days = var.auto_file_deletion
    }
  }

  rule {
    id     = "AbortIncompleteMultipartUpload"
    status = "Enabled"

    noncurrent_version_expiration {
      days = var.auto_file_deletion
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "workspace_bucket_encrypt_config" {
  bucket = aws_s3_bucket.workspace_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_acl" "workspace_bucket_acl" {
  bucket = aws_s3_bucket.workspace_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket" "shared_bucket" {
  bucket = format("%s-shared-%s-%s", var.app_name, var.organisation_name, var.environment)
}

resource "aws_s3_bucket_cors_configuration" "shared_bucket_cors" {
  bucket = aws_s3_bucket.shared_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "POST", "PUT", "DELETE"]
    allowed_origins = [var.website_connection_origin_url]
    id              = "DataStoreRule"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "shared_bucket_lifecycle" {
  bucket = aws_s3_bucket.shared_bucket.id

  rule {
    id     = "AutoDeleteContent"
    status = "Enabled"

    expiration {
      days = var.auto_file_deletion
    }
  }

  rule {
    id     = "AbortIncompleteMultipartUpload"
    status = "Enabled"

    noncurrent_version_expiration {
      days = var.auto_file_deletion
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "shared_bucket_encrypt_config" {
  bucket = aws_s3_bucket.shared_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_acl" "shared_bucket_acl" {
  bucket = aws_s3_bucket.shared_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "shared_bucket_access_policy" {
  bucket = aws_s3_bucket.shared_bucket.bucket

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { AWS = var.org_user_account_arn },
      Action    = "s3:GetObject",
      Resource  = join("", ["arn:aws:s3:::", aws_s3_bucket.shared_bucket.bucket, "/*"])
    }]
  })
}

resource "aws_iam_role" "data_store_storage_role" {
  name = format("%s-data-store-user-%s-%s", var.app_name, var.organisation_name, var.environment)
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = ["ec2.amazonaws.com"] },
      Action    = "sts:AssumeRole"
    }]
  })

  inline_policy {
    name = format("%s-data-store-user-access-%s-%s", var.app_name, var.organisation_name, var.environment)
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [{
        Effect   = "Allow",
        Action   = ["s3:PutObject", "s3:GetObject", "s3:DeleteObject"],
        Resource = join("", [aws_s3_bucket.data_store_bucket.arn, "/*"])
      }]
    })
  }
}

resource "aws_iam_role" "workspace_storage_role" {
  name = format("%s-workspace-user-%s-%s", var.app_name, var.organisation_name, var.environment)
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = ["ec2.amazonaws.com"] },
      Action    = "sts:AssumeRole"
    }]
  })

  inline_policy {
    name = format("%s-workspace-user-access-%s-%s", var.app_name, var.organisation_name, var.environment)
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [{
        Effect   = "Allow",
        Action   = ["s3:PutObject", "s3:GetObject", "s3:DeleteObject"],
        Resource = join("", [aws_s3_bucket.workspace_bucket.arn, "/*"])
      }]
    })
  }
}

resource "aws_iam_role" "shared_storage_role" {
  count = var.enable_cross_account_access ? 1 : 0
  name  = format("%s-shared-user-%s-%s", var.app_name, var.organisation_name, var.environment)
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = ["ec2.amazonaws.com"] },
      Action    = "sts:AssumeRole"
    }]
  })

  inline_policy {
    name = format("%s-shared-user-access-%s-%s", var.app_name, var.organisation_name, var.environment)
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [{
        Effect   = "Allow",
        Action   = ["s3:PutObject", "s3:GetObject", "s3:DeleteObject"],
        Resource = join("", [aws_s3_bucket.shared_bucket.arn, "/*"])
      }]
    })
  }
}
