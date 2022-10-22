variable "eks-fargate-cluster" {
    type = string
}

variable "oidc_arn" {
    type = any
}
variable "oidc_url" {
    type = any
}

variable "oidc_certificate" {
    type = any
}

variable "endpoint" {
    type = string
}
variable "vpc-id" {
    type = string
}

variable "iam-fargate-role" {
    type = any
  
}