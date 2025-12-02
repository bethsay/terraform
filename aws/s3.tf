resource "aws_s3_bucket" "first" {
  # # bucket = "tf-bucket"
  # bucket_prefix =  "tf-bucket-"
  # force_destroy = true
  # tags = { another = "temp", env = "temp" }
  bucket_prefix =  local.mys3_prefix_hyphen
  force_destroy = var.bucket_force_destroy
  tags = var.bucket_extra_tags
  # count = var.bool ? length (var.set) : 0
}

locals { mys3_prefix_hyphen = "${var.mys3_prefix}-" }
#
# resource "random_id" "second" {
#   count = 0
#   byte_length = 7
#   prefix = "${local.mys3}-"
# }
#
# resource "random_pet" "second" {
#   length = 3
#   prefix = "${local.mys3}"
# }
#
# resource "aws_s3_bucket" "second" {
#   for_each = toset(["${lower(random_id.second.b64_url)}", "${random_pet.second.id}"])
#   bucket = each.key
#   force_destroy = true
# }
#
# resource "random_uuid" "third" {}
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
#     [try(lower(random_id.second[*].b64_url),[])],
#     [random_pet.second.id],
#     ["${local.mys3}-${random_uuid.third.result}"],
#     formatlist("%s-%s", local.mys3, values(data.external.third)[*].result.uuid_part)
#   )
# }
#
# locals {
#   s3_set = setunion([aws_s3_bucket.first.id],values(aws_s3_bucket.second)[*].id,values(aws_s3_bucket.third)[*].id)
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
