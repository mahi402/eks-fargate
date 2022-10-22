# vpc

data "aws_vpc" "selected" {
  filter {
    name = "tag:Name"
    values = ["vpc-test-vpc"]
  }
}
# eks
module "eks" {
  source              = "./modules/eks-fargate"
  eks-clustername     = var.eks-cluster
  kubernetes-version  = var.kubernetes-version
  vpc-id              = data.aws_vpc.selected.id
 
}



/* module "irsa" {
  source             = "../modules/irsa"
  eks-fargate-cluster = var.eks-cluster
  kubernetes-namespace = var.kubenamespace
  kubernetes-serviceaccount = "eks-fargate-sa"
  policy_arns    = ["arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"]
  oidc_url       = module.eks.oidc.url
  oidc_arn       = module.eks.oidc.arn
  depends_on = [
    module.eks
  ]
} */

module "lbc-controller" {
  source   =  "./modules/aws-lbc-controller"
  eks-fargate-cluster = module.eks.clustername
  oidc_arn       = module.eks.oidc.arn
  oidc_url       = module.eks.oidc.url
  oidc_certificate = module.eks.oidc.certificate
  endpoint = module.eks.oidc.endpoint
  vpc-id           = data.aws_vpc.selected.id
  iam-fargate-role = module.eks.iam-fargate-role


}




