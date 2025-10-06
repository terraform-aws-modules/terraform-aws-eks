data "aws_partition" "current" {
  count = local.create ? 1 : 0
}
data "aws_caller_identity" "current" {
  count = local.create ? 1 : 0
}

data "aws_iam_session_context" "current" {
  count = local.create ? 1 : 0

  # This data source provides information on the IAM source role of an STS assumed role
  # For non-role ARNs, this data source simply passes the ARN through issuer ARN
  # Ref https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2327#issuecomment-1355581682
  # Ref https://github.com/hashicorp/terraform-provider-aws/issues/28381
  arn = try(data.aws_caller_identity.current[0].arn, "")
}

locals {
  create = var.create && var.putin_khuylo

  account_id = try(data.aws_caller_identity.current[0].account_id, "")
  partition  = try(data.aws_partition.current[0].partition, "")

  role_arn = try(aws_iam_role.this[0].arn, var.iam_role_arn)

  create_outposts_local_cluster = var.outpost_config != null
  enable_encryption_config      = var.encryption_config != null && !local.create_outposts_local_cluster

  create_auto_mode_iam_resources = try(var.compute_config.enabled, false) == true || var.create_auto_mode_iam_resources
}

################################################################################
# Cluster
################################################################################

resource "aws_eks_cluster" "this" {
  count = local.create ? 1 : 0

  region = var.region

  name                          = var.name
  role_arn                      = local.role_arn
  version                       = var.kubernetes_version
  enabled_cluster_log_types     = var.enabled_log_types
  deletion_protection           = var.deletion_protection
  bootstrap_self_managed_addons = false
  force_update_version          = var.force_update_version

  access_config {
    authentication_mode = var.authentication_mode

    # See access entries below - this is a one time operation from the EKS API.
    # Instead, we are hardcoding this to false and if users wish to achieve this
    # same functionality, we will do that through an access entry which can be
    # enabled or disabled at any time of their choosing using the variable
    # var.enable_cluster_creator_admin_permissions
    bootstrap_cluster_creator_admin_permissions = false
  }

  dynamic "compute_config" {
    for_each = var.compute_config != null ? [var.compute_config] : []

    content {
      enabled       = compute_config.value.enabled
      node_pools    = compute_config.value.node_pools
      node_role_arn = compute_config.value.node_pools != null ? try(aws_iam_role.eks_auto[0].arn, compute_config.value.node_role_arn) : null
    }
  }

  vpc_config {
    security_group_ids      = compact(distinct(concat(var.additional_security_group_ids, [local.security_group_id])))
    subnet_ids              = coalescelist(var.control_plane_subnet_ids, var.subnet_ids)
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.endpoint_public_access_cidrs
  }

  dynamic "kubernetes_network_config" {
    # Not valid on Outposts
    for_each = local.create_outposts_local_cluster ? [] : [1]

    content {
      dynamic "elastic_load_balancing" {
        for_each = var.compute_config != null ? [var.compute_config] : []

        content {
          enabled = elastic_load_balancing.value.enabled
        }
      }

      ip_family         = var.ip_family
      service_ipv4_cidr = var.service_ipv4_cidr
      service_ipv6_cidr = var.service_ipv6_cidr
    }
  }

  dynamic "outpost_config" {
    for_each = local.create_outposts_local_cluster ? [var.outpost_config] : []

    content {
      control_plane_instance_type = outpost_config.value.control_plane_instance_type

      dynamic "control_plane_placement" {
        for_each = outpost_config.value.control_plane_placement != null ? [outpost_config.value.control_plane_placement] : []

        content {
          group_name = control_plane_placement.value.group_name
        }
      }

      outpost_arns = outpost_config.value.outpost_arns
    }
  }

  dynamic "encryption_config" {
    # Not available on Outposts
    for_each = local.enable_encryption_config ? [var.encryption_config] : []

    content {
      provider {
        key_arn = var.create_kms_key ? module.kms.key_arn : encryption_config.value.provider_key_arn
      }
      resources = encryption_config.value.resources
    }
  }

  dynamic "remote_network_config" {
    # Not valid on Outposts
    for_each = var.remote_network_config != null && !local.create_outposts_local_cluster ? [var.remote_network_config] : []

    content {
      dynamic "remote_node_networks" {
        for_each = [remote_network_config.value.remote_node_networks]

        content {
          cidrs = remote_node_networks.value.cidrs
        }
      }

      dynamic "remote_pod_networks" {
        for_each = remote_network_config.value.remote_pod_networks != null ? [remote_network_config.value.remote_pod_networks] : []

        content {
          cidrs = remote_pod_networks.value.cidrs
        }
      }
    }
  }

  dynamic "storage_config" {
    for_each = var.compute_config != null ? [var.compute_config] : []

    content {
      block_storage {
        enabled = storage_config.value.enabled
      }
    }
  }

  dynamic "upgrade_policy" {
    for_each = var.upgrade_policy != null ? [var.upgrade_policy] : []

    content {
      support_type = upgrade_policy.value.support_type
    }
  }

  dynamic "zonal_shift_config" {
    for_each = var.zonal_shift_config != null ? [var.zonal_shift_config] : []

    content {
      enabled = zonal_shift_config.value.enabled
    }
  }

  tags = merge(
    { terraform-aws-modules = "eks" },
    var.tags,
    var.cluster_tags,
  )

  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []

    content {
      create = var.timeouts.create
      update = var.timeouts.update
      delete = var.timeouts.delete
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.this,
    aws_security_group_rule.cluster,
    aws_security_group_rule.node,
    aws_cloudwatch_log_group.this,
    aws_iam_policy.cni_ipv6_policy,
  ]

  lifecycle {
    ignore_changes = [
      access_config[0].bootstrap_cluster_creator_admin_permissions,
      bootstrap_self_managed_addons,
    ]
  }
}

