resource "aws_s3_bucket" "first" {
  # bucket = "tf-bucket"
  bucket = var.mys3_prefix
  force_destroy = var.bucket_force_destroy
  tags = var.bucket_extra_tags
  count = var.suffix_type=="none" ? 1 : 0
}

resource "aws_s3_bucket" "second" {
  # bucket_prefix =  "tf-bucket-"
  # force_destroy = true
  # tags = { another = "temp", env = "temp" }
  bucket_prefix =  local.mys3_prefix_hyphen
  force_destroy = var.bucket_force_destroy
  tags = var.bucket_extra_tags
  count = (var.suffix_type=="time"||var.suffix_type=="all") ? 1 : 0
}

locals { mys3_prefix_hyphen = "${var.mys3_prefix}-" }

resource "random_id" "third" {
  byte_length = var.suffix_string_length
  prefix = local.mys3_prefix_hyphen
  count = (var.suffix_type=="string"||var.suffix_type=="all") ? 1 : 0
}

resource "random_pet" "third" {
  length = var.suffix_word_count
  prefix = var.mys3_prefix
  count = (var.suffix_type=="words"||var.suffix_type=="all") ? 1 : 0
}

resource "aws_s3_bucket" "third" {
  # # # for_each = toset(["${lower(replace(random_id.third.b64_url, "_", "-"))}", "${random_pet.third.id}"])
  # # # bucket = each.key
  # # for_each = local.id_map_third
  # # bucket = each.value
  # count = length(local.id_list_third)
  count = (var.suffix_type=="all") ? 2 : ((var.suffix_type=="words"||var.suffix_type=="string") ? 1 : 0)
  bucket = local.id_list_third[count.index]
  force_destroy = var.bucket_force_destroy
  tags = var.bucket_extra_tags
}

locals {
  # id_map_third = tomap({
  #   third_id = "${lower(replace(random_id.third.b64_url, "_", "-"))}"
  #   third_pet = "${random_pet.third.id}"
  # })
  # id_list_third = tolist([
  #   "${lower(replace(random_id.third.b64_url, "_", "-"))}",
  #   "${random_pet.third.id}",
  # ])
  id_list_third = compact(tolist([
    "${try(lower(replace(random_id.third[0].b64_url, "_", "-")), null)}",
    "${try(random_pet.third[0].id, null)}",
  ]))
}

resource "random_uuid" "fourth" {}
#
# data "external" "third" {
#   for_each = toset(["${local.mys3}", ])
#   program = [ "/bin/bash", "-c", "uuidgen -s -n @oid -N \"${each.key}\" | jq -R ' . as $full | split(\"-\")[0] as $part | { uuid_full: $full, uuid_part: $part }'" ]
# }
#
# resource "aws_s3_bucket" "third" {
#   # for_each = toset([ "${random_uuid.third.result}", "${data.external.third["${local.mys3}"].result.uuid_full}" ])
#   for_each = setunion([random_uuid.third.result],values(data.external.third)[*].result.uuid_part)
#   bucket = "${local.mys3}-${each.key}"
#   force_destroy = true
# }
#
# locals {
#   mys3_unique = setunion(
#     [try(lower(random_id.third[*].b64_url),[])],
#     [random_pet.third.id],
#     ["${local.mys3}-${random_uuid.third.result}"],
#     formatlist("%s-%s", local.mys3, values(data.external.third)[*].result.uuid_part)
#   )
# }
#
# locals {
#   s3_set = setunion([aws_s3_bucket.second.id],values(aws_s3_bucket.third)[*].id,values(aws_s3_bucket.third)[*].id)
# }
#
# resource "aws_s3_bucket_versioning" "all" {
#   for_each = local.s3_set
#   bucket = each.key
#   versioning_configuration {
#     status = "Enabled"
#   }
# }
#
# locals {
#   s3_upload_set = setproduct(local.s3_set, fileset("../", "*.txt"))
# }
#
# resource "aws_s3_object" "all" {
#   count = length(local.s3_upload_set)
#   bucket = tolist(tolist(local.s3_upload_set)[count.index])[0]
#   key = "docs/${tolist(tolist(local.s3_upload_set)[count.index])[1]}"
#   source = "../${tolist(tolist(local.s3_upload_set)[count.index])[1]}"
# }
#
