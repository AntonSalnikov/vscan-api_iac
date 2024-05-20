resource "aws_ecr_repository" "vscan-api-ecr" {
  name = "vscan-api"

  encryption_configuration {
    encryption_type = "KMS"
  }

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = local.tags
}

resource "aws_ecr_lifecycle_policy" "vscan-api-ecr-policy" {
  repository = aws_ecr_repository.vscan-api-ecr.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last 10 images",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": 10
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}