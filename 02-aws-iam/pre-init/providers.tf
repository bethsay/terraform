terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>6.23"
    }
  }
}

provider "aws" {
  # shared_credentials_files = ["~/.aws/credentials"]
  # shared_config_files      = ["~/.aws/config"]
  # profile                  = "default"
  # default_tags {
  #   tags = {
  #     project = "training",
  #     env     = "dev"
  #   }
  # }
  shared_credentials_files = var.path_aws_creds
  shared_config_files      = var.path_aws_conf
  profile                  = var.profile_aws_conf
  default_tags {
    tags = var.global_tags
  }
}
