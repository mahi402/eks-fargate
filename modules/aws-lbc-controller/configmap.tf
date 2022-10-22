/* # Get AWS Account ID
data "aws_caller_identity" "current" {}
output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

data "aws_iam_role" "fargate-role" {
  name = var.iam-fargate-role.name
}


# Sample Role Format: arn:aws:iam::180789647333:role/hr-dev-eks-nodegroup-role
# Locals Block
locals {
  configmap_roles = [
     {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${data.aws_iam_role.fargate-role.name}"
      #rolearn =    "${data.aws_iam_role.fargate-role.arn}"
      username = "system:node:{{SessionName}}"
      groups   = ["system:bootstrappers", "system:nodes","system:node-proxier"]
    }, 
       {
      #rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.eks_nodegroup_role.name}"
      rolearn = "${aws_iam_role.lbc_iam_role.arn}"      
      username = "system:node:{{SessionName}}"
      groups   = ["system:bootstrappers", "system:nodes","system:node-proxier"]
    }
  ]

  
}
# Resource: Kubernetes Config Map
resource "kubernetes_config_map_v1" "aws_auth" {

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
  data = {
    mapRoles = yamlencode(local.configmap_roles)
         
  }  
}
 */