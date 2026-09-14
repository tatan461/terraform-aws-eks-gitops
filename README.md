# 🏗️ AWS EKS Enterprise Platform with GitOps

Plataforma de Kubernetes empresarial en **AWS EKS** provisionada como código con **Terraform** y gestionada mediante **GitOps** con **ArgoCD**. Esta solución separa la infraestructura (IaC) de la gestión de aplicaciones (GitOps), permitiendo un ciclo de vida robusto, seguro y automatizado.

## 📋 Índice
1. [Arquitectura](#-arquitectura)
2. [Prerrequisitos](#-prerrequisitos)
3. [Estructura del Repositorio](#-estructura-del-repositorio)
4. [Inicio Rápido](#-inicio-rápido)
5. [Flujo de Trabajo GitOps](#-flujo-de-trabajo-gitops)
6. [Seguridad y Observabilidad](#-seguridad-y-observabilidad)

## 🏗️ Arquitectura

La plataforma sigue una topología de **Hub & Spoke** o mono-repo, donde **Terraform** gestiona la infraestructura de AWS y **ArgoCD** reconcilia el estado deseado del clúster.

*   **Infraestructura:** VPC, Subnets, EKS Cluster, Node Groups, IAM Roles y S3 State Backend.
*   **GitOps:** ArgoCD instalado vía Helm, configurado para sincronizar automáticamente los manifiestos de Kubernetes desde el repositorio.
*   **CI/CD:** Pipelines (GitHub Actions/GitLab CI) que construyen imágenes, ejecutan seguridad (Trivy/Checkov) y actualizan los manifiestos Helm en el repositorio de GitOps.

```mermaid
graph TD
    Dev[Developer] -->|Push Code| Git[GitHub/GitLab Repo]
    Git -->|Trigger| CI[CI Pipeline]
    CI -->|Build & Scan| ECR[Amazon ECR]
    CI -->|Update Helm Values| GitOpsRepo[GitOps Manifests]
    GitOpsRepo -->|Sync| Argo[ArgoCD]
    Argo -->|Reconcile| EKS[Amazon EKS Cluster]
    EKS -->|Expose| LB[AWS Load Balancer]

📋 Prerrequisitos
AWS CLI: Configurado con credenciales válidas (aws configure).
Terraform: Versión >= 1.11.0 (para soporte nativo de locking S3).
kubectl: Versión compatible con el clúster EKS (ej. 1.33).
Helm: Versión 3.x para la instalación de ArgoCD si se hace manual.
Git: Repositorio remoto accesible desde la red de AWS (VPC Endpoint o Internet Gateway).
📂 Estructura del Repositorio
eks-enterprise-platform/
├── terraform/                  # Infraestructura AWS
│   ├── modules/                # Módulos reutilizables (VPC, EKS, IAM)
│   ├── environments/           # Configuración por entorno (dev/staging/prod)
│   │   ├── dev/
│   │   │   ├── main.tf
│   │   │   └── terraform.tfvars
│   │   └── prod/
│   └── bootstrap/              # Setup inicial del backend S3/DynamoDB
├── gitops/                     # Manifiestos Kubernetes para ArgoCD
│   ├── infrastructure/         # ArgoCD App-of-Apps para plataforma
│   ├── apps/                   # Aplicaciones de negocio
│   └── kustomize/              # Overlays para entornos
├── .github/                    # Pipelines CI/CD
│   └── workflows/
│       ├── terraform.yaml      # Plan/Apply de Infraestructura
│       └── deploy.yaml         # Build de Apps y actualización GitOps
└── README.md

🚀 Inicio Rápido
1. Provisionar Infraestructura
Navega al entorno deseado (ej. dev) y ejecuta:

cd terraform/environments/dev

# Inicializar el backend S3 (si es la primera vez)
# cd ../../bootstrap && terraform init && terraform apply
# cd ../dev

# Inicializar y aplicar la infraestructura
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"

Nota: Terraform instalará automáticamente ArgoCD en el clúster EKS creado.

2. Configurar kubectl
aws eks update-kubeconfig --name <your-eks-cluster-name> --region <aws-region>

3. Verificar Instalación
# Verificar pods de ArgoCD
kubectl get pods -n argocd

# Obtener credenciales de ArgoCD
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d

🔄 Flujo de Trabajo GitOps
Una vez que el clúster está activo, Terraform termina su trabajo. La gestión continua se hace mediante Git:

Desarrollo: El desarrollador actualiza los manifiestos de la aplicación en gitops/apps/<app-name>.
Commit: Se hace push al repositorio.
Sincronización: ArgoCD detecta el cambio y sincroniza el estado deseado con el clúster EKS automáticamente.
Auto-Heal: Si alguien modifica el clúster manualmente, ArgoCD lo restaurará al estado definido en Git.
Para agregar una nueva aplicación, crea un Application manifest en gitops/apps/ apuntando al repo de tu aplicación:

apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: mi-app-empresa
  namespace: argocd
spec:
  project: default
  source:
    repoURL: 'https://github.com/org/mi-app.git'
    targetRevision: HEAD
    path: k8s/overlays/prod
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true

🛡️ Seguridad y Observabilidad
IAM Roles for Service Accounts (IRSA): Asignación granular de permisos AWS a pods de Kubernetes.
Secrets: Uso de External Secrets Operator o AWS Secrets Manager integrado con ArgoCD.
Observabilidad: Instalación automática de Prometheus, Grafana y CloudWatch Agent vía Helm Charts gestionados por ArgoCD.
Red: Subnets públicas y privadas, NAT Gateway y Control de acceso a endpoints públicos de EKS restringido por CIDR.