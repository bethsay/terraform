output "path" {
  # value = local.path
  value = "${path.cwd}${trimprefix(local.path, ".")}"
}
output "items" {
  value = concat([for attr in resource.local_file.env_files_set : basename(attr.filename)], [for attr in resource.local_file.component_files : basename(attr.filename)])
}
output "count" {
  value = length(resource.local_file.env_files_set) + length(resource.local_file.component_files)
}
