variable "file1" {
  description = "file name"
  default     = "tf_file_1"
  type        = string
}
variable "file2" {
  description = "file name"
  default     = "tf_file_2"
  type        = string
}
variable "replica" {
  description = "Resource multiplier"
  type        = number
  default     = 1
}
variable "env" {
  description = "List of environments"
  # type = set(string)
  type    = list(string)
  default = ["tf_infra_1", "tf_infra_2"]
}
variable "component" {
  description = "List of components"
  type        = map(string)
  default = {
    "Zone1" = "Public Content of Zone1"
    "Zone2" = "Private data within Zone2"
  }
}
variable "content" {
  description = "List of components with more properties"
  # type = map(any)
  type = map(map(string))
  default = {
    "Zone1" = {
      "ext"    = "html"
      "header" = "----Zone_1----"
      "body"   = "Public Content of Zone1"
      "footer" = "Regards\nBethsay Tom V"
    }
    "Zone2" = {
      "ext"    = "mail"
      "header" = "----Zone_2----"
      "body"   = "Private data within Zone2"
      "footer" = "Regards\nBethsay Tom V"
    }
  }
}
