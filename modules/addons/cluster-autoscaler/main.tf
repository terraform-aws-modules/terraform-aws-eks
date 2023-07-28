################################################################################
# Cluster Autoscaler
################################################################################
locals {
  image_tag = coalesce(
    var.image_tag,
    var.cluster_version == "1.24" ? "v1.24.2" : "",
    var.cluster_version == "1.25" ? "v1.25.2" : "",
    var.cluster_version == "1.26" ? "v1.26.3" : "",
    var.cluster_version == "1.27" ? "v1.27.2" : "",
  )

  helm_release_version = coalesce(
    var.helm_release_version,
    var.cluster_version == "1.24" ? "9.29.1" : "",
    var.cluster_version == "1.25" ? "9.29.1" : "",
    var.cluster_version == "1.26" ? "9.29.1" : "",
    var.cluster_version == "1.27" ? "9.29.1" : "",
  )
  helm_chart_full_name = "aws-cluster-autoscaler"
}

data "aws_region" "current" {}

resource "time_sleep" "this" {
  count = var.install ? 1 : 0

  create_duration = var.time_wait
}

module "irsa_role" {
  count = var.install ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.3"

  role_name                        = var.irsa_role_name != "" ? var.irsa_role_name : "cluster-autoscaler-${var.cluster_name}"
  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_ids   = [var.cluster_name]

  oidc_providers = {
    ex = {
      provider_arn               = var.cluster_oidc_provider_arn
      namespace_service_accounts = ["${var.namespace}:${local.helm_chart_full_name}"]
    }
  }

  tags = var.tags
}

# Reference: https://artifacthub.io/packages/helm/cluster-autoscaler/cluster-autoscaler
resource "helm_release" "this" {
  count = var.install ? 1 : 0

  depends_on = [
    time_sleep.this,
  ]

  namespace        = var.namespace
  create_namespace = false

  name              = "cluster-autoscaler"
  repository        = "https://kubernetes.github.io/autoscaler"
  chart             = "cluster-autoscaler"
  version           = local.helm_release_version
  dependency_update = true

  set {
    name  = "image.tag"
    value = local.image_tag
  }
  set {
    name  = "autoDiscovery.clusterName"
    value = var.cluster_name
  }
  set {
    name  = "awsRegion"
    value = data.aws_region.current.name
  }
  set {
    name  = "cloudProvider"
    value = "aws"
  }
  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.irsa_role[0].iam_role_arn
  }

  values = [
    yamlencode({
      replicaCount = "2"
      updateStrategy = {
        type = "RollingUpdate"
        rollingUpdate = {
          maxUnavailable = "1"
        }
      }
      extraArgs = {
        expander = "least-waste"
      }
      affinity = {
        podAntiAffinity = {
          requiredDuringSchedulingIgnoredDuringExecution = [
            {
              labelSelector = {
                matchLabels = {
                  "app.kubernetes.io/name" = local.helm_chart_full_name
                }
              }
              namespaces  = [var.namespace]
              topologyKey = "kubernetes.io/hostname"
            }
          ]
        }
      }
    }), var.helm_release_values
  ]
}
