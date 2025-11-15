resource "aws_iam_user" "first" {
  name = "tf-user"
  # path = "/system/"

  tags = {
    project = "training"
    env     = "dev"
  }
}

resource "aws_iam_access_key" "first" {
  user = aws_iam_user.first.name
}

# data "aws_iam_policy_document" "lb_ro" {
#   statement {
#     effect    = "Allow"
#     actions   = ["ec2:Describe*"]
#     resources = ["*"]
#   }
# }
#
# resource "aws_iam_user_policy" "lb_ro" {
#   name   = "test"
#   user   = aws_iam_user.lb.name
#   policy = data.aws_iam_policy_document.lb_ro.json
# }
