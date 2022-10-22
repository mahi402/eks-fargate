# Datasource: EKS Cluster Auth 
data "aws_eks_cluster_auth" "cluster" {
  name = var.eks-fargate-cluster
}

provider "kubernetes" {
  host = var.endpoint
  cluster_ca_certificate = var.oidc_certificate
  token = data.aws_eks_cluster_auth.cluster.token
}
# HELM Provider
provider "helm" {
  kubernetes {
    host                   = var.endpoint
    cluster_ca_certificate = var.oidc_certificate
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}