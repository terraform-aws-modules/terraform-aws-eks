terraform {
  required_version = ">= 1.3.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.7, < 3.0.0"
    }
  }
}
