
# Create AWS EKS Cluster
resource "aws_eks_cluster" "eks_cluster" {
  name     = var.eks-clustername
  role_arn = aws_iam_role.eks_master_role.arn
  version = var.kubernetes-version

  vpc_config {
    subnet_ids = ["subnet-008c8fbf5b8f2b096","subnet-080eb5aa241e1a181"]
    endpoint_private_access = true
    endpoint_public_access  = false
   # public_access_cidrs     = ["54.84.221.22/32"]
    security_group_ids  = [aws_security_group.allow_lambda.id]
    
  }

 kubernetes_network_config {
    service_ipv4_cidr = "172.16.0.0/16"
  }

  
  # Enable EKS Cluster Control Plane Logging
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKSVPCResourceController,
    aws_iam_role_policy_attachment.eks-AmazonEKSECRResource
   
  ]
  timeouts {
    create = "15m"
  }

}

resource "aws_security_group" "allow_lambda" {
  name        = "lambdasg1"
  description = "Allow lambda inbound traffic"
  vpc_id      = var.vpc-id

  ingress {
    description      = "lambda from VPC"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
 
}
# Resource: EKS Fargate Profile
resource "aws_eks_fargate_profile" "kube_system" {
  cluster_name           = aws_eks_cluster.eks_cluster.id
  fargate_profile_name   = "fp-kube-system"
  pod_execution_role_arn = aws_iam_role.fargate_profile_role.arn
  subnet_ids = ["subnet-008c8fbf5b8f2b096","subnet-080eb5aa241e1a181"]
  selector {
    namespace = "kube-system"
    # Enable the below labels if we want only CoreDNS Pods to run on Fargate from kube-system namespace
    #labels = { 
    #  "k8s-app" = "kube-dns"
    #}
  }
}

# Resource: IAM Role for EKS Fargate Profile
resource "aws_iam_role" "fargate_profile_role" {
  name = "eks-fargate-profile-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks-fargate-pods.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

# Resource: IAM Policy Attachment to IAM Role
resource "aws_iam_role_policy_attachment" "eks_fargate_pod_execution_role_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate_profile_role.name
}

# Fargate Profile Role ARN Output
output "fargate_profile_iam_role_arn" {
  description = "Fargate Profile IAM Role ARN"
  value = aws_iam_role.fargate_profile_role.arn 
}



  

 


# Create IAM Role
resource "aws_iam_role" "eks_master_role" {
  name = "eks-master-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

# Associate IAM Policy to IAM Role
resource "aws_iam_role_policy_attachment" "eks-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_master_role.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_master_role.name
}
resource "aws_iam_role_policy_attachment" "eks-AmazonEKSECRResource" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_master_role.name
}


/*
# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "eks-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_master_role.name
}
*/

# The following Lambda resource fixes a CoreDNS issue on Fargate EKS clusters
 
data "archive_file" "bootstrap_archive" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda/python.zip"
}
 
resource "aws_security_group" "bootstrap" {
  
  name_prefix = "terraformeksclustersg" # Reference to EKS Cluster Name variable
  vpc_id      = var.vpc-id # Reference to VPC ID variable (VPC in which EKS Cluster is hosted)
 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
 
resource "aws_iam_role" "bootstrap" {
  name_prefix        = "terraformekscluster1" # Reference to EKS Cluster Name variable
  assume_role_policy = <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
JSON
}
 
resource "aws_iam_role_policy_attachment" "bootstrap" {
  role        = aws_iam_role.bootstrap.name
  policy_arn  = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
 
resource "aws_lambda_function" "bootstrap" {
  function_name    = "eksterraform-bootstrap"
  runtime          = "python3.7"
  handler          = "main.handler"
  role             = aws_iam_role.bootstrap.arn
  filename         = data.archive_file.bootstrap_archive.output_path
  source_code_hash = data.archive_file.bootstrap_archive.output_base64sha256
  timeout          = 120
 
  vpc_config {
  subnet_ids = ["subnet-008c8fbf5b8f2b096","subnet-080eb5aa241e1a181"]
    security_group_ids = [aws_security_group.bootstrap.id]
  }
}

data "aws_eks_cluster" "eks_cluster" {
 
  name = var.eks-clustername
   depends_on = [
    aws_eks_cluster.eks_cluster
  ]
}

data "aws_eks_cluster_auth" "eks-cluster-auth" {
  name = aws_eks_cluster.eks_cluster.id
}

data "aws_lambda_invocation" "bootstrap" {
  function_name = aws_lambda_function.bootstrap.function_name
  input = <<JSON
{
  "endpoint": "${data.aws_eks_cluster.eks_cluster.endpoint}",
  "token": "${data.aws_eks_cluster_auth.eks-cluster-auth.token}"
}
JSON
 
  depends_on = [aws_lambda_function.bootstrap,aws_eks_cluster.eks_cluster]
}

data "aws_lambda_invocation" "bootstrap1" {
  function_name = aws_lambda_function.bootstrap.function_name
  input = <<JSON
{
  "endpoint": "${data.aws_eks_cluster.eks_cluster.endpoint}",
  "token": "${data.aws_eks_cluster_auth.eks-cluster-auth.token}"
}
JSON
 
 depends_on = [aws_eks_fargate_profile.kube_system]
}



/* output "kubeconfig-certificate-authority-data" {
  value = data.aws_eks_cluster.eks_cluster.certificate_authority[0].data
}
 */

 resource "aws_iam_openid_connect_provider" "oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]
  url             = aws_eks_cluster.eks_cluster.identity.0.oidc.0.issuer
}

locals {
  oidc = {
    arn = aws_iam_openid_connect_provider.oidc.arn
    url = replace(aws_iam_openid_connect_provider.oidc.url, "https://", "")
    certificate = base64decode(aws_eks_cluster.eks_cluster.certificate_authority.0.data)
    endpoint = aws_eks_cluster.eks_cluster.endpoint
  }
}

provider "kubernetes" {
  host                   = aws_eks_cluster.eks_cluster.endpoint
  token                  = data.aws_eks_cluster_auth.eks-cluster-auth.token
  cluster_ca_certificate = local.oidc.certificate
}

