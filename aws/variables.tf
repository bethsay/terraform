variable "mys3_prefix" {
  type = string
  default = "tf-bucket"
}

variable "bucket_force_destroy" {
  type = bool
  default = true
}

variable "bucket_extra_tags" {
  type = map(string)
  default = {}
}

variable "suffix_string_length" {
  type = number
  default = 7
}

variable "suffix_word_count" {
  type = number
  default = 3
}

variable "suffix_type" {
  type = string
  default = "all"
  validation {
    condition = contains(
      [ "all", "none", "time", "string", "words",
        "uuid", "uuidv5_int", "uuidv5_ext",
      ],
      var.suffix_type
    )
    error_message = "Choose one : \"all\", \"none\", \"time\", \"string\", \"words\", \"uuid\", \"uuidv5_int\", \"uuidv5_ext\","
  }
}

