user               = "tf-eks-admin"
console_access     = false
aws_policy_names   = ["AmazonEC2FullAccess", "AWSCloudFormationFullAccess", "IAMFullAccess", "AmazonElasticFileSystemFullAccess", "AmazonEC2ContainerRegistryFullAccess"]
custom_policy_name = "tf-EKSFullandSSMRead"
custom_policy = [
  {
    sid     = "EksFullAccess",
    actions = ["eks:*"],
  },
  {
    sid     = "SystemsManagerRead",
    actions = ["ssm:Describe*", "ssm:Get*", "ssm:List*", ],
  },
  {
    sid = "SecretsManagerFullAccess",
    actions = ["secretsmanager:*"],
  }
]
# #Credit : https://github.com/schoolofdevops/kubernetes-labguide/blob/master/chapters/eks_prep.md#required-iam-permissions
# custom_policy_name = "tf-eksadmin"
# custom_policy = [
#   {
#     sid       = "eksadmin",
#     actions   = [
#       "eks:*", "ec2:*", "cloudformation:*", "iam:*", "ecr:*", "s3:*",
#       "autoscaling:*", "cloudwatch:*", "elasticloadbalancing:*",
#       "sts:AssumeRole", "ssm:GetParameter", "ssm:DescribeParameters",
#       "kms:ListAliases", "kms:DescribeKey", "kms:CreateGrant", "kms:RetireGrant", "kms:RevokeGrant",
#     ],
#   },
# ]

# # Credit : https://github.com/eksctl-io/eksctl-docs/blob/main/docs/iam/minimum-iam-policies.adoc
# custom_policy_name = "tf-eksadmin"
# custom_policy = [
#   {
#     sid       = "EksAllAccess",
#     actions   = [ ],
#   },
# ]