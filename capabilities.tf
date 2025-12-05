################################################################################
# Capabilities
################################################################################

resource "aws_eks_capability" "example" {
  for_each = var.create && var.capabilities != null ? var.capabilities : {}

  capability_name = each.value.capability_name
  cluster_name    = aws_eks_cluster.this[0].id

  dynamic "configuration" {
    for_each = each.value.configuration != null ? [each.value.configuration] : []

    content {
      dynamic "argo_cd" {
        for_each = configuration.value.argo_cd != null ? [configuration.value.argo_cd] : []

        content {
          dynamic "aws_idc" {
            for_each = [argo_cd.value.aws_idc]

            content {
              idc_instance_arn = aws_idc.value.idc_instance_arn
              idc_region       = aws_idc.value.idc_region
            }
          }

          namespace = argo_cd.value.namespace

          dynamic "network_access" {
            for_each = argo_cd.value.network_access != null ? [argo_cd.value.network_access] : []

            content {
              vpce_ids = network_access.value.vpce_ids
            }
          }

          dynamic "rbac_role_mapping" {
            for_each = argo_cd.value.rbac_role_mapping != null ? argo_cd.value.rbac_role_mapping : []

            content {
              dynamic "identity" {
                for_each = rbac_role_mapping.value.identity

                content {
                  id   = identity.value.id
                  type = identity.value.type
                }
              }

              role = rbac_role_mapping.value.role
            }
          }
        }
      }
    }
  }

  delete_propagation_policy = each.value.delete_propagation_policy
  role_arn                  = each.value.role_arn
  type                      = each.value.type

  dynamic "timeouts" {
    for_each = each.value.timeouts != null ? [each.value.timeouts] : []

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      update = timeouts.value.update
    }
  }

  tags = var.tags
}
