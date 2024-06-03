module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

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
}

#module "vpc_vpc-endpoints" {
#  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
#  version = "5.8.1"
#
#  vpc_id = module.vpc.vpc_id
#
#  endpoints = {
#    s3 = {
#      service = "s3"
#    }
#
#    dynamodb = {
#      service = "dynamodb"
#    }
#
#    ssm = {
#      service = "ssm",
#      security_group_ids = [aws_security_group.vscan-api-security-group.id]
#    }
#  }
#}
