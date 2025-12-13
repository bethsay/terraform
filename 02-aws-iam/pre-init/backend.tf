locals {
  uuidv5_part = split("-", "${uuidv5("oid", var.s3_prefix)}")[0]
}

resource "aws_s3_bucket" "backend" {
  bucket        = "${var.s3_prefix}-${local.uuidv5_part}"
  force_destroy = var.bucket_force_destroy
  tags          = var.bucket_extra_tags
}

resource "aws_s3_bucket_versioning" "backend" {
  bucket = aws_s3_bucket.backend.id
  versioning_configuration {
    status = "Enabled"
  }
}

