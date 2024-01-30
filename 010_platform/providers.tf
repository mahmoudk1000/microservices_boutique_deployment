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
    helm = {
      source = "hashicorp/helm"
      version = "2.12.1"
    }
  }
  backend "s3" {
    bucket  = "terraform-state-00-platform"
    key     = "aws/10_platform/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_eks_cluster" "cluster" {
  name = "boutique-prod"
}

data "aws_eks_cluster_auth" "cluster" {
  name = "boutique-prod"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.default.endpoint
    token                  = data.aws_eks_cluster_auth.default.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)
  }
}
