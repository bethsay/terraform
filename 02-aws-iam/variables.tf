variable "user" {
  type    = string
  default = "tf-user"
}

variable "user_path" {
  type    = string
  default = "/"
}

variable "user_force_destroy" {
  type = bool
  default = true
}

variable "api_access" {
  type = bool
  default = true
}

variable "console_access" {
  type = bool
  default = true
}

