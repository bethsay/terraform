user = "tf-eks-admin"
console_access = false
aws_policy_names = ["AmazonEC2FullAccess", "AWSCloudFormationFullAccess", "IAMFullAccess"]
custom_policy_name = "tf-EKSFullandSSMRead"
custom_policy = [
  {
    sid       = "EksAllAccess",
    actions   = ["eks:*"],
  },
  {
    sid       = "SystemsManagerRead",
    actions   = ["ssm:Describe*", "ssm:Get*", "ssm:List*",],
  },
]
