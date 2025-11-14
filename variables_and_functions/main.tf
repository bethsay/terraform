locals {
  app      = "myapp"
  app_caps = upper(local.app)
  ext      = "md"
  env_ext  = formatlist("%s.%s", var.env, local.ext)
  path     = "${path.module}/training/${local.app_caps}"
}

resource "local_file" "file1" {
  content = "...This is ${var.file1} content..!!\n"
  # filename = "${path.module}/training/${var.file1}.txt"
  # filename = "${path.module}/training/set_${count.index+1}/${var.file1}.txt"
  filename = "${local.path}/${var.file1}_v${count.index + 1}.txt"
  count    = var.replica
}

resource "local_file" "file2" {
  content = "...This is ${var.file2} content..!!\n"
  # filename = "${path.module}/training/${var.file2}.txt"
  # filename = "${path.module}/training/set_${count.index+1}/${var.file2}.txt"
  filename = "${local.path}/${var.file2}_v${count.index + 1}.txt"
  count    = var.replica
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

resource "local_file" "env_files_list" {
  count    = length(var.env)
  content  = "...This is ${var.env[count.index]} content..!!\n"
  filename = "${local.path}/${local.env_ext[count.index]}"
}

resource "local_file" "content_files" {
  for_each = tomap(var.content)
  content  = "${each.value.header}\n${each.value.body}\n\n${each.value.footer}\n"
  filename = "${local.path}/${each.key}.${each.value.ext}"
}
