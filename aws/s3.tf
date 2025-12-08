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
  # # for_each = local.mys3_id_map_third
  # # bucket = each.value
  # count = length(local.mys3_id_list_third)
  count = (var.suffix_type=="all") ? 2 : ((var.suffix_type=="words"||var.suffix_type=="string") ? 1 : 0)
  bucket = local.mys3_id_list_third[count.index]
  force_destroy = var.bucket_force_destroy
  tags = var.bucket_extra_tags
}

locals {
  # mys3_id_map_third = tomap({
  #   third_id = "${lower(replace(random_id.third.b64_url, "_", "-"))}"
  #   third_pet = "${random_pet.third.id}"
  # })
  # mys3_id_list_third = tolist([
  #   "${lower(replace(random_id.third.b64_url, "_", "-"))}",
  #   "${random_pet.third.id}",
  # ])
  mys3_id_list_third = compact(tolist([
    "${try(lower(replace(random_id.third[0].b64_url, "_", "-")), null)}",
    "${try(random_pet.third[0].id, null)}",
  ]))
}

resource "random_uuid" "fourth" {
  count = (var.suffix_type=="uuid"||var.suffix_type=="all") ? 1 : 0
}

locals {
  uuidv5_int = (var.suffix_type=="uuidv5_int"||var.suffix_type=="all") ? uuidv5("oid",var.mys3_prefix) : null
}

data "external" "fourth" {
  count = (var.suffix_type=="uuidv5_ext"||var.suffix_type=="all") ? 1 : 0
  program = [ "/bin/bash", "-c", "uuidgen -s -n @oid -N \"${var.mys3_prefix}\" | jq -R '{uuidv5_ext: .}'" ]
}

locals {
  suffix_list_fourth = compact(tolist([
    "${try(random_uuid.fourth[0].id, null)}",
    "${try(data.external.fourth[0].result.uuidv5_ext, local.uuidv5_int)}",
  ]))
}

resource "aws_s3_bucket" "fourth" {
  count = (var.suffix_type=="all") ? 2 : ((startswith(var.suffix_type, "uuid")) ? 1 : 0)
  bucket = "${local.mys3_prefix_hyphen}${local.suffix_list_fourth[count.index]}"
  force_destroy = var.bucket_force_destroy
  tags = var.bucket_extra_tags
}

locals {
  mys3_id_all = compact(setunion(
    [try(aws_s3_bucket.first[0].id, null)],
    [try(aws_s3_bucket.second[0].id, null)],
    aws_s3_bucket.third[*].id,
    aws_s3_bucket.fourth[*].id
  ))
}

resource "aws_s3_bucket_versioning" "all" {
  count = (var.bucket_versioning && var.suffix_type=="all") ? 5 : ( var.bucket_versioning ? 1 : 0)
  bucket = local.mys3_id_all[count.index]
  versioning_configuration {
    status = "Enabled"
  }
}
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
