variable "kubernetes-namespace" {
  description = "Kubernetes Namespace name"
  type        = string
}

variable "kubernetes-serviceaccount" {
  description = "Should the module create the Service Account"
  type        = string
  default     = true
}

variable "eks-fargate-cluster" {
    type = string
}



variable "path" {
  description = "The path for role"
  type        = string
  default     = "/"
}


### security
variable "policy_arns" {
  description = "A list of policy ARNs to attach the role"
  type        = list(string)
  default     = []
}

variable "oidc_url" {
    type = any
  
}

variable "oidc_arn" {
    type = any
}
