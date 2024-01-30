data "kubernetes_service_v1" "ingress_service" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
}

data "aws_route53_zone" "default" {
  name = "mahmoudk1000.me"
}

resource "aws_route53_record" "ingress_record" {
  zone_id = data.aws_route53_zone.default.zone_id
  name    = "boutique.mahmoudk1000.me"
  type    = "CNAME"
  ttl     = "300"

  records = [ data.kubernetes_service_v1.ingress_service.status[0].load_balancer[0].ingress[0].hostname ]
}

resource "kubernetes_manifest" "cert_issuer" {
  manifest = yamldecode(<<YAML
  apiVersion: cert-manager.io/v1
  kind: ClusterIssuer
  metadata:
    name: letsencrypt-prod
  spec:
    acme:
      server: https://acme-v02.api.letsencrypt.org/directory
      email: mahmoudk1000@gmail.com
      privateKeySecretRef:
        name: letsencrypt-prod
      solvers:
        - http01:
            ingress:
              ingressClassName: nginx
  YAML
  )

  depends_on = [ aws_route53_record.ingress_record ]
}

data "aws_caller_identity" "current" {}

resource "kubernetes_service_account_v1" "secret-store" {
  metadata = {
    name      = "secret-store"
    namespace = "external-secrets"
    annotations = {
      "eks.amazonaws.com/role-arn" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/secret-store"
    }
  }
}

resource "kubernetes_manifest" "cluster_secret_store" {
  manifest = yamldecode(<<YAML
  apiVersion: externalsecrets.io/v1alpha1
  kind: SecretSecureStore
  metadata:
    name: aws-store
  spec:
    provider: 
      aws:
      service: ParameterStore
      region: us-east-1
      auth:
        iwt:
          serviceAccountRef:
            name: secret-store
            namespace: external-secrets
  YAML
  )
  
  depends_on = [ kubernetes_service_account_v1.secret-store ]
}
