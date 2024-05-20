provider "aws" {
  region = local.region
  profile = local.profile
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = local.terraform_bucket
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-up-and-running-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}
