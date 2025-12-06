output "mys3_id_first"{
  # value = aws_s3_bucket.first.id
  value = try(aws_s3_bucket.first[0].id, null)
}

output "mys3_id_second"{
  # value = aws_s3_bucket.second.id
  value = try(aws_s3_bucket.second[0].id, null)
}

output "mys3_id_third"{
  # # value = values(aws_s3_bucket.second)[*].id
  # value = aws_s3_bucket.third[*].id
  value = length(aws_s3_bucket.third)>0 ? aws_s3_bucket.third[*].id : null
}

