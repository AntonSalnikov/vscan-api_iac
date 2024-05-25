output "arn" {
    value = aws_s3_bucket.dirty_storage_bucket.arn
}

output "bucket_name" {
    value = aws_s3_bucket.dirty_storage_bucket.bucket
}