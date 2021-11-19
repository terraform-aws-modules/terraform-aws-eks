terraform {
  required_version = ">= 0.13.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
<<<<<<< HEAD
      version = ">= 3.64"
    }
    http = {
      source  = "terraform-aws-modules/http"
      version = ">= 2.4.1"
=======
      version = ">= 3.56"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 1.4"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 1.11.1"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 2.1"
>>>>>>> b876ff9 (fix: update CI/CD process to enable auto-release workflow (#1698))
    }
  }
}
