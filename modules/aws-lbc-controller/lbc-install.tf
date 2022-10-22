# Install AWS Load Balancer Controller using HELM

# Resource: Helm Release 
resource "helm_release" "loadbalancer_controller" {

        
   
  name       = "aws-load-balancer-controller"

  #repository = "${path.module}/helm"
  repository =  "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"

  namespace = "kube-system"     

  # Value changes based on your Region (Below is for us-east-1)
  set {
    name = "image.repository"
    value = "602401143452.dkr.ecr.us-east-1.amazonaws.com/amazon/aws-load-balancer-controller" 
    # Changes based on Region - This is for us-east-1 Additional Reference: https://docs.aws.amazon.com/eks/latest/userguide/add-ons-images.html
  }       

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "irsa-lbc-sa"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = "${aws_iam_role.lbc_iam_role.arn}"
  }

  set {
    name  = "vpcId"
    value = var. vpc-id
  }  

  set {
    name  = "region"
    value = "us-east-1"
  }    

  set {
    name  = "clusterName"
    value = var.eks-fargate-cluster
  }    
  
  
}
