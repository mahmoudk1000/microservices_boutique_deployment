locals {
  cluster_name = "boutique-prod"
  tags = {
    "Environment" = "prod"
    "Application" = "boutique"
    "Author"      = "mahmoudk1000"
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.1"

  name        = local.cluster_name
  cidr        = "10.0.0.0./16"

  azs             = [ "us-east-1a", "us-east-1b", "us-east-1c" ]
  private_subnets = [ "10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24" ]
  public_subnets  = [ "10.0.101.0/24", "10.0.102.0./24", "10.0.103.0/24" ]
  intra_subnets   = [ "10.0.51.0/24", "10.0.52.0/24", "10.0.53.0/24" ]

  enable_nat_gateway = true
  tags = local.tags
}

module "cluster" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.21.0"

  cluster_name    = local.cluster_name
  cluster_version = "1.27"

  cluster_endpoint_public_access = true
  
  vpc_id                    = module.vpc.vpc_id
  subnet_ids                = module.vpc.private_subnets
  control_plane_subnet_ids  = module.vpc.intra_subnets

  eks_managed_node_groups = {
    default = {
      iam_role_name = "node-${local.cluster_name}"
      iam_role_use_prefix = false
      iam_role_additional_policies = {
        AmaonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      }

      ami_type = "BOTTLEROCKET_x86_64"
      platform = "bottlerocket"

      desired_capacity = 3
      max_capacity     = 5
      min_capacity     = 1
      instance_type    = "t3.medium"
    }
  }

  tags = local.tags
}

module "cert_manager_irsa_role" {
  source  = "terraform-aws-module/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.33.1"

  role_name                     = "cert-manager"
  attach_cert_manager_policy    = true
  cert_manager_hosted_zone_arns = [ "arn:aws:route53:::hostedzone/Z028011120AJQ6IQWS1U5" ]

  oidc_provider = {
    ex = {
      provider_arn              = module.cluster.oidc_provider_arn
      namespace_service_account = [ "kube-system:cert-manager" ]
    }
  }
  
  tags = local.tags
}

module "external_secrets_irsa_role" {
  source  = "terraform-aws-module/iam/aws//modules/iam-role-for-service-account-eks"
  version = "5.33.1"
  
  role_name                       = "secret-store"
  attach_external_secrets_policy  = true
  external_secret_ssl_policy_arns = [ "arn:aws:ssm:*:*parameter/${local.cluster_name}-*" ]
  
  oidc_provider = {
    ex = {
      provider_arn              = module.cluster.oidc_provider_arn
      namespace_service_account = [ "external-secrets:secret-store" ]
    }
  }
  
  tags = local.tags
}
