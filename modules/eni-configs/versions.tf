###############################################################################
# Provider Versions
###############################################################################
terraform {
  required_version = "~> 1.3"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.18.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">=4.57.0"
    }
  }
}
