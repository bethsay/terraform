variable "s3_prefix" {
  type    = string
  default = "tf-bucket"
}

variable "bucket_force_destroy" {
  type    = bool
  default = true
}

variable "bucket_extra_tags" {
  type    = map(string)
  default = {}
}

