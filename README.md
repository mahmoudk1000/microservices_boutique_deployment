# Microservices Demo Deployment

## Demo App

**Online Boutique** is a cloud-first [Microservices-demo](https://github.com/GoogleCloudPlatform/microservices-demo) application. The application is a web-based e-commerce app where users can browse items, add them to the cart, and purchase them.

Google uses this application to demonstrate the use of technologies like Kubernetes, GKE, Istio, Stackdriver, and gRPC. This application works on any Kubernetes cluster, like Google Kubernetes Engine (GKE). It’s easy to deploy with little to no configuration.

### Architecture

**Online Boutique** is composed of 11 microservices written in different languages that talk to each other over gRPC.

![Architecture diagram of demo app, showing the 11 service and the communication in between](https://github.com/GoogleCloudPlatform/microservices-demo/blob/main/docs/img/architecture-diagram.png)

## 00 Foundations

- VPC
- Subnets
- IAM
- DNS
- Cluster
- NAT

## 05/10 Platform

1. Gateway/Ingress (Ingress Nginx)
2. Secret Management (External Secret Operator)
3. Certificate Management (Cert Manager)
4. Continuous Delivery (ArgoCD)
5. Cluster Autoscaling

## 20 Observability

1. Visualization (Grafana)
2. Logging (Grafana Loki)
3. Metrics (Prometheus)
4. Auto-Instrument Tracing (Pixie)
5. Tracing (Grafana Tempo & Open Telemetry)

## 30 Resilience

1. Volume Backup (Native Cloud Backups | Longhorn | Velero)
2. Api/etcd Backups (Velero)

## 40 FinOps

1. Event-driven Autoscalling (KEDA)
2. Optimized Cluster Autoscalling (Karpenter)
3. Cost Monitoring (Open Cost)

## 50 Security

1. Configuration Security (Kyverno)
2. Image Security (Trivy)
3. Cloud Security Posture (Prowler)
4. CIS Benchmarks (Trivy)
5. Service Mesh (Cilium)
6. Runtime Monitoring (Falco)
7. MicroVM Isolation (Firecracker)

## 60 Developer Self-Service

1. Workflows & Runbooks (Argo Workflows)
2. Service Catalog

## 70 IaaS Management

1. Cloud Resource (Crossplane)
2. DNS (External DNS)
3. Cluster Fleet (Cluster API & Gardener)

## 80 Container Optimized OS

1. AWS (Bottelrocket)
2. Anywhere (Fedora CoreOS)
