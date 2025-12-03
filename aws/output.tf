output "mys3_id_first"{
  value = aws_s3_bucket.first.id
}

output "mys3_id_second"{
  value = values(aws_s3_bucket.second)[*].id
  # value = aws_s3_bucket.second[*].id
}

