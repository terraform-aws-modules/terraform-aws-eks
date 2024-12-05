terraform {
  required_version = ">= 1.3.2"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = ">= 2.4"
    }
  }
}
