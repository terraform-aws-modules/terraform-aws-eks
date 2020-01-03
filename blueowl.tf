# Changes made on top of the community module to fit BlueOwl needs and terragrunt configruation.

provider "aws" {
  region = var.aws_region
  profile = var.aws_profile
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}

  # The latest version of Terragrunt (v0.19.0 and above) requires Terraform 0.12.0 or above.
  required_version = ">= 0.12.2"
}

provider "random" {
  version = "~> 2.1"
}

provider "local" {
  version = "~> 1.2"
}

provider "null" {
  version = "~> 2.1"
}

provider "template" {
  version = "~> 2.1"
}

data "aws_eks_cluster" "cluster" {
  name = element(concat(aws_eks_cluster.this.*.id, list("")), 0)
}

data "aws_eks_cluster_auth" "cluster" {
  name = element(concat(aws_eks_cluster.this.*.id, list("")), 0)
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.10"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

resource "kubernetes_namespace" "datascience_namespace" {
  depends_on = [aws_eks_cluster.this]
  metadata {
    name = "datascience"
  }
}

resource "kubernetes_role_binding" "datascience_dev_admin_rolebinding" {
  depends_on = [aws_eks_cluster.this, kubernetes_namespace.datascience_namespace]

  metadata {
    name      = "allow-dev-admins"
    namespace = "datascience"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "admin"
  }
  subject {
    kind      = "Group"
    name      = "dev-admin"
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_namespace" "monitoring_namespace" {
  depends_on = [aws_eks_cluster.this]
  metadata {
    name = "monitoring"
  }
}

resource "kubernetes_priority_class" "monitoring_critical_priority_class" {
  depends_on = [kubernetes_namespace.monitoring_namespace]
  metadata {
    name = "log-node-critical"
  }
  value = 1000000
  global_default = false
  description = "These pods must be running to support logging"
}

resource "kubernetes_role" "monitoring_port_forwarding_role" {
  depends_on = [kubernetes_namespace.monitoring_namespace]
  metadata {
    name = "allow-port-forwarding"
    namespace = "monitoring"
  }

  rule {
    api_groups     = [""]
    resources      = ["pods", "pods/log", "pods/portforward"]
    verbs          = ["get", "list", "watch"]
  }
}

resource "kubernetes_role_binding" "dev_admin_rolebinding" {
  count = var.aws_profile == "production" ? 0 : 1
  depends_on = [kubernetes_role.monitoring_port_forwarding_role]
  metadata {
    name      = "allow-dev-admins"
    namespace = "monitoring"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "allow-port-forwarding"
  }
  subject {
    kind      = "Group"
    name      = "dev-admin"
    api_group = "rbac.authorization.k8s.io"
  }
}
