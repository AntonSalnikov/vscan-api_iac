terraform {
  required_version = ">= 0.14"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.4.0"
    }
#     tls = {
#       source = "hashicorp/tls"
#       version = "3.0.0"
#     }
#     random = {
#       source = "hashicorp/random"
#       version = "3.0.0"
#     }
#     template = {
#       source = "hashicorp/template"
#       version = "2.2.0"
#     }
  }
  backend "s3" {}
}
