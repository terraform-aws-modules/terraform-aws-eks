terraform {
  required_version = ">= 0.13.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.56.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 1.4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 1.11.1"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = ">= 2.0.0"
    }
    http = {
      source  = "terraform-aws-modules/http"
      version = ">= 2.4.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 2.2.0"
    }
  }
}
