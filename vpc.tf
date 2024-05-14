#Full example - https://github.com/terraform-aws-modules/terraform-aws-vpc/blob/master/examples/complete-vpc/main.tf
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "2.70.0"

  name = local.vpc_name
  cidr = "10.0.0.0/16"

  azs             = local.availability_zones
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets

  tags = local.tags

  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway   = true
  single_nat_gateway   = true
  one_nat_gateway_per_az = false

  #Create IGW for public subnets
  create_igw = true
  igw_tags   = local.tags

  # VPC endpoint for S3
  enable_s3_endpoint = true

  # VPC endpoint for DynamoDB
  enable_dynamodb_endpoint = true

  ecs_agent_endpoint_security_group_ids = [aws_security_group.document-handler-security-group.id]
  enable_ecs_agent_endpoint = true

  ecs_endpoint_security_group_ids = [aws_security_group.document-handler-security-group.id]
  enable_ecs_endpoint = true

  ecs_telemetry_endpoint_security_group_ids = [aws_security_group.document-handler-security-group.id]
  enable_ecs_telemetry_endpoint = true

  #Enable SSM Endpoint
  ssm_endpoint_security_group_ids = [aws_security_group.document-handler-security-group.id]
  enable_ssm_endpoint = true

  #Enable Secret Manager Endpoint
  secretsmanager_endpoint_security_group_ids = [aws_security_group.document-handler-security-group.id]
  enable_secretsmanager_endpoint = true
}
