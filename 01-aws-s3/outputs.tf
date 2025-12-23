output "mys3_id_first" {
  # value = aws_s3_bucket.first.id
  value = one(aws_s3_bucket.first[*].id)
}

output "mys3_id_second" {
  # value = aws_s3_bucket.second.id
  value = one(aws_s3_bucket.second[*].id)
}

output "mys3_id_third" {
  # # value = values(aws_s3_bucket.second)[*].id
  # value = aws_s3_bucket.third[*].id
  value = length(aws_s3_bucket.third) > 0 ? aws_s3_bucket.third[*].id : null
}

output "mys3_id_fourth" {
  value = length(aws_s3_bucket.fourth) > 0 ? aws_s3_bucket.fourth[*].id : null
}

output "mys3_id_all" {
  value = local.mys3_id_all
}
