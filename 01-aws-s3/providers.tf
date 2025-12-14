terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>6.23"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.7"
    }
    external = {
      source  = "hashicorp/external"
      version = "~>2.3"
    }
  }
  # backend "s3" {
  #   bucket = "terraform-backend-bucket-20251128040048159500000001"
  #   key = "second/terraform.tfstate"
  #   region = "us-east-1"
  #   use_lockfile = true
  # }
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
provider "random" {}
