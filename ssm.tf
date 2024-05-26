

resource "aws_ssm_parameter" "cloud_aws_sqs_queue_file_data" {
  name = "/config/${local.application_name}_${terraform.workspace}/cloud.aws.sqs.queue.file-upload-queue"
  type = "String"
  value = aws_sqs_queue.file-upload-queue.name
}

resource "aws_ssm_parameter" "cloud_aws_s3_bucket_dirty" {
  name = "/config/${local.application_name}_${terraform.workspace}/spring.cloud.aws.s3.dirty-bucket"
  type = "String"
  value = local.storage_dirty_bucket_name
}

resource "aws_ssm_parameter" "cloud_aws_dynamodb_table_name" {
  name = "/config/${local.application_name}_${terraform.workspace}/spring.cloud.aws.dynamodb.file-scan-result-table"
  type = "String"
  value = aws_dynamodb_table.file-scan-results-dynamodb-table.name
}