resource "aws_ec2_tag" "cluster_primary_security_group" {
  # This should not affect the name of the cluster primary security group
  # Ref: https://github.com/terraform-aws-modules/terraform-aws-eks/pull/2006
  # Ref: https://github.com/terraform-aws-modules/terraform-aws-eks/pull/2008
  for_each = { for k, v in merge(var.tags, var.cluster_tags) :
    k => v if local.create && k != "Name" && var.create_primary_security_group_tags
  }

  region = var.region

  resource_id = aws_eks_cluster.this[0].vpc_config[0].cluster_security_group_id
  key         = each.key
  value       = each.value
}

resource "aws_cloudwatch_log_group" "this" {
  count = local.create && var.create_cloudwatch_log_group ? 1 : 0

  region = var.region

  name              = "/aws/eks/${var.name}/cluster"
  retention_in_days = var.cloudwatch_log_group_retention_in_days
  kms_key_id        = var.cloudwatch_log_group_kms_key_id
  log_group_class   = var.cloudwatch_log_group_class

  tags = merge(
    var.tags,
    var.cloudwatch_log_group_tags,
    { Name = "/aws/eks/${var.name}/cluster" }
  )
}

################################################################################
# Access Entry
################################################################################

locals {
  # This replaces the one time logic from the EKS API with something that can be
  # better controlled by users through Terraform
  bootstrap_cluster_creator_admin_permissions = { for k, v in {
    cluster_creator = {
      principal_arn = try(data.aws_iam_session_context.current[0].issuer_arn, "")
      type          = "STANDARD"

      policy_associations = {
        admin = {
          policy_arn = "arn:${local.partition}:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  } : k => v if var.enable_cluster_creator_admin_permissions }

  # Merge the bootstrap behavior with the entries that users provide
  merged_access_entries = merge(
    local.bootstrap_cluster_creator_admin_permissions,
    var.access_entries,
  )

  # Flatten out entries and policy associations so users can specify the policy
  # associations within a single entry
  flattened_access_entries = flatten([
    for entry_key, entry_val in local.merged_access_entries : [
      for pol_key, pol_val in entry_val.policy_associations :
      merge(
        {
          principal_arn = entry_val.principal_arn
          entry_key     = entry_key
          pol_key       = pol_key
        },
        { for k, v in {
          association_policy_arn              = pol_val.policy_arn
          association_access_scope_type       = pol_val.access_scope.type
          association_access_scope_namespaces = try(pol_val.access_scope.namespaces, null)
        } : k => v if !contains(["EC2_LINUX", "EC2_WINDOWS", "FARGATE_LINUX", "HYBRID_LINUX"], lookup(entry_val, "type", "STANDARD")) },
      )
    ]
  ])
}

resource "aws_eks_access_entry" "this" {
  for_each = { for k, v in local.merged_access_entries : k => v if local.create }

  region = var.region

  cluster_name      = aws_eks_cluster.this[0].id
  kubernetes_groups = try(each.value.kubernetes_groups, null)
  principal_arn     = each.value.principal_arn
  type              = try(each.value.type, null)
  user_name         = try(each.value.user_name, null)

  tags = merge(
    var.tags,
    try(each.value.tags, {}),
  )
}

resource "aws_eks_access_policy_association" "this" {
  for_each = { for k, v in local.flattened_access_entries : "${v.entry_key}_${v.pol_key}" => v if local.create }

  region = var.region

  access_scope {
    namespaces = each.value.association_access_scope_namespaces
    type       = each.value.association_access_scope_type
  }

  cluster_name = aws_eks_cluster.this[0].id

  policy_arn    = each.value.association_policy_arn
  principal_arn = each.value.principal_arn

  depends_on = [
    aws_eks_access_entry.this,
  ]
}

################################################################################
# KMS Key
################################################################################

module "kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "4.0.0" # Note - be mindful of Terraform/provider version compatibility between modules

  create = local.create && var.create_kms_key && local.enable_encryption_config # not valid on Outposts

  region = var.region

  description             = coalesce(var.kms_key_description, "${var.name} cluster encryption key")
  key_usage               = "ENCRYPT_DECRYPT"
  deletion_window_in_days = var.kms_key_deletion_window_in_days
  enable_key_rotation     = var.enable_kms_key_rotation

  # Policy
  enable_default_policy     = var.kms_key_enable_default_policy
  key_owners                = var.kms_key_owners
  key_administrators        = coalescelist(var.kms_key_administrators, [try(data.aws_iam_session_context.current[0].issuer_arn, "")])
  key_users                 = concat([local.role_arn], var.kms_key_users)
  key_service_users         = var.kms_key_service_users
  source_policy_documents   = var.kms_key_source_policy_documents
  override_policy_documents = var.kms_key_override_policy_documents

  # Aliases
  aliases = var.kms_key_aliases
  computed_aliases = {
    # Computed since users can pass in computed values for cluster name such as random provider resources
    cluster = { name = "eks/${var.name}" }
  }

  tags = merge(
    { terraform-aws-modules = "eks" },
    var.tags,
  )
}

################################################################################
# Cluster Security Group
# Defaults follow https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html
################################################################################

locals {
  security_group_name   = coalesce(var.security_group_name, "${var.name}-cluster")
  create_security_group = local.create && var.create_security_group

  security_group_id = local.create_security_group ? aws_security_group.cluster[0].id : var.security_group_id

  # Do not add rules to node security group if the module is not creating it
  cluster_security_group_rules = { for k, v in {
    ingress_nodes_443 = {
      description                = "Node groups to cluster API"
      protocol                   = "tcp"
      from_port                  = 443
      to_port                    = 443
      type                       = "ingress"
      source_node_security_group = true
    }
  } : k => v if local.create_node_sg }
}

resource "aws_security_group" "cluster" {
  count = local.create_security_group ? 1 : 0

  region = var.region

  name        = var.security_group_use_name_prefix ? null : local.security_group_name
  name_prefix = var.security_group_use_name_prefix ? "${local.security_group_name}${var.prefix_separator}" : null
  description = var.security_group_description
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    { "Name" = local.security_group_name },
    var.security_group_tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "cluster" {
  for_each = { for k, v in merge(
    local.cluster_security_group_rules,
    var.security_group_additional_rules
  ) : k => v if local.create_security_group }

  region = var.region

  security_group_id        = aws_security_group.cluster[0].id
  protocol                 = each.value.protocol
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  type                     = each.value.type
  description              = try(each.value.description, null)
  cidr_blocks              = try(each.value.cidr_blocks, null)
  ipv6_cidr_blocks         = try(each.value.ipv6_cidr_blocks, null)
  prefix_list_ids          = try(each.value.prefix_list_ids, null)
  self                     = try(each.value.self, null)
  source_security_group_id = try(each.value.source_node_security_group, false) ? local.node_security_group_id : try(each.value.source_security_group_id, null)
}

################################################################################
# IRSA
# Note - this is different from EKS identity provider
################################################################################

locals {
  # Not available on outposts
  create_oidc_provider = local.create && var.enable_irsa && !local.create_outposts_local_cluster

  oidc_root_ca_thumbprint = local.create_oidc_provider && var.include_oidc_root_ca_thumbprint ? [data.tls_certificate.this[0].certificates[0].sha1_fingerprint] : []
}

data "tls_certificate" "this" {
  # Not available on outposts
  count = local.create_oidc_provider && var.include_oidc_root_ca_thumbprint ? 1 : 0

  url = aws_eks_cluster.this[0].identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "oidc_provider" {
  # Not available on outposts
  count = local.create_oidc_provider ? 1 : 0

  client_id_list  = distinct(compact(concat(["sts.amazonaws.com"], var.openid_connect_audiences)))
  thumbprint_list = concat(local.oidc_root_ca_thumbprint, var.custom_oidc_thumbprints)
  url             = aws_eks_cluster.this[0].identity[0].oidc[0].issuer

  tags = merge(
    { Name = "${var.name}-eks-irsa" },
    var.tags
  )
}

################################################################################
# IAM Role
################################################################################

locals {
  create_iam_role        = local.create && var.create_iam_role
  iam_role_name          = coalesce(var.iam_role_name, "${var.name}-cluster")
  iam_role_policy_prefix = "arn:${local.partition}:iam::aws:policy"

  cluster_encryption_policy_name = coalesce(var.encryption_policy_name, "${local.iam_role_name}-ClusterEncryption")

  # Standard EKS cluster
  eks_standard_iam_role_policies = { for k, v in {
    AmazonEKSClusterPolicy = "${local.iam_role_policy_prefix}/AmazonEKSClusterPolicy",
  } : k => v if !local.create_outposts_local_cluster && !local.create_auto_mode_iam_resources }

  # EKS cluster with EKS auto mode enabled
  eks_auto_mode_iam_role_policies = { for k, v in {
    AmazonEKSClusterPolicy       = "${local.iam_role_policy_prefix}/AmazonEKSClusterPolicy"
    AmazonEKSComputePolicy       = "${local.iam_role_policy_prefix}/AmazonEKSComputePolicy"
    AmazonEKSBlockStoragePolicy  = "${local.iam_role_policy_prefix}/AmazonEKSBlockStoragePolicy"
    AmazonEKSLoadBalancingPolicy = "${local.iam_role_policy_prefix}/AmazonEKSLoadBalancingPolicy"
    AmazonEKSNetworkingPolicy    = "${local.iam_role_policy_prefix}/AmazonEKSNetworkingPolicy"
  } : k => v if !local.create_outposts_local_cluster && local.create_auto_mode_iam_resources }

  # EKS local cluster on Outposts
  eks_outpost_iam_role_policies = { for k, v in {
    AmazonEKSClusterPolicy = "${local.iam_role_policy_prefix}/AmazonEKSLocalOutpostClusterPolicy"
  } : k => v if local.create_outposts_local_cluster && !local.create_auto_mode_iam_resources }
}

data "aws_iam_policy_document" "assume_role_policy" {
  count = local.create && var.create_iam_role ? 1 : 0

  statement {
    sid = "EKSClusterAssumeRole"
    actions = [
      "sts:AssumeRole",
      "sts:TagSession",
    ]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    dynamic "principals" {
      for_each = local.create_outposts_local_cluster ? [1] : []

      content {
        type        = "Service"
        identifiers = ["ec2.amazonaws.com"]
      }
    }
  }
}

resource "aws_iam_role" "this" {
  count = local.create_iam_role ? 1 : 0

  name        = var.iam_role_use_name_prefix ? null : local.iam_role_name
  name_prefix = var.iam_role_use_name_prefix ? "${local.iam_role_name}${var.prefix_separator}" : null
  path        = var.iam_role_path
  description = var.iam_role_description

  assume_role_policy    = data.aws_iam_policy_document.assume_role_policy[0].json
  permissions_boundary  = var.iam_role_permissions_boundary
  force_detach_policies = true

  tags = merge(var.tags, var.iam_role_tags)
}

# Policies attached ref https://docs.aws.amazon.com/eks/latest/userguide/service_IAM_role.html
resource "aws_iam_role_policy_attachment" "this" {
  for_each = { for k, v in merge(
    local.eks_standard_iam_role_policies,
    local.eks_auto_mode_iam_role_policies,
    local.eks_outpost_iam_role_policies,
  ) : k => v if local.create_iam_role }

  policy_arn = each.value
  role       = aws_iam_role.this[0].name
}

resource "aws_iam_role_policy_attachment" "additional" {
  for_each = { for k, v in var.iam_role_additional_policies : k => v if local.create_iam_role }

  policy_arn = each.value
  role       = aws_iam_role.this[0].name
}

# Using separate attachment due to `The "for_each" value depends on resource attributes that cannot be determined until apply`
resource "aws_iam_role_policy_attachment" "cluster_encryption" {
  # Encryption config not available on Outposts
  count = local.create_iam_role && var.attach_encryption_policy && local.enable_encryption_config ? 1 : 0

  policy_arn = aws_iam_policy.cluster_encryption[0].arn
  role       = aws_iam_role.this[0].name
}

resource "aws_iam_policy" "cluster_encryption" {
  # Encryption config not available on Outposts
  count = local.create_iam_role && var.attach_encryption_policy && local.enable_encryption_config ? 1 : 0

  name        = var.encryption_policy_use_name_prefix ? null : local.cluster_encryption_policy_name
  name_prefix = var.encryption_policy_use_name_prefix ? local.cluster_encryption_policy_name : null
  description = var.encryption_policy_description
  path        = var.encryption_policy_path

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ListGrants",
          "kms:DescribeKey",
        ]
        Effect   = "Allow"
        Resource = var.create_kms_key ? module.kms.key_arn : var.encryption_config.provider_key_arn
      },
    ]
  })

  tags = merge(var.tags, var.encryption_policy_tags)
}

data "aws_iam_policy_document" "custom" {
  count = local.create_iam_role && local.create_auto_mode_iam_resources && var.enable_auto_mode_custom_tags ? 1 : 0

  dynamic "statement" {
    for_each = var.enable_auto_mode_custom_tags ? [1] : []

    content {
      sid = "Compute"
      actions = [
        "ec2:CreateFleet",
        "ec2:RunInstances",
        "ec2:CreateLaunchTemplate",
      ]
      resources = ["*"]

      condition {
        test     = "StringEquals"
        variable = "aws:RequestTag/eks:eks-cluster-name"
        values   = ["$${aws:PrincipalTag/eks:eks-cluster-name}"]
      }

      condition {
        test     = "StringLike"
        variable = "aws:RequestTag/eks:kubernetes-node-class-name"
        values   = ["*"]
      }

      condition {
        test     = "StringLike"
        variable = "aws:RequestTag/eks:kubernetes-node-pool-name"
        values   = ["*"]
      }
    }
  }

  dynamic "statement" {
    for_each = var.enable_auto_mode_custom_tags ? [1] : []

    content {
      sid = "Storage"
      actions = [
        "ec2:CreateVolume",
        "ec2:CreateSnapshot",
      ]
      resources = [
        "arn:${local.partition}:ec2:*:*:volume/*",
        "arn:${local.partition}:ec2:*:*:snapshot/*",
      ]

      condition {
        test     = "StringEquals"
        variable = "aws:RequestTag/eks:eks-cluster-name"
        values   = ["$${aws:PrincipalTag/eks:eks-cluster-name}"]
      }
    }
  }

  dynamic "statement" {
    for_each = var.enable_auto_mode_custom_tags ? [1] : []

    content {
      sid       = "Networking"
      actions   = ["ec2:CreateNetworkInterface"]
      resources = ["*"]

      condition {
        test     = "StringEquals"
        variable = "aws:RequestTag/eks:eks-cluster-name"
        values   = ["$${aws:PrincipalTag/eks:eks-cluster-name}"]
      }

      condition {
        test     = "StringEquals"
        variable = "aws:RequestTag/eks:kubernetes-cni-node-name"
        values   = ["*"]
      }
    }
  }

  dynamic "statement" {
    for_each = var.enable_auto_mode_custom_tags ? [1] : []

    content {
      sid = "LoadBalancer"
      actions = [
        "elasticloadbalancing:CreateLoadBalancer",
        "elasticloadbalancing:CreateTargetGroup",
        "elasticloadbalancing:CreateListener",
        "elasticloadbalancing:CreateRule",
        "ec2:CreateSecurityGroup",
      ]
      resources = ["*"]

      condition {
        test     = "StringEquals"
        variable = "aws:RequestTag/eks:eks-cluster-name"
        values   = ["$${aws:PrincipalTag/eks:eks-cluster-name}"]
      }
    }
  }

  dynamic "statement" {
    for_each = var.enable_auto_mode_custom_tags ? [1] : []

    content {
      sid       = "ShieldProtection"
      actions   = ["shield:CreateProtection"]
      resources = ["*"]

      condition {
        test     = "StringEquals"
        variable = "aws:RequestTag/eks:eks-cluster-name"
        values   = ["$${aws:PrincipalTag/eks:eks-cluster-name}"]
      }
    }
  }

  dynamic "statement" {
    for_each = var.enable_auto_mode_custom_tags ? [1] : []

    content {
      sid       = "ShieldTagResource"
      actions   = ["shield:TagResource"]
      resources = ["arn:${local.partition}:shield::*:protection/*"]

      condition {
        test     = "StringEquals"
        variable = "aws:RequestTag/eks:eks-cluster-name"
        values   = ["$${aws:PrincipalTag/eks:eks-cluster-name}"]
      }
    }
  }
}

resource "aws_iam_policy" "custom" {
  count = local.create_iam_role && local.create_auto_mode_iam_resources && var.enable_auto_mode_custom_tags ? 1 : 0

  name        = var.iam_role_use_name_prefix ? null : local.iam_role_name
  name_prefix = var.iam_role_use_name_prefix ? "${local.iam_role_name}-" : null
  path        = var.iam_role_path
  description = var.iam_role_description

  policy = data.aws_iam_policy_document.custom[0].json

  tags = merge(var.tags, var.iam_role_tags)
}

resource "aws_iam_role_policy_attachment" "custom" {
  count = local.create_iam_role && local.create_auto_mode_iam_resources && var.enable_auto_mode_custom_tags ? 1 : 0

  policy_arn = aws_iam_policy.custom[0].arn
  role       = aws_iam_role.this[0].name
}

################################################################################
# EKS Addons
################################################################################

data "aws_eks_addon_version" "this" {
  for_each = var.addons != null && local.create && !local.create_outposts_local_cluster ? var.addons : {}

  region = var.region

  addon_name         = coalesce(each.value.name, each.key)
  kubernetes_version = coalesce(var.kubernetes_version, aws_eks_cluster.this[0].version)
  most_recent        = each.value.most_recent
}

resource "aws_eks_addon" "this" {
  # Not supported on outposts
  for_each = var.addons != null && local.create && !local.create_outposts_local_cluster ? { for k, v in var.addons : k => v if !v.before_compute } : {}

  region = var.region

  cluster_name = aws_eks_cluster.this[0].id
  addon_name   = coalesce(each.value.name, each.key)

  addon_version        = coalesce(each.value.addon_version, data.aws_eks_addon_version.this[each.key].version)
  configuration_values = each.value.configuration_values

  dynamic "pod_identity_association" {
    for_each = each.value.pod_identity_association != null ? each.value.pod_identity_association : []

    content {
      role_arn        = pod_identity_association.value.role_arn
      service_account = pod_identity_association.value.service_account
    }
  }

  preserve                    = each.value.preserve
  resolve_conflicts_on_create = each.value.resolve_conflicts_on_create
  resolve_conflicts_on_update = each.value.resolve_conflicts_on_update
  service_account_role_arn    = each.value.service_account_role_arn

  timeouts {
    create = each.value.timeouts.create != null ? each.value.timeouts.create : var.addons_timeouts.create
    update = each.value.timeouts.update != null ? each.value.timeouts.update : var.addons_timeouts.update
    delete = each.value.timeouts.delete != null ? each.value.timeouts.delete : var.addons_timeouts.delete
  }

  tags = merge(
    var.tags,
    each.value.tags,
  )

  # before_compute = false
  depends_on = [
    module.fargate_profile,
    module.eks_managed_node_group,
    module.self_managed_node_group,
  ]
}

resource "aws_eks_addon" "before_compute" {
  # Not supported on outposts
  for_each = var.addons != null && local.create && !local.create_outposts_local_cluster ? { for k, v in var.addons : k => v if v.before_compute } : {}

  region = var.region

  cluster_name = aws_eks_cluster.this[0].id
  addon_name   = coalesce(each.value.name, each.key)

  addon_version        = coalesce(each.value.addon_version, data.aws_eks_addon_version.this[each.key].version)
  configuration_values = each.value.configuration_values

  dynamic "pod_identity_association" {
    for_each = each.value.pod_identity_association != null ? each.value.pod_identity_association : []

    content {
      role_arn        = pod_identity_association.value.role_arn
      service_account = pod_identity_association.value.service_account
    }
  }

  preserve                    = each.value.preserve
  resolve_conflicts_on_create = each.value.resolve_conflicts_on_create
  resolve_conflicts_on_update = each.value.resolve_conflicts_on_update
  service_account_role_arn    = each.value.service_account_role_arn

  timeouts {
    create = each.value.timeouts.create != null ? each.value.timeouts.create : var.addons_timeouts.create
    update = each.value.timeouts.update != null ? each.value.timeouts.update : var.addons_timeouts.update
    delete = each.value.timeouts.delete != null ? each.value.timeouts.delete : var.addons_timeouts.delete
  }

  tags = merge(
    var.tags,
    each.value.tags,
  )
}

################################################################################
# EKS Identity Provider
# Note - this is different from IRSA
################################################################################

resource "aws_eks_identity_provider_config" "this" {
  for_each = var.identity_providers != null && local.create && !local.create_outposts_local_cluster ? var.identity_providers : {}

  region = var.region

  cluster_name = aws_eks_cluster.this[0].id

  oidc {
    client_id                     = each.value.client_id
    groups_claim                  = each.value.groups_claim
    groups_prefix                 = each.value.groups_prefix
    identity_provider_config_name = coalesce(each.value.identity_provider_config_name, each.key)
    issuer_url                    = each.value.issuer_url
    required_claims               = each.value.required_claims
    username_claim                = each.value.username_claim
    username_prefix               = each.value.username_prefix
  }

  tags = merge(
    var.tags,
    each.value.tags,
  )
}

################################################################################
# EKS Auto Node IAM Role
################################################################################

locals {
  create_node_iam_role = local.create && var.create_node_iam_role && local.create_auto_mode_iam_resources
  node_iam_role_name   = coalesce(var.node_iam_role_name, "${var.name}-eks-auto")
}

data "aws_iam_policy_document" "node_assume_role_policy" {
  count = local.create_node_iam_role ? 1 : 0

  statement {
    sid = "EKSAutoNodeAssumeRole"
    actions = [
      "sts:AssumeRole",
      "sts:TagSession",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_auto" {
  count = local.create_node_iam_role ? 1 : 0

  name        = var.node_iam_role_use_name_prefix ? null : local.node_iam_role_name
  name_prefix = var.node_iam_role_use_name_prefix ? "${local.node_iam_role_name}-" : null
  path        = var.node_iam_role_path
  description = var.node_iam_role_description

  assume_role_policy    = data.aws_iam_policy_document.node_assume_role_policy[0].json
  permissions_boundary  = var.node_iam_role_permissions_boundary
  force_detach_policies = true

  tags = merge(var.tags, var.node_iam_role_tags)
}

# Policies attached ref https://docs.aws.amazon.com/eks/latest/userguide/service_IAM_role.html
resource "aws_iam_role_policy_attachment" "eks_auto" {
  for_each = { for k, v in {
    AmazonEKSWorkerNodeMinimalPolicy   = "${local.iam_role_policy_prefix}/AmazonEKSWorkerNodeMinimalPolicy",
    AmazonEC2ContainerRegistryPullOnly = "${local.iam_role_policy_prefix}/AmazonEC2ContainerRegistryPullOnly",
  } : k => v if local.create_node_iam_role }

  policy_arn = each.value
  role       = aws_iam_role.eks_auto[0].name
}

resource "aws_iam_role_policy_attachment" "eks_auto_additional" {
  for_each = { for k, v in var.node_iam_role_additional_policies : k => v if local.create_node_iam_role }

  policy_arn = each.value
  role       = aws_iam_role.eks_auto[0].name
}
