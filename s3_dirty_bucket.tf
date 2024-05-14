module "dirty_storage_bucket" {
  source = "./modules/s3_dirty_bucket"

  dirty_access_logs_bucket_name = local.dirty_access_logs_bucket_name
  storage_dirty_bucket_name = local.storage_dirty_bucket_name
  tags = local.tags

  count = local.environment == "prod" ? 0 : 1
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = local.storage_dirty_bucket_name
  queue {
    queue_arn     = aws_sqs_queue.file-upload-queue.arn
    events        = ["s3:ObjectCreated:*"]
  }
}

