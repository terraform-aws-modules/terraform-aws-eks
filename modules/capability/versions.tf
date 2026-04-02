terraform {
  required_version = ">= 1.5.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.28"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9"
    }
  }

  provider_meta "aws" {
    user_agent = [
      "github.com/terraform-aws-modules/terraform-aws-eks"
    ]
  }
}
