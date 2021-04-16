terraform {
  required_version = ">= 0.13.1"

  required_providers {
    aws        = ">= 3.22.0"
    kubernetes = "~> 1.11"
  }
}
