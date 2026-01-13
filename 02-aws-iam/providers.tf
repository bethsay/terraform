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
  }
  backend "s3" {
    bucket       = "terraform-backend-58fd44e0"
    key          = "iam/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}

provider "aws" {
  shared_credentials_files = ["~/.aws/credentials"]
  shared_config_files      = ["~/.aws/config"]
  profile                  = "default"
  default_tags {
    tags = {
      project = "training",
      env     = "dev"
    }
  }
}
provider "external" {}
