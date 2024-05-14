data "aws_caller_identity" "this" {}

locals {
  environment = terraform.workspace

  tags = {
    managed_by = "Terraform"
    env = local.environment
  }

  dirty_storage_bucket_arn = "arn:aws:s3:::${local.storage_dirty_bucket_name}"

  storage_clean_bucket_name = lookup({ 
      "dev" = "vscan-api-clean-storage-dev",
      "test" = "vscan-api-clean-storage-test",
      "prod" = "vscan-api-clean-storage-prod"
    }, local.environment, "")
  storage_dirty_bucket_name = lookup({ 
      "dev" = "vscan-api-dirty-storage-dev",
      "test" = "vscan-api-dirty-storage-test",
      "prod" = "vscan-api-dirty-storage-prod"
    }, local.environment, "")
  clean_access_logs_bucket_name = lookup({ 
      "dev" = "vscan-api-logs-dev",
      "test" = "vscan-api-logs-test",
      "prod" = "vscan-api-logs"
    }, local.environment, "")
  dirty_access_logs_bucket_name = lookup({ 
      "dev" = "vscan-api-logs-dirty-dev",
      "test" = "vscan-api-logs-dirty-test",
      "prod" = "vscan-api-dirty-logs"
    }, local.environment, "")

  rds_cluster_snapshot = lookup({ "dev" = "", "test" = "arn:aws:rds:eu-central-1:444672554014:cluster-snapshot:vscan-api-final-sahred-rds-snapshot", "prod" = "vscan-api-cluster-1-final-snapshot" }, local.environment, "")

  bastion_key_pair = lookup({ "dev" = "vscan-api-bastion-dev", "test" = "vscan-api-bastion-test", "prod" = "vscan-api-bastion" }, local.environment, "")
  account_id = data.aws_caller_identity.this.account_id
  region = lookup({ "dev" = "eu-west-1", "test" = "eu-central-1", "prod" = "eu-central-1" }, local.environment, "")
  profile = lookup({ "dev" = "vscan-api-dev", "test" = "vscan-api-test", "prod" = "vscan-api-prod" }, local.environment, "")
  terraform_bucket = lookup({ "dev" = "vscan-api-terraform-dev", "test" = "vscan-api-terraform-test", "prod" = "vscan-api-terraform" }, local.environment, "")
  terraform_admin = lookup({ "dev" = "terraform", "test" = "terraform", "prod" = "terraform" }, local.environment, "")

  private_subnets = lookup({
      "dev" = [ "10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24" ], 
      "test" = [ "10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24" ], 
      "prod" = [ "10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24" ],
    }, local.environment, ""
  )
  public_subnets = lookup({
      "dev" = [ "10.0.121.0/24", "10.0.122.0/24", "10.0.123.0/24" ], 
      "test" = [ "10.0.111.0/24", "10.0.112.0/24", "10.0.113.0/24" ], 
      "prod" = [  "10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24" ]
    },
      local.environment, ""
  )
  vpc_name = lookup({ "dev" = "vscan-api-dev-vpc", "test" = "vscan-api-test-vpc", "prod" = "vscan-api-vpc" }, local.environment, "")
  availability_zones = [ format("%s%s", local.region, "a"), format("%s%s", local.region, "b"), format("%s%s", local.region, "c") ]
  
  mgt_instance_profile = lookup({ "dev" = "mgt-ec2-instance", "test" = "mgt-ec2-instance", "prod" = "MgmtEC2" }, local.environment, "")
  mgt_instance_ami = lookup({ "dev" = "", "test" = "ami-00aeb15a47842da91", "prod" = "ami-074c0aeef10ec9768" }, local.environment, "")
  mgt_instance_keypair = lookup({ "dev" = "", "test" = "bastion-test", "prod" = "mgmt-prod" }, local.environment, "")

  cloudflare_ip = toset([
    "103.21.244.0/22",
    "103.22.200.0/22",
    "103.31.4.0/22",
    "104.16.0.0/13",
    "104.24.0.0/14",
    "108.162.192.0/18",
    "131.0.72.0/22",
    "141.101.64.0/18",
    "162.158.0.0/15",
    "172.64.0.0/13",
    "173.245.48.0/20",
    "188.114.96.0/20",
    "190.93.240.0/20",
    "197.234.240.0/22",
    "198.41.128.0/17"
  ])
#   hosted_zone = lookup({ "dev" = "", "test" = "war-crimes.org.ua", "prod" = "vscan-api.gov.ua" }, local.environment, "")
}

