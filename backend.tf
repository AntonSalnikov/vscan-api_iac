terraform {
  required_version = ">= 1.8.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.50.0"
    }
     tls = {
       source = "hashicorp/tls"
       version = "4.0.5"
     }
     random = {
       source = "hashicorp/random"
       version = "3.6.1"
     }
     template = {
       source = "hashicorp/template"
       version = "2.2.0"
     }
  }
  backend "s3" {}
}
