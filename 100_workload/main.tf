resource "kubernetes_namespace_v1" "boutique" {
  metadata {
    name = "boutique"
  }
}

# https://github.com/GoogleCloudPlatform/microservices-demo.git
resource "kubernetes_manifest" "workload_chart" {
  manifest = yamldecode(<<YAML
  apiVersion: acgoproj.io/v1alpha1
  kind: Application
  metadata:
    name: boutique
    namespace: argocd
    annotations:
      argocd.argoproj.io/sync-wave: "0"
    finalizers:
      - resources-finalizer.argocd.argoproj.io
  spec:
    source:
      repoURL: us-docker.pkg.dev/online-botique-ci/charts
      chart: onlienboutique
      targetRevision: 0.8.1
      helm:
        releaseName: boutique
        values: |
          frontend:
            externalService: false
    destination:
      server: https://kubernetes.default.svc
      namespace: boutique
    project: default
    syncPolicy:
      automated:
        prune: true
        selfHeal: true
        allowEmpty: true
      syncOptions:
        - CreateNamespace=true
        - PrunePropagationPolicy=foreground
        - PruneLast=true
      retry:
        limit: 7
  YAML
  )

  depends_on = [ kubernetes_namespace_v1.boutique ]
}

resource "kubernetes_ingress_v1" "frontend" {
  metadata {
    name        = "frontend"
    namespace   = "boutique"
    annotations = {
      "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
    }
  }
  spec {
    ingress_class_name = "nginx"

    tls {
      hosts = [ "mahmoudk1000.me" ]
      secret_name = "mahmoudk1000-me-tls"
    }

    rule {
      host = "mahmoudk1000.me"
      http {
        path {
          backend {
            service_name = "frontend"
            port {
              number = 80
            }
          }
        }
      }
    }
  }

  depends_on = [ kubernetes_manifest.workload_chart, kubernetes_namespace_v1.boutique ]
}

# Dummy app don't use secret, but this just to show off how to use it
resource "kubernetes_manifest" "cluster_secret_store" {
  manifest = yamldecode(<<YAML
  apiVersion: external-secrets.io/v1beta1
  kind: ExternalSecret
  metadata:
    name: boutique-custom-secret
    namespace: boutique
  spec:
    refreshInterval: 1h
    secretStoreRef:
      kind: ClusterSecretStore
      namespace: aws-store
    target:
      name: boutique-custom-secret
    date:
      - secretKey: THE_ANWER
        remoteRef:
          key: boutique-prod-k8s-platform-show-off
  YAML
  )
  
  depends_on = [ kubernetes_namespace_v1.boutique ]
}
