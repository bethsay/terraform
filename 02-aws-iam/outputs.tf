output "user_name" {
  value = aws_iam_user.first.id
}

output "user_arn" {
  value = aws_iam_user.first.arn
}

output "api_access" {
  value = one(aws_iam_access_key.first[*].id)
}

output "api_secret" {
  value = one(aws_iam_access_key.first[*].secret)
  sensitive = true
}

output "console_password" {
  value = one(aws_iam_user_login_profile.first[*].password)
  sensitive = true
}

locals {
  signin_url = format("https://%s.signin.aws.amazon.com/console", coalesce(data.external.account_alias.result.alias, data.aws_caller_identity.account_id.id))
  # signin_url = formatlist("https://%s.signin.aws.amazon.com/console", compact([data.external.account_alias.result.alias, data.aws_caller_identity.account_id.id]))
}

output "console_url" {
  value = local.signin_url
}

output "console_password_encrypted" {
  value = one(aws_iam_user_login_profile.first[*].encrypted_password)
  sensitive = true
}

output "api_secret_encrypted" {
  value = one(aws_iam_access_key.first[*].encrypted_secret)
  sensitive = true
}

