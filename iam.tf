
resource "aws_iam_role" "document-handler-ecs-task-role" {
  name = "document-handler-ecs-task-role"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "document-handler-task-policy-attachment" {
  role       = aws_iam_role.document-handler-ecs-task-role.name
  policy_arn = aws_iam_policy.document-handler-task-policy.arn
}


resource "aws_iam_policy" "document-handler-task-policy" {
  name = "document-handler-task-policy"

  policy = <<EOF
{
    "Id": "document-handler-task-policy",
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ssmsid",
            "Effect": "Allow",
            "Action": [
                "ssm:Describe*",
                "ssm:Get*",
                "ssm:List*"
            ],
            "Resource": "*"
        },
        {
            "Sid": "s3sid",
            "Effect": "Allow",
            "Action": [
                "s3:Describe*",
                "s3:Get*",
                "s3:List*",
                "s3:Post*",
                "s3:Put*"
            ],
            "Resource": "*"
        },
        {
            "Sid": "secretsmanagersid",
            "Effect": "Allow",
            "Action": [
                "secretsmanager:Describe*",
                "secretsmanager:Get*",
                "secretsmanager:List*"
            ],
            "Resource": "*"
        },
        {
            "Sid": "kmssid",
            "Effect": "Allow",
            "Action": [
                "kms:GenerateDataKey*",
                "kms:Decrypt*"
            ],
            "Resource": "*"
        },
        {
            "Sid": "sqssid",
            "Effect": "Allow",
            "Action": [
                "sqs:*"
            ],
            "Resource": "*"
        },
        {
            "Sid": "cloudwatchsid",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogStreams",
                "cloudwatch:PutMetricData"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

# ecs task role
resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs_execution_role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "ecs_execution_policy" {
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogStreams"
            ],
            "Resource": "*"
        }
    ]
}
POLICY
  role = aws_iam_role.ecs_execution_role.name
}

# ecs service role
resource "aws_iam_role" "ecs-service-role" {
  name = "ecs-service-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs-service-attach" {
  role       = aws_iam_role.ecs-service-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}


### CICD role
# data "aws_iam_openid_connect_provider" "github" {
#   arn = format("arn:aws:iam::%s:oidc-provider/token.actions.githubusercontent.com",local.account_id)
# }
#
# data "aws_iam_policy_document" "github_actions_assume_role" {
#   statement {
#     actions = ["sts:AssumeRoleWithWebIdentity"]
#     principals {
#       type        = "Federated"
#       identifiers = [data.aws_iam_openid_connect_provider.github.arn]
#     }
#     condition {
#       test     = "StringLike"
#       variable = "token.actions.githubusercontent.com:sub"
#       values   = ["repo:AntonSalnikov/DocumentHandler:*"]
#     }
#   }
# }
#
# resource "aws_iam_role" "github_actions" {
#   name               = "github-actions-AntonSalnikov-DocumentHandler"
#   assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json
# }
#
# ####
#
# resource "aws_iam_policy" "github-actions-role-policy" {
#   name = "github-actions-role-policy"
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Sid:"GetAuthorizationToken",
#         Effect:"Allow",
#         Action:[
#           "ecr:GetAuthorizationToken"
#         ],
#         Resource:"*"
#       },
#       {
#         Action = [
#           "ecr:GetDownloadUrlForLayer",
#           "ecr:BatchGetImage",
#           "ecr:BatchCheckLayerAvailability",
#           "ecr:PutImage",
#           "ecr:InitiateLayerUpload",
#           "ecr:UploadLayerPart",
#           "ecr:CompleteLayerUpload"
#         ]
#         Effect   = "Allow"
#         Resource = [
#           aws_ecr_repository.document-handler-ecr.arn,
#           "${aws_ecr_repository.document-handler-ecr.arn}/*",
#         ]
#       },
#       {
#         "Sid":"RegisterTaskDefinition",
#         "Effect":"Allow",
#         "Action":[
#           "ecs:RegisterTaskDefinition",
#           "ecs:DescribeTaskDefinition"
#         ],
#         "Resource":"*"
#       },
#       {
#         "Sid":"PassRolesInTaskDefinition",
#         "Effect":"Allow",
#         "Action":[
#           "iam:PassRole"
#         ],
#         "Resource":[
#           aws_iam_role.document-handler-ecs-task-role.arn,
#           aws_iam_role.ecs_execution_role.arn
#         ]
#       },
#       {
#         "Sid":"DeployService",
#         "Effect":"Allow",
#         "Action":[
#           "ecs:UpdateService",
#           "ecs:DescribeServices"
#         ],
#         "Resource":[
#           aws_ecs_service.document-handler-backend-service.id
#         ]
#       }
#     ]
#   })
# }
#
# resource "aws_iam_role_policy_attachment" "github_actions" {
#   role       = aws_iam_role.github_actions.name
#   policy_arn = aws_iam_policy.github-actions-role-policy.arn
# }