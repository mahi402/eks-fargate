# Define Local Values in Terraform
locals {
  owners = "pge"
  environment = "dev"
  name = "dev-lbc-controller"
  common_tags = {
    owners = local.owners
    environment = local.environment
  }
  eks-cluster-name = "${var.eks-fargate-cluster}"  
} 