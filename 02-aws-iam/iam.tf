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
  pgp_key                 = try(filebase64(var.encryption_key), "")
}

resource "aws_iam_user_login_profile" "first" {
  count = var.console_access ? 1 : 0
  user                    = aws_iam_user.first.name
  password_reset_required = true
  pgp_key                 = try(filebase64(var.encryption_key), "")
}

data "aws_caller_identity" "first" {}

# data "aws_iam_account_alias" "first" {}  #tfPlan Error expected when alias does not exist
data "external" "account_alias" {
  program = ["/bin/bash", "-c", "aws iam list-account-aliases | jq '{alias : .AccountAliases[0]}'"]
}

resource "aws_iam_user_policy_attachment" "first" {
  user       = aws_iam_user.first.id
  # policy_arn = "arn:aws:iam::aws:policy/IAMUserChangePassword"
  count = length(var.aws_policy_names)
  policy_arn = data.aws_iam_policy.first[count.index].arn
}

data "aws_iam_policy" "first" {
  count = length(var.aws_policy_names)
  name     = var.aws_policy_names[count.index]
}

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
