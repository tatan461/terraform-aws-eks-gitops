variable "aws_region" {
  type    = string
  default = "us-east-1" 
}

variable "cluster_name" {
  type    = string
  default = "production-eks-cluster"
}

variable "kubernetes_version" {
  type        = string
  description = "Versión estable y soportada de EKS"
  default     = "1.31" # Usamos 1.31 para evitar bloqueos de versiones obsoletas o futuras no soportadas
}