output "path" {
  # value = "They are all created and stored in ${local.path}"
  # value = "They are all created and stored in ${path.cwd}${trimprefix(local.path, ".")}"
  value     = "They are all created and stored in ${abspath(local.path)}"
  sensitive = false
}
output "items" {
  # value = format("Some of these items are %s", join(", ",local_file.file1[*].filename))
  value = format("Some of these items are %s", join(", ", [for attr in local_file.content_files : basename(attr.filename)]))
  # value = format("Some of these items are %s", join(", ",[for attr in local_file.content_files : trimprefix(attr.filename,"${local.path}/")]))
  # value = format("Some of these items are %s", join(", ",[for attr in local_file.content_files : regex("([^/]+)$",attr.filename)[0]]))
  # value = format("Some of these items are %s", join(", ",[for attr in local_file.content_files : element(split("/",attr.filename),-1)]))
  # value = format("All of these items are %s", join(", ", fileset(local.path,"**")))
  # value = format("Some of these items are %s", join(", ", slice(tolist(fileset(local.path, "**")), 0, 5)))
  # value = format("Some of these items are %s", join(", ", element(chunklist(tolist(fileset(local.path,"**")), 5), 0)))
}
output "count" {
  value = format("We have %d files created", length(local_file.file1) + length(local_file.file2) + length(local_file.env_files_set) + length(local_file.component_files) + length(local_file.env_files_list) + length(local_file.content_files))
  # value = format("We have %d files created", length(fileset(local.path, "**")))
}
data "local_file" "items_content" {
  # for_each = toset(values(local_file.content_files)[*].filename)
  # filename = each.key
  for_each = toset([for attr in local_file.content_files : basename(attr.filename)])
  filename = "${local.path}/${each.key}"
}
output "items_content" {
  # value  = values(data.local_file.items_content)[*].content
  value = [for attr in data.local_file.items_content : trimspace(attr.content)]
}
