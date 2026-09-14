markdown

Copiar
# AWS EKS Enterprise Platform with GitOps (ArgoCD & Terraform)

A production-grade, highly available Amazon EKS cluster provisioned entirely via Terraform, featuring automated continuous deployment using ArgoCD for declarative GitOps workflows.

Infrastructure fully provisioned as code (IaC) with modular Terraform components.

## Architecture Overview

- **GitOps Continuous Delivery:** ArgoCD continuously monitors this repository and automatically synchronizes the cluster state with the desired application manifests.
- **VPC & Networking:** Custom multi-AZ Virtual Private Cloud with public and private subnets, ensuring secure network isolation and high availability.
- **Compute (EKS):** Scalable Amazon EKS cluster managed via Terraform with robust worker node groups distributed across availability zones.

## Project Structure

```text
terraform-aws-eks-gitops/
├── terraform/
│   ├── main.tf       # Provider configurations and required versions
│   ├── variables.tf  # Input variables (cluster name, version, region)
│   ├── vpc.tf        # Network architecture module
│   ├── eks.tf        # EKS cluster and managed node group definitions
│   └── outputs.tf    # Post-deployment outputs (endpoint, kubeconfig command)
└── k8s/
    └── argocd/
        └── application.yaml # Declarative ArgoCD application manifest
Quick Start Guide
1. Provision Infrastructure
Navigate into the terraform directory and apply the configuration:

bash

Copiar
cd terraform
terraform init
terraform apply -auto-approve
2. Configure Kubectl
Update your local kubeconfig to target the new cluster (replace <your-region> and <cluster-name>):

bash

Copiar
aws eks update-kubeconfig --region <your-region> --name <cluster-name>
3. Install ArgoCD & Deploy via GitOps
Install ArgoCD using server-side apply and register the application manifest contained in this repo:

bash

Copiar
kubectl create namespace argocd
kubectl apply --server-side -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -f ../k8s/argocd/application.yaml
Accessing ArgoCD
Once deployed, you can access the ArgoCD UI. Retrieve the initial admin password:

bash

Copiar
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
Teardown (Cleanup)
To delete all created AWS resources and avoid unexpected charges:

Remove the GitOps application from the cluster:

bash

Copiar
kubectl delete -f k8s/argocd/application.yaml
Destroy the Terraform infrastructure:

bash

Copiar
cd terraform
terraform destroy -auto-approve