resource "aws_s3_bucket" "dirty_access_log_bucket" {
  bucket = var.dirty_access_logs_bucket_name
  tags = var.tags
}

# Dirty Bucket
resource "aws_s3_bucket" "dirty_storage_bucket" {
  bucket = var.storage_dirty_bucket_name
  tags = var.tags
}

# resource "aws_s3_bucket_acl" "dirty_storage_bucket_acl" {
#   bucket = aws_s3_bucket.dirty_storage_bucket.id
#   acl    = "private"
# }

resource "aws_s3_bucket_ownership_controls" "dirty_storage_bucket_ownership_controls" {
  bucket = aws_s3_bucket.dirty_storage_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}


resource "aws_s3_bucket_versioning" "dirty_storage_bucket_versioning" {
  bucket = aws_s3_bucket.dirty_storage_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "dirty_storage_bucket_logging" {
  bucket = aws_s3_bucket.dirty_storage_bucket.id

  target_bucket = aws_s3_bucket.dirty_access_log_bucket.id
  target_prefix = aws_s3_bucket.dirty_storage_bucket.bucket
}

resource "aws_s3_bucket_server_side_encryption_configuration" "dirty_storage_bucket_encryption" {
  bucket = aws_s3_bucket.dirty_storage_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

