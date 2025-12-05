output "mys3_id_first"{
  value = try(aws_s3_bucket.first[0].id, null)
}

output "mys3_id_second"{
  value = try(aws_s3_bucket.second[0].id, null)
}

output "mys3_id_third"{
  # value = values(aws_s3_bucket.second)[*].id
  value = aws_s3_bucket.third[*].id
}

