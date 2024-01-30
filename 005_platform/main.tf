resource "helm_release" "eso" {
  name      = "external-secrets-operator"
  namespace = "external-secrets-operator"
  
  repository  = "https://external-secrets.github.io"
  chart       = "external-secrets"
  version     = "0.9.11"

  timeout           = 300
  atomic            = true
  create_namespace  = true
}

resource "helm_release" "cert-manager" {
  name      = "cert-manager"
  namespace = "cert-manager"
  
  repository  = "https://charts.jetstack.io"
  chart       = "cert-manager"
  version     = "1.13.3"
  
  timeout           = 300
  atomic            = true
  create_namespace  = true

  values = [
    <<YAML
      installCRDs: true
    YAML
  ]
}

resource "helm_release" "ingress-nginx" {
  name      = "ingress-nginx"
  namespace = "ingress-nginx"
  
  repository  = "https://kubernetes.github.io/ingress-nginx"
  chart       = "ingress-nginx"
  version     = "3.24.0"
  
  timeout           = 300
  atomic            = true
  create_namespace  = true

  values = [
    <<YAML
    podSecurityContext:
      runAsNoonRoot: true
    service:
      enableHttp: true
      enableHttps: true
      annotations:
        service.beta.kubernetes.io/aws-load-balancer-type: nlb
    YAML
  ]
}

resource "helm_release" "argocd" {
  name      = "argocd"
  namespace = "argocd"

  repository  = "https://argoproj.github.io/argo-helm"
  chart       = "argo-cd"
  version     = "5.53.9"

  timeout           = 300
  atomic            = true
  create_namespace  = true

  values = [
    <<YAML
      nameOverride: argocd
      redis-ha:
        enabled: true
      controller:
        replicas: 1
      server:
        replicas: 1
      repo-server:
        replicas: 1
      applicationSet:
        replicas: 1
    YAML
  ]
}
