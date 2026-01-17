variable "mys3_prefix" {
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

variable "suffix_string_length" {
  type    = number
  default = 7
}

variable "suffix_word_count" {
  type    = number
  default = 3
}

variable "suffix_type" {
  type    = string
  default = "all"
  validation {
    condition = contains(
      ["all", "none", "time", "string", "words",
       "uuid", "uuidv5_int", "uuidv5_ext",
      ],
      var.suffix_type
    )
    error_message = "Choose one : \"all\", \"none\", \"time\", \"string\", \"words\", \"uuid\", \"uuidv5_int\", \"uuidv5_ext\","
  }
}

variable "bucket_versioning" {
  type    = bool
  default = true
}

variable "version_limit" {
  type    = number
  default = 5
}

variable "bucket_upload" {
  type    = list(string)
  default = []
}

variable "bucket_lock" {
  type    = bool
  default = true
}

variable "lock_bypass_username" {
  type    = list(string)
  default = []
  validation {
    condition = var.bucket_lock || length(var.lock_bypass_username) == 0
    error_message = "lock_bypass cannot items when bucket_lock is disabled"
  }
}

variable "lock_bypass_arn" {
  type    = list(string)
  default = []
  validation {
    condition = var.bucket_lock || length(var.lock_bypass_arn) == 0
    error_message = "lock_bypass cannot items when bucket_lock is disabled"
  }
  validation {
    condition = alltrue([
      for item in var.lock_bypass_arn : can(regex(
        "^arn:aws:iam::[\\d]{12}:(?:user|role)(/(?:[\\x21-\\x7E]*/)?)([\\w+=,.@-]+)$",
        item
      ))
    ])
    error_message = "Only User or Role Arn may be passed"
  }
}

