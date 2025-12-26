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

variable "encryption_key" {
  type = string
  default = ""
}

variable "aws_policy_names" {
  type    = list(string)
  default = []
  validation {
    condition = (
      !var.console_access ||                                    #IAMUserChangePassword policy isnt needed when console_access is disabled
      length(var.aws_policy_names) == 0 ||                      #IAMUserChangePassword policy isnt needed when using custom_policy_name
      contains(var.aws_policy_names, "IAMFullAccess") ||        #IAMUserChangePassword policy is already include in IAMFullAccess
      contains(var.aws_policy_names, "IAMUserChangePassword")
    )
    error_message = "include IAMUserChangePassword policy. Or you could deny console access or avoid using aws managed policies."
  }
  validation {
    condition = !contains(var.aws_policy_names, "AdministratorAccess")
    error_message = "AWS admins should not be created by code"
  }
}

