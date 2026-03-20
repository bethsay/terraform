resource "aws_iam_user" "first" {
  # name          = "tf-user"
  # # path          = "/dev/"
  name          = var.user
  path          = var.user_path
  force_destroy = var.user_force_destroy
}

resource "aws_iam_access_key" "first" {
  count   = var.api_access ? 1 : 0
  user    = aws_iam_user.first.name
  pgp_key = try(filebase64(var.encryption_key), "")
}

resource "local_file" "api_access" {
  count    = (var.encryption_key == "" && var.api_access) ? 1 : 0
  filename = "${pathexpand("~/.aws/tf-creds")}/${aws_iam_user.first.id}_accessKeys.csv"
  content  = <<EOT
User Name,Access key ID,Secret access key
${aws_iam_user.first.id},${one(aws_iam_access_key.first[*].id)},${one(aws_iam_access_key.first[*].secret)}
EOT
}

resource "aws_iam_user_login_profile" "first" {
  count                   = var.console_access ? 1 : 0
  user                    = aws_iam_user.first.name
  password_reset_required = true
  pgp_key                 = try(filebase64(var.encryption_key), "")
}

data "aws_caller_identity" "account_id" {}

# data "aws_iam_account_alias" "account_alias" {}  #tfPlan Error expected when alias does not exist
data "external" "account_alias" {
  program = ["/bin/bash", "-c", "aws iam list-account-aliases | jq '{id : .AccountAliases[0]}'"]
}

locals {
  signin_url = format("https://%s.signin.aws.amazon.com/console", coalesce(
    data.external.account_alias.result.id,
    data.aws_caller_identity.account_id.id
  ))
  # signin_url = formatlist("https://%s.signin.aws.amazon.com/console", compact([
  #   data.external.account_alias.result.id,
  #   data.aws_caller_identity.account_id.id
  # ]))
}

resource "local_file" "console_access" {
  count    = (var.encryption_key == "" && var.console_access) ? 1 : 0
  filename = "${pathexpand("~/.aws/tf-creds")}/${aws_iam_user.first.id}_credentials.csv"
  content  = <<EOT
User Name,Password,Console sign-in URL
${aws_iam_user.first.id},${one(aws_iam_user_login_profile.first[*].password)},${local.signin_url}
EOT
}

resource "aws_iam_user_policy_attachment" "aws_policy" {
  user = aws_iam_user.first.id
  # policy_arn = "arn:aws:iam::aws:policy/IAMUserChangePassword"
  count      = length(var.aws_policy_names)
  policy_arn = data.aws_iam_policy.aws_policy[count.index].arn
}

data "aws_iam_policy" "aws_policy" {
  count = length(var.aws_policy_names)
  name  = var.aws_policy_names[count.index]
}

resource "aws_iam_user_policy" "inline_policy" {
  user = aws_iam_user.first.name
  # # name   = "tf-IAMreadAll"
  # # policy = data.aws_iam_policy_document.read_all.json
  # name   = "tf-IAMselfManage"
  name   = var.custom_policy_name
  policy = data.aws_iam_policy_document.inline_policy.json
}

data "aws_iam_policy_document" "read_all" {
  statement {
    sid       = "IAMreadAll"
    actions   = ["iam:Get*", "iam:List*", "iam:GenerateServiceLastAccessedDetails", "iam:GenerateCredentialReport", "iam:Simulate*Policy"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "api_security" {
  count = var.api_access ? 1 : 0
  statement {
    sid       = "IAMselfAPIsecurity"
    actions   = ["iam:*AccessKey", "iam:*SSHPublicKey", "iam:*ServiceSpecificCredentials", "iam:*SigningCertificate"]
    resources = [aws_iam_user.first.arn]
  }
}

data "aws_iam_policy_document" "console_security" {
  count = var.console_access ? 1 : 0
  statement {
    sid       = "IAMselfConsoleSecurity"
    actions   = ["iam:*LoginProfile", "iam:ChangePassword", "iam:*MFADevice"]
    resources = [aws_iam_user.first.arn, "arn:aws:iam::${data.aws_caller_identity.account_id.id}:mfa/${aws_iam_user.first.name}*"]
  }
}

data "aws_iam_policy_document" "inline_policy" {
  source_policy_documents = concat(
    [data.aws_iam_policy_document.read_all.json],
    data.aws_iam_policy_document.api_security[*].json,
    data.aws_iam_policy_document.console_security[*].json,
  )
  dynamic "statement" {
    # for_each = var.custom_policy
    for_each = local.custom_policy
    content {
      sid       = statement.value.sid
      effect    = statement.value.effect
      actions   = statement.value.actions
      resources = statement.value.resources
      dynamic "condition" {
        for_each = statement.value.condition
        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }
}

locals {
  custom_policy = [
    for stmt in var.custom_policy : merge(stmt, {
      resources = [
        # for res in stmt.resources : replace(res, "TF_ACCOUNT_ID", data.aws_caller_identity.account_id.id)
        for res in stmt.resources : templatestring(res, {
          tf_account_id = data.aws_caller_identity.account_id.id
          tf_user_name  = aws_iam_user.first.id
          tf_user_arn   = aws_iam_user.first.arn
        })
      ]
      condition = [
        for cond in lookup(stmt, "condition", []) : merge(cond, {
          values = [
            for val in cond.values : templatestring(val, {
              tf_account_id = data.aws_caller_identity.account_id.id
            })
          ]
        })
      ]
      }
    )
  ]
}
