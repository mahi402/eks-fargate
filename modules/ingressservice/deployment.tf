# Kubernetes Deployment Manifest
resource "kubernetes_deployment_v1" "myapp3" {
  metadata {
    name = "app3-nginx-deployment"
    labels = {
      app = "app3-nginx"
    }
  } 
 
  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "app3-nginx"
      }
    }

    template {
      metadata {
        labels = {
          app = "app3-nginx"
        }
      }

      spec {
        container {
          image = "013896206397.dkr.ecr.us-east-1.amazonaws.com/mahi402ecr:latest"
          name  = "app3-nginx"
          port {
            container_port = 80
          }
          }
        }
      }
    }
}