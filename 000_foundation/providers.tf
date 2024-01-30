terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.34.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = " 2.25.2"
    }
  }
  backend "s3" {
    bucket  = "terraform-state-00-foundation"
    key     = "aws/00_foundation/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-1"
}
  
provider "kubernetes" {
  host                    = module.eks_cluster.cluster_endpoint
  cluster_ca_certificate  = base64decode(module.eks_cluster.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = [ "eks", "get-token", "--cluster-name", module.eks_cluster.cluster_name ]
  }
}
