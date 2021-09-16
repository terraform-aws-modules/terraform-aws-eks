terraform {
  required_version = ">= 0.13.1"

  required_providers {
    aws        = ">= 3.56.0"
    local      = ">= 1.4"
    kubernetes = ">= 1.11.1"
    cloudinit  = ">= 2.0"
    http = {
      source  = "terraform-aws-modules/http"
      version = ">= 2.4.1"
    }
  }
}
