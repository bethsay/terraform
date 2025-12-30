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

data "aws_iam_policy_document" "second" {
  # statement {
  #   sid = "USeastContainers"
  #   actions = ["eks:*", "ecs:*", "ecr:*"]
  #   resources = ["*"]
  #   condition {
  #     test = "StringEquals"
  #     variable = "aws:RequestedRegion"
  #     values = ["us-east-1", "us-east-2"]
  #   }
  # }
  statement {
    sid = "IAMsecurityConsole"
    actions = ["iam:*LoginProfile", "iam:ChangePassword", "iam:*MFADevice" ]
    # resources = ["arn:aws:iam::<account_id>:user/<user_name>"]
    # resources = [aws_iam_user.first.arn]
    # resources = ["arn:aws:iam::*:user/&{aws:username}"]
    resources = ["arn:aws:iam::${data.aws_caller_identity.first.account_id}:user/&{aws:username}", "arn:aws:iam::${data.aws_caller_identity.first.account_id}:mfa/&{aws:username}"]
  }
  statement {
    sid = "IAMselfUpdate"
    actions = ["iam:UpdateUser", "iam:TagUser", "iam:UntagUser", "iam:RemoveUserFromGroup"]
    # resources = ["arn:aws:iam::<account_id>:user/<user_name>"]
    resources = [aws_iam_user.first.arn]
    # resources = ["arn:aws:iam::*:user/&{aws:username}"]
    # resources = ["arn:aws:iam::${data.aws_caller_identity.first.account_id}:user/&{aws:username}"]
  }
  statement {
    sid = "IAMsecurityAPI"
    actions = ["iam:*AccessKey", "iam:*SSHPublicKey", "iam:*ServiceSpecificCredentials", "iam:*SigningCertificate"]
    # resources = ["arn:aws:iam::<account_id>:user/<user_name>"]
    resources = [aws_iam_user.first.arn]
    # resources = ["arn:aws:iam::*:user/&{aws:username}"]
    # resources = ["arn:aws:iam::${data.aws_caller_identity.first.account_id}:user/&{aws:username}"]
  }
  statement {
    sid = "IAMreadAll"
    actions = ["iam:Get*", "iam:List*", "iam:GenerateServiceLastAccessedDetails", "iam:GenerateCredentialReport", "iam:Simulate*Policy"]
    resources = ["*"]
    # resources = ["arn:aws:iam::<account_id>:user/<user_name>"]
    # resources = [aws_iam_user.first.arn,]
    # resources = ["arn:aws:iam::&{aws:PrincipalAccount}:user/&{aws:username}"]
  }
}

resource "aws_iam_user_policy" "second" {
  user        = aws_iam_user.first.name
  name        = "IAMuserMax"
  policy      = data.aws_iam_policy_document.second.json
}

