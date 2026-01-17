resource "aws_s3_bucket" "first" {
  # bucket = "tf-bucket"
  bucket        = var.mys3_prefix
  force_destroy = var.bucket_force_destroy
  tags          = var.bucket_extra_tags
  count         = var.suffix_type == "none" ? 1 : 0
}

resource "aws_s3_bucket" "second" {
  # bucket_prefix =  "tf-bucket-"
  # force_destroy = true
  # tags = { another = "temp", env = "temp" }
  bucket_prefix = local.mys3_prefix_hyphen
  force_destroy = var.bucket_force_destroy
  tags          = var.bucket_extra_tags
  count         = (var.suffix_type == "time" || var.suffix_type == "all") ? 1 : 0
}

locals { mys3_prefix_hyphen = "${var.mys3_prefix}-" }

resource "random_id" "third" {
  byte_length = var.suffix_string_length
  prefix      = local.mys3_prefix_hyphen
  count       = (var.suffix_type == "string" || var.suffix_type == "all") ? 1 : 0
}

resource "random_pet" "third" {
  length = var.suffix_word_count
  prefix = var.mys3_prefix
  count  = (var.suffix_type == "words" || var.suffix_type == "all") ? 1 : 0
}

resource "aws_s3_bucket" "third" {
  # # # for_each = toset([lower(replace(random_id.third.b64_url, "_", "-")), random_pet.third.id])
  # # # bucket = each.key
  # # for_each = local.mys3_id_map_third
  # # bucket = each.value
  # count = length(local.mys3_id_list_third)
  count         = (var.suffix_type == "all") ? 2 : ((var.suffix_type == "words" || var.suffix_type == "string") ? 1 : 0)
  bucket        = local.mys3_id_list_third[count.index]
  force_destroy = var.bucket_force_destroy
  tags          = var.bucket_extra_tags
}

locals {
  # mys3_id_map_third = tomap({
  #   third_id = lower(replace(random_id.third.b64_url, "_", "-"))
  #   third_pet = random_pet.third.id
  # })
  # mys3_id_list_third = tolist([
  #   lower(replace(random_id.third.b64_url, "_", "-")),
  #   random_pet.third.id,
  # ])
  mys3_id_list_third = compact(tolist([
    try(lower(replace(random_id.third[0].b64_url, "_", "-")), null),
    one(random_pet.third[*].id),
  ]))
  # mys3_count_all = 1 + 2   # time+(words+string)
}

resource "random_uuid" "fourth" {
  count = (var.suffix_type == "uuid" || var.suffix_type == "all") ? 1 : 0
}

locals {
  uuidv5_int = (var.suffix_type == "uuidv5_int" || var.suffix_type == "all") ? uuidv5("oid", var.mys3_prefix) : null
}

data "external" "fourth" {
  count   = (var.suffix_type == "uuidv5_ext" || var.suffix_type == "all") ? 1 : 0
  program = ["/bin/bash", "-c", "uuidgen -s -n @oid -N \"${var.mys3_prefix}\" | jq -R '{uuidv5_ext: .}'"]
}

locals {
  suffix_list_fourth = compact(tolist([
    one(random_uuid.fourth[*].id),
    try(data.external.fourth[0].result.uuidv5_ext, local.uuidv5_int),
  ]))
}

resource "aws_s3_bucket" "fourth" {
  count         = (var.suffix_type == "all") ? 2 : ((startswith(var.suffix_type, "uuid")) ? 1 : 0)
  bucket        = "${local.mys3_prefix_hyphen}${local.suffix_list_fourth[count.index]}"
  force_destroy = var.bucket_force_destroy
  tags          = var.bucket_extra_tags
}

locals {
  mys3_count_all = 1 + 2 + 2 # time+(words+string)+(uuid+uuidv5_int)
  mys3_id_all = compact(tolist(setunion(
    [one(aws_s3_bucket.first[*].id)],
    [one(aws_s3_bucket.second[*].id)],
    aws_s3_bucket.third[*].id,
    aws_s3_bucket.fourth[*].id
  )))
  bucket_versioning_count = (var.bucket_versioning && var.suffix_type == "all") ? local.mys3_count_all : (var.bucket_versioning ? 1 : 0)
}

resource "aws_s3_bucket_versioning" "all" {
  count  = local.bucket_versioning_count
  bucket = local.mys3_id_all[count.index]
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "all" {
  count = local.bucket_versioning_count
  bucket = local.mys3_id_all[count.index]
  rule {
    id = "VersionCleanup"
    filter {}
    noncurrent_version_expiration {
      noncurrent_days = 1
      newer_noncurrent_versions = var.version_limit
    }
    status = "Enabled"
  }
}

locals {
  bucket_upload_set   = setproduct(local.mys3_id_all, var.bucket_upload)
  bucket_upload_max   = (local.mys3_count_all) * (length(var.bucket_upload))
  bucket_upload_count = (length(var.bucket_upload) > 0 && var.suffix_type == "all") ? local.bucket_upload_max : length(var.bucket_upload)
}

resource "aws_s3_object" "all" {
  count  = local.bucket_upload_count
  bucket = local.bucket_upload_set[count.index][0]
  key    = "preload/${basename(local.bucket_upload_set[count.index][1])}"
  source = local.bucket_upload_set[count.index][1]
}

locals {
  mys3_arn_all = compact(tolist(setunion(
    [one(aws_s3_bucket.first[*].arn)],
    [one(aws_s3_bucket.second[*].arn)],
    aws_s3_bucket.third[*].arn,
    aws_s3_bucket.fourth[*].arn
  )))
  bucket_lock_count = (var.bucket_lock && var.suffix_type == "all") ? local.mys3_count_all : (var.bucket_lock ? 1 : 0)
  lock_bypass_arn = flatten([
    "arn:aws:iam::${data.aws_caller_identity.bucket_owner.account_id}:root",
    data.aws_caller_identity.bucket_owner.arn,
    data.aws_iam_user.lock_bypass_username[*].arn,
    var.lock_bypass_arn,
  ])
}

resource "aws_s3_bucket_policy" "all" {
  count = local.bucket_lock_count
  bucket = local.mys3_id_all[count.index]
  policy = data.aws_iam_policy_document.deny_others[count.index].json
}

data "aws_iam_policy_document" "deny_others" {
  count = local.bucket_lock_count
  statement {
    sid = "LockedBucketWithExceptions"
    principals {
      type = "*"
      identifiers = ["*"]
    }
    actions = [ "s3:Delete*", "s3:Put*", "s3:GetObject", "s3:GetObjectVersion" ]
    resources = [ local.mys3_arn_all[count.index], "${local.mys3_arn_all[count.index]}/*" ]
     condition {
       test = "StringNotEquals"
       variable = "aws:PrincipalArn"
       values = local.lock_bypass_arn
     }
  }
}

data "aws_caller_identity" "bucket_owner" {}

data "aws_iam_user" "lock_bypass_username" {
  count = length(var.lock_bypass_username)
  user_name = var.lock_bypass_username[count.index]
}

