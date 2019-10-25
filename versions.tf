terraform {
  required_version = ">= 0.12.2"

  required_providers {
    aws      = ">= 2.31.0"
    local    = ">= 1.2"
    null     = ">= 2.1"
    template = ">= 2.1"
    random   = ">= 2.1"
  }
}
