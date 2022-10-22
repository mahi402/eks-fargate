output "oidc" {
  description = "The OIDC provider attributes for IAM Role for ServiceAccount"
  value = zipmap(
    ["url", "arn","certificate","endpoint"],
    [local.oidc["url"], local.oidc["arn"],local.oidc["certificate"],local.oidc["endpoint"]]
  )
}

output "clustername" {

  value = data.aws_eks_cluster.eks_cluster.name
  
}

output "iam-fargate-role" {
  value = aws_iam_role.fargate_profile_role
  
}