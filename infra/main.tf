terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

########################################
# LOCALS
########################################

locals {
  project_name = "ofisy"
  aws_region   = "us-east-1"
}

########################################
# PROVIDER
########################################

provider "aws" {
  region = local.aws_region
}
