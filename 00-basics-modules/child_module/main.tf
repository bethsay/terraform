locals {
  app  = upper(var.name)
  path = "${path.root}/training/${local.app}"
}

resource "local_file" "env_files_set" {
  for_each = toset(var.env)
  content  = "...This is ${each.key} content..!!\n"
  filename = "${local.path}/${each.key}.txt"
}

resource "local_file" "component_files" {
  for_each = tomap(var.component)
  content  = each.value
  filename = "${local.path}/${each.key}.txt"
}
