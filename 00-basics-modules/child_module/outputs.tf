output "path" {
  # value = local.path
  value = "${path.cwd}${trimprefix(local.path, ".")}"
}
output "items" {
  value = concat([for attr in local_file.env_files_set : basename(attr.filename)], [for attr in local_file.component_files : basename(attr.filename)])
}
output "count" {
  value = length(local_file.env_files_set) + length(local_file.component_files)
}
