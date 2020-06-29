terraform {
  required_version = ">= 0.12.0"
  required_providers {
    aws        = ">= 2.28.1"
    kubernetes = "~> 1.11"
    random     = "~> 2.1"
    local      = "~> 1.2"
    template   = "~> 2.1"
  }
}

provider "aws" {
  region = var.region
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.11"
}
