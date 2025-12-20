output "user_name" {
  value = aws_iam_user.first.id
}

output "user_arn" {
  value = aws_iam_user.first.arn
}

output "api_access" {
  value = try(aws_iam_access_key.first[0].id ,null)
}

output "api_secret" {
  value = try(aws_iam_access_key.first[0].secret, null)
  sensitive = true
}

output "console_password" {
  value = try(aws_iam_user_login_profile.first[0].password, null)
  sensitive = true
}

output "console_url" {
  value = local.signin_url[*]
}

