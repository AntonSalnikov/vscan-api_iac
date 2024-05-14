# data "aws_sqs_queue" "file-metadata-queue" {
#   name = "MediaFileData"
# }

resource "aws_sqs_queue" "file-upload-queue" {
  name = "FileUpload"
  delay_seconds = 30
  message_retention_seconds = 86400
  sqs_managed_sse_enabled = true

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.file-upload-queue-dlq.arn
    maxReceiveCount     = 10
  })
  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.file-upload-queue-dlq.arn]
  })

  tags = local.tags
}

resource "aws_sqs_queue" "report-data-queue" {
  name = "FileReportDataUpload"
  delay_seconds = 5
  message_retention_seconds = 86400 * 14
  sqs_managed_sse_enabled = true

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.report-data-queue-dlq.arn
    maxReceiveCount     = 10
  })
  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.report-data-queue-dlq.arn]
  })

  tags = local.tags
}

resource "aws_sqs_queue_policy" "file-upload-queue_policy" {
  policy    = <<POLICY
{
  "Version": "2008-10-17",
  "Id": "__default_policy_ID",
  "Statement": [
    {
      "Sid": "__owner_statement",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${local.account_id}:root"
      },
      "Action": "SQS:*",
      "Resource": "${aws_sqs_queue.file-upload-queue.arn}"
    },
    {
      "Sid": "s3-statement-ID",
      "Effect": "Allow",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Action": "SQS:SendMessage",
      "Resource": "${aws_sqs_queue.file-upload-queue.arn}",
      "Condition": {
        "StringEquals": {
          "aws:SourceAccount": "${local.account_id}"
        },
        "ArnLike": {
          "aws:SourceArn": "${local.dirty_storage_bucket_arn}"
        }
      }
    }
  ]
}
POLICY
  queue_url = aws_sqs_queue.file-upload-queue.url
}

resource "aws_sqs_queue" "file-upload-queue-dlq" {
  name = "FileUpload-DLQ"
  message_retention_seconds = 1209600

  sqs_managed_sse_enabled = true

  tags = local.tags
}

resource "aws_sqs_queue" "report-data-queue-dlq" {
  name = "ReportData-DLQ"
  message_retention_seconds = 1209600

  sqs_managed_sse_enabled = true

  tags = local.tags
}

### ThreadGrid queue

resource "aws_sqs_queue" "quarantine-data-queue" {
  name = "QuarantineData"
  message_retention_seconds = 86400 * 14 # 14 days
  delay_seconds = 60 * 10 # 10 minutes
  visibility_timeout_seconds = 60 * 10 # 10 minutes
  sqs_managed_sse_enabled = true

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.quarantine-data-queue-dlq.arn
    maxReceiveCount     = 10
  })
  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.quarantine-data-queue-dlq.arn]
  })

  tags = local.tags
}

resource "aws_sqs_queue" "quarantine-data-queue-dlq" {
  name = "QuarantineData-DLQ"
  message_retention_seconds = 1209600
  sqs_managed_sse_enabled = true
  tags = local.tags
}
