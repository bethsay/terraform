variable "env" {
  description = "List of environments"
  type        = set(string)
  default     = ["tf_infra_1", "tf_infra_2"]
}
variable "component" {
  description = "List of components"
  type        = map(string)
  default = {
    "Zone1" = "Public Content of Zone1"
    "Zone2" = "Private data within Zone2"
  }
}
