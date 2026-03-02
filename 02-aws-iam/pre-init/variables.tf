variable "path_aws_creds" {
  type    = list(string)
  default = null
}

variable "path_aws_conf" {
  type    = list(string)
  default = null
}

variable "profile_aws_conf" {
  type    = string
  default = null
}

variable "global_tags" {
  type    = map(string)
  default = {
    project = "training"
    env     = "dev"
  }
}

variable "s3_prefix" {
  type    = string
  default = "terraform-backend"
}

variable "bucket_force_destroy" {
  type    = bool
  default = true
}

variable "bucket_extra_tags" {
  type    = map(string)
  default = {}
}

