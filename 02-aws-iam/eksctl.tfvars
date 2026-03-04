user = "tf-eks-admin"
console_access = false
# aws_policy_names = ["AmazonEKSClusterPolicy", "AmazonEC2FullAccess", "AWSCloudFormationFullAccess", "IAMFullAccess"]
aws_policy_names = ["AmazonEC2FullAccess", "AWSCloudFormationFullAccess", "IAMFullAccess"]
custom_policy_name = "tf-EKSFullAccess"
custom_policy = [
  {
    sid       = "EksAllAccess",
    actions   = ["eks:*"],
  },
]
