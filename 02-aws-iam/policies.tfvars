aws_policy_names = ["IAMUserChangePassword"]
# aws_policy_names = ["AmazonEC2FullAccess", "AmazonS3FullAccess", "IAMFullAccess"]
custom_policy = [
{
  sid = "IAMselfModify",
  actions = ["iam:UpdateUser", "iam:TagUser", "iam:UntagUser"],
  resources = ["arn:aws:iam::*:user/&{aws:username}"],
},
{
  sid = "S3consoleListBuckets",
  actions = ["s3:ListAllMyBuckets"],
},
{
  sid = "S3exclusiveBackendBucket",
  actions = [
    "s3:CreateBucket", "s3:DeleteBucket*",
    "s3:ListBucket*", "s3:GetBucket*", "s3:PutBucket*",
    "s3:GetObject*", "s3:PutObject*", "s3:DeleteObject*",
    "s3:*LifecycleConfiguration", "s3:RestoreObject",
  ],
  resources = [
    "arn:aws:s3:::terraform-backend-58fd44e0",
    "arn:aws:s3:::terraform-backend-58fd44e0/*"
  ]
  condition = [
  { test = "StringEquals",
    variable = "aws:ResourceAccount",
    values = ["&{aws:PrincipalAccount}"],
  },
  { test = "StringEquals",
    variable = "aws:RequestedRegion",
    values = ["us-east-1"],
  },]
},
# {
#   sid = "S3sharedBackendBucket",
#   actions = ["s3:ListBucket", "s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
#   resources = [
#     "arn:aws:s3:::terraform-backend-58fd44e0",
#     "arn:aws:s3:::terraform-backend-58fd44e0/iam/terraform.tfstate",
#     "arn:aws:s3:::terraform-backend-58fd44e0/iam/terraform.tfstate.tflock",
#   ]
#   condition = [
#   { test = "StringEquals",
#     variable = "aws:ResourceAccount",
#     values = ["&{aws:PrincipalAccount}"],
#   },
#   { test = "StringEquals",
#     variable = "aws:RequestedRegion",
#     values = ["us-east-1"],
#   },]
# },
]
