locals {
  file-upload-queue-name = "file-upload-queue"
  seg-log-queue-name = "seg-log-queue"
}


resource "aws_sqs_queue" "file-upload-queue" {
  name = "${local.file-upload-queue-name}-${terraform.workspace}"
  delay_seconds = 5
  message_retention_seconds = 86400
  receive_wait_time_seconds = 20 #enable long polling to minimise costs
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

resource "aws_sqs_queue" "seg-log-queue" {
  name = "${local.seg-log-queue-name}-${terraform.workspace}"
  message_retention_seconds = 86400
  receive_wait_time_seconds = 20 #enable long polling to minimise costs
  sqs_managed_sse_enabled = true

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.seg-log-queue-dlq.arn
    maxReceiveCount     = 10
  })
  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.seg-log-queue-dlq.arn]
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


resource "aws_sqs_queue_policy" "seg-log-queue_policy" {
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
      "Resource": "${aws_sqs_queue.seg-log-queue.arn}"
    }
  ]
}
POLICY
  queue_url = aws_sqs_queue.seg-log-queue.url
}

resource "aws_sqs_queue" "file-upload-queue-dlq" {
  name = "${local.file-upload-queue-name}-${terraform.workspace}-DLQ"
  message_retention_seconds = 1209600

  sqs_managed_sse_enabled = true

  tags = local.tags
}

resource "aws_sqs_queue" "seg-log-queue-dlq" {
  name = "${local.seg-log-queue-name}-${terraform.workspace}-DLQ"
  message_retention_seconds = 1209600

  sqs_managed_sse_enabled = true

  tags = local.tags
}
