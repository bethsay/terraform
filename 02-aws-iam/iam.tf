resource "aws_iam_user" "first" {
  # name = "tf-user"
  # # path = "/dev/"
  name = var.user
  path = var.user_path
  force_destroy = var.user_force_destroy
}

resource "aws_iam_access_key" "first" {
  count = var.api_access ? 1 : 0
  user = aws_iam_user.first.name
}

resource "aws_iam_user_login_profile" "first" {
  count = var.console_access ? 1 : 0
  user                    = aws_iam_user.first.name
  # pgp_key                 = "keybase:your_keybase_username" # Replace with your Keybase username
  # password_reset_required = true
}

# data "aws_iam_account_alias" "first" {}

data "aws_caller_identity" "first" {}

locals {
  # signin_url = format("https://%s.signin.aws.amazon.com/console", try(data.aws_iam_account_alias.first.id, data.aws_caller_identity.first.id))
  signin_url = format("https://%s.signin.aws.amazon.com/console", data.aws_caller_identity.first.id)
}
# resource "aws_iam_user_policy_attachment" "first" {
#   user       = aws_iam_user.first.name
#   policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
# }
#
# locals {
#   policy_arns = [
#     "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess",
#     "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
#   ]
# }
#
# resource "aws_iam_user_policy_attachment" "second" {
#   for_each   = toset(local.policy_arns)
#   user       = aws_iam_user.first.name
#   policy_arn = each.key
# }
#
# locals {
#   policy_names = toset([
#     "AmazonEC2FullAccess",
#     "AmazonS3FullAccess",
#     "AmazonRDSFullAccess",
#   ])
# }
#
# data "aws_iam_policy" "third" {
#   for_each = local.policy_names
#   name     = each.key
# }
#
# resource "aws_iam_user_policy_attachment" "third" {
#   user       = aws_iam_user.first.name
#   for_each   = local.policy_names
#   policy_arn = data.aws_iam_policy.third["${each.key}"].arn
# }
#
# # resource "aws_iam_user_policy_attachment" "third-v2" {
# #   user       = aws_iam_user.first.name
# #   for_each   = toset([for pol in data.aws_iam_policy.third : pol.arn])
# #   policy_arn = each.key
# # }
#
# data "aws_iam_policy_document" "fourth" {
#   statement {
#     sid = "USeastContainers"
#     actions = ["eks:*", "ecs:*", "ecr:*"]
#     resources = ["*"]
#     condition {
#       test = "StringEquals"
#       variable = "aws:RequestedRegion"
#       values = ["us-east-1", "us-east-2"]
#     }
#   }
#   statement {
#     sid = "IAMself"
#     actions = ["iam:*"]
#     resources = ["arn:aws:iam::${data.aws_caller_identity.fourth.account_id}:user/${aws_iam_user.first.name}"]
#   }
# }
#
# resource "aws_iam_user_policy" "fourth" {
#   user        = aws_iam_user.first.name
#   name        = "USeastContainers"
#   policy      = data.aws_iam_policy_document.fourth.json
# }
#
