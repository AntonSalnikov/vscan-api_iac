
resource "aws_dynamodb_table" "file-scan-results-dynamodb-table" {
  name           = "FileScanResults-${terraform.workspace}"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "sha256Hash"
    type = "S"
  }

  global_secondary_index {
    name               = "sha256Hash-index"
    hash_key           = "sha256Hash"
    projection_type    = "KEYS_ONLY"
  }

  tags = local.tags
}
