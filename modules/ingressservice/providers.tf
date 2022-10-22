# Terraform AWS Provider Block
provider "aws" {
  region = "us-east-1"
}



data "aws_eks_cluster_auth" "cluster" {
  name = var.eks-fargate-cluster
}

# Terraform Kubernetes Provider
provider "kubernetes" {
  host = var.endpoint
  cluster_ca_certificate = var.oidc_certificate
  token = data.aws_eks_cluster_auth.cluster.token
}