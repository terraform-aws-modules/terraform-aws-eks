terraform {
  required_version = ">= 0.13.1"

  required_providers {
    aws        = ">= 3.56.0"
    local      = ">= 1.4"
    random     = ">= 2.1"
    kubernetes = "~> 1.11"
  }
}
