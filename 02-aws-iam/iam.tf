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

resource "aws_iam_user_policy_attachment" "aws_policy" {
  user       = aws_iam_user.first.id
  # policy_arn = "arn:aws:iam::aws:policy/IAMUserChangePassword"
  count = length(var.aws_policy_names)
  policy_arn = data.aws_iam_policy.aws_policy[count.index].arn
}

data "aws_iam_policy" "aws_policy" {
  count = length(var.aws_policy_names)
  name     = var.aws_policy_names[count.index]
}

resource "aws_iam_user_policy" "inline_policy" {
  user        = aws_iam_user.first.name
  name        = "IAMreadAll"
  policy      = data.aws_iam_policy_document.read_all.json
  # name        = "IAMselfAndS3backendViaTerraform"
  # policy      = data.aws_iam_policy_document.inline_policy.json
}

data "aws_iam_policy_document" "read_all" {
  statement {
    sid = "IAMreadAll"
    actions = ["iam:Get*", "iam:List*", "iam:GenerateServiceLastAccessedDetails", "iam:GenerateCredentialReport", "iam:Simulate*Policy"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "api_security" {
  count = var.api_access ? 1 : 0
  statement {
    sid = "IAMselfAPIsecurity"
    actions = ["iam:*AccessKey", "iam:*SSHPublicKey", "iam:*ServiceSpecificCredentials", "iam:*SigningCertificate"]
    # resources = ["arn:aws:iam::<account_id>:user/<user_name>"]
    # resources = ["arn:aws:iam::${data.aws_caller_identity.first.account_id}:user/${aws_iam_user.first.name}"]
    resources = [aws_iam_user.first.arn]
    # resources = ["arn:aws:iam::*:user/&{aws:username}"]
    # resources = ["arn:aws:iam::${data.aws_caller_identity.first.account_id}:user/&{aws:username}"]
  }
}

data "aws_iam_policy_document" "console_security" {
  count = var.console_access ? 1 : 0
  statement {
    sid = "IAMselfConsoleSecurity"
    actions = ["iam:*LoginProfile", "iam:ChangePassword", "iam:*MFADevice" ]
    # resources = ["arn:aws:iam::<account_id>:user/<user_name>"]
    # resources = [aws_iam_user.first.arn, "arn:aws:iam::*:mfa/*"]
    # resources = ["arn:aws:iam::*:user/&{aws:username}", "arn:aws:iam::*:mfa/&{aws:username}*"]
    resources = ["arn:aws:iam::${data.aws_caller_identity.account_id.id}:user/&{aws:username}", "arn:aws:iam::${data.aws_caller_identity.account_id.id}:mfa/&{aws:username}*"]
  }
}

data "aws_iam_policy_document" "inline_policy" {
  source_policy_documents = concat(
    [data.aws_iam_policy_document.read_all.json],
    data.aws_iam_policy_document.api_security[*].json,
    data.aws_iam_policy_document.console_security[*].json,
  )
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
  dynamic "statement" {
    for_each = var.custom_policy
    content {
      sid = statement.value.sid
      effect = statement.value.effect
      actions = statement.value.actions
      resources = statement.value.resources
      dynamic "condition" {
        for_each = statement.value.condition
        content {
          test = condition.value.test
          variable = condition.value.variable
          values = condition.value.values
        }
      }
    }
  }
  # statement {
  #   sid = "S3listBucketNames"
  #   actions = [ "s3:ListAllMyBuckets" ]
  #   resources = ["*"]
  #   condition {
  #     test = "StringLike"
  #     variable = "aws:ResourceAccount"
  #     values = [data.aws_caller_identity.first.account_id]
  #   }
  # }
  # statement {
  #   sid = "S3backendDedicatedBucket"
  #   actions = [
  #     "s3:CreateBucket", "s3:DeleteBucket*", "s3:ListBucket*", "s3:GetBucket*", "s3:PutBucket*", "s3:UpdateBucket*",
  #     "s3:GetObject*", "s3:PutObject*", "s3:DeleteObject*", "s3:RestoreObject",
  #     "s3:GetLifecycleConfiguration", "s3:PutLifecycleConfiguration"
  #   ]
  #   # resources = ["arn:aws:<aws_service>:<aws_region>:<account_id>:<aws_resource_type>/<path>/<aws_resource_name>"]
  #   resources = ["arn:aws:s3:::terraform-backend-58fd44e0", "arn:aws:s3:::terraform-backend-58fd44e0/*"]
  #   condition {
  #     test = "StringLike"
  #     variable = "aws:RequestedRegion"
  #     values = ["us-east-1"]
  #   }
  #   condition {
  #     test = "StringLike"
  #     variable = "aws:ResourceAccount"
  #     values = [data.aws_caller_identity.first.account_id]
  #   }
  # }
  # statement {
  #   sid = "S3backendSharedBucket"
  #   actions = ["s3:ListBucket", "s3:GetObject", "s3:PutObject", "s3:DeleteObject" ]
  #   # resources = ["arn:aws:<aws_service>:<aws_region>:<account_id>:<aws_resource_type>/<path>/<aws_resource_name>"]
  #   resources = [
  #     "arn:aws:s3:::terraform-backend-58fd44e0",
  #     "arn:aws:s3:::terraform-backend-58fd44e0/iam/terraform.tfstate",
  #     "arn:aws:s3:::terraform-backend-58fd44e0/iam/terraform.tfstate.tflock"
  #   ]
  #   condition {
  #     test = "StringLike"
  #     variable = "aws:RequestedRegion"
  #     values = ["us-east-1"]
  #   }
  #   condition {
  #     test = "StringLike"
  #     variable = "aws:ResourceAccount"
  #     values = [data.aws_caller_identity.first.account_id]
  #   }
  # }
  # statement {
  #   sid = "IAMselfModify"
  #   actions = ["iam:UpdateUser", "iam:TagUser", "iam:UntagUser"]
  #   resources = [aws_iam_user.first.arn]
  # }
}

