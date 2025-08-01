provider "aws" {
  region = local.region
}

locals {
  name   = "ex-${basename(path.cwd)}"
  region = "us-west-2"

  tags = {
    Test       = local.name
    GithubRepo = "terraform-aws-eks"
    GithubOrg  = "terraform-aws-modules"
  }
}

################################################################################
# Hybrid Node IAM Module
################################################################################

# Default (SSM)
module "eks_hybrid_node_role" {
  source = "../../modules/hybrid-node-role"

  policy_statements = [
    {
      actions = [
        "s3:Get*",
        "s3:List*",
      ]
      resources = ["*"]
    }
  ]

  tags = local.tags
}

# IAM Roles Anywhere
module "ira_eks_hybrid_node_role" {
  source = "../../modules/hybrid-node-role"

  name = "${local.name}-ira"

  enable_ira = true

  ira_trust_anchor_source_type           = "CERTIFICATE_BUNDLE"
  ira_trust_anchor_x509_certificate_data = local.cert_data

  tags = local.tags
}

module "disabled_eks_hybrid_node_role" {
  source = "../../modules/hybrid-node-role"

  create = false
}

################################################################################
# Supporting Resources
################################################################################

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_self_signed_cert" "example" {
  private_key_pem = tls_private_key.example.private_key_pem

  subject {
    common_name  = "Custom root"
    organization = "ACME Examples, Inc"
  }

  validity_period_hours = 17544
  is_ca_certificate     = true

  allowed_uses = [
    "cert_signing",
  ]
}

locals {
  cert_data = trimspace(replace(trimprefix(tls_self_signed_cert.example.cert_pem, "-----BEGIN CERTIFICATE-----"), "-----END CERTIFICATE-----", ""))
}
