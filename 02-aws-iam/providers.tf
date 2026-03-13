terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>6.23"
    }
    external = {
      source  = "hashicorp/external"
      version = "~>2.3"
    }
    local = {
      source  = "hashicorp/local"
      version = "~>2.5"
    }
  }
  backend "s3" {
    bucket       = "terraform-backend-58fd44e0"
    key          = "iam/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}

provider "aws" {
  shared_credentials_files = var.path_aws_creds
  shared_config_files      = var.path_aws_conf
  profile                  = var.profile_aws_conf
  default_tags {
    tags = var.global_tags
  }
}

provider "external" {}
provider "local" {}
