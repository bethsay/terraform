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
