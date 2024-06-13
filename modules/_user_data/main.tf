# The `cluster_service_cidr` is required when `create == true`
# This is a hacky way to make that logic work, otherwise Terraform always wants a value
# and supplying any old value like `""` or `null` is not valid and will silently
# fail to join nodes to the cluster
resource "null_resource" "validate_cluster_service_cidr" {
  lifecycle {
    precondition {
      # The length 6 is currently arbitrary, but it's a safe bet that the CIDR will be longer than that
      # The main point is that a value needs to be provided when `create = true`
      condition     = var.create ? length(local.cluster_service_cidr) > 6 : true
      error_message = "`cluster_service_cidr` is required when `create = true`."
    }
  }
}

locals {
  # Converts AMI type into user data type that represents the underlying format (bash, toml, PS1, nodeadm)
  # TODO - platform will be removed in v21.0 and only `ami_type` will be valid
  ami_type_to_user_data_type = {
    AL2_x86_64                 = "linux"
    AL2_x86_64_GPU             = "linux"
    AL2_ARM_64                 = "linux"
    BOTTLEROCKET_ARM_64        = "bottlerocket"
    BOTTLEROCKET_x86_64        = "bottlerocket"
    BOTTLEROCKET_ARM_64_NVIDIA = "bottlerocket"
    BOTTLEROCKET_x86_64_NVIDIA = "bottlerocket"
    WINDOWS_CORE_2019_x86_64   = "windows"
    WINDOWS_FULL_2019_x86_64   = "windows"
    WINDOWS_CORE_2022_x86_64   = "windows"
    WINDOWS_FULL_2022_x86_64   = "windows"
    AL2023_x86_64_STANDARD     = "al2023"
    AL2023_ARM_64_STANDARD     = "al2023"
  }
  # Try to use `ami_type` first, but fall back to current, default behavior
  # TODO - will be removed in v21.0
  user_data_type = try(local.ami_type_to_user_data_type[var.ami_type], var.platform)

  template_path = {
    al2023       = "${path.module}/../../templates/al2023_user_data.tpl"
    bottlerocket = "${path.module}/../../templates/bottlerocket_user_data.tpl"
    linux        = "${path.module}/../../templates/linux_user_data.tpl"
    windows      = "${path.module}/../../templates/windows_user_data.tpl"
  }

  cluster_service_cidr = try(coalesce(var.cluster_service_ipv4_cidr, var.cluster_service_cidr), "")
  cluster_dns_ips      = flatten(concat([try(cidrhost(local.cluster_service_cidr, 10), "")], var.additional_cluster_dns_ips))

  user_data = base64encode(templatefile(
    coalesce(var.user_data_template_path, local.template_path[local.user_data_type]),
    {
      # https://docs.aws.amazon.com/eks/latest/userguide/launch-templates.html#launch-template-custom-ami
      enable_bootstrap_user_data = var.enable_bootstrap_user_data

      # Required to bootstrap node
      cluster_name        = var.cluster_name
      cluster_endpoint    = var.cluster_endpoint
      cluster_auth_base64 = var.cluster_auth_base64

      cluster_service_cidr = local.cluster_service_cidr
      cluster_ip_family    = var.cluster_ip_family

      # Bottlerocket
      cluster_dns_ips = "[${join(", ", formatlist("\"%s\"", local.cluster_dns_ips))}]"

      # Optional
      bootstrap_extra_args     = var.bootstrap_extra_args
      pre_bootstrap_user_data  = var.pre_bootstrap_user_data
      post_bootstrap_user_data = var.post_bootstrap_user_data
    }
  ))

  user_data_type_to_rendered = {
    al2023 = {
      user_data = var.create ? try(data.cloudinit_config.al2023_eks_managed_node_group[0].rendered, local.user_data) : ""
    }
    bottlerocket = {
      user_data = var.create && local.user_data_type == "bottlerocket" && (var.enable_bootstrap_user_data || var.user_data_template_path != "" || var.bootstrap_extra_args != "") ? local.user_data : ""
    }
    linux = {
      user_data = var.create ? try(data.cloudinit_config.linux_eks_managed_node_group[0].rendered, local.user_data) : ""
    }
    windows = {
      user_data = var.create && local.user_data_type == "windows" && (var.enable_bootstrap_user_data || var.user_data_template_path != "" || var.pre_bootstrap_user_data != "") ? local.user_data : ""
    }
  }
}

# https://github.com/aws/containers-roadmap/issues/596#issuecomment-675097667
# Managed node group data must in MIME multi-part archive format,
# as by default, EKS will merge the bootstrapping command required for nodes to join the
# cluster with your user data. If you use a custom AMI in your launch template,
# this merging will NOT happen and you are responsible for nodes joining the cluster.
# See docs for more details -> https://docs.aws.amazon.com/eks/latest/userguide/launch-templates.html#launch-template-user-data

data "cloudinit_config" "linux_eks_managed_node_group" {
  count = var.create && local.user_data_type == "linux" && var.is_eks_managed_node_group && !var.enable_bootstrap_user_data && var.pre_bootstrap_user_data != "" && var.user_data_template_path == "" ? 1 : 0

  base64_encode = true
  gzip          = false
  boundary      = "//"

  # Prepend to existing user data supplied by AWS EKS
  part {
    content      = var.pre_bootstrap_user_data
    content_type = "text/x-shellscript"
  }
}

# Scenarios:
#
# 1. Do nothing - provide nothing
# 2. Prepend stuff on EKS MNG (before EKS MNG adds its bit at the end)
# 3. Own all of the stuff on self-MNG or EKS MNG w/ custom AMI

locals {
  nodeadm_cloudinit = var.enable_bootstrap_user_data ? concat(
    var.cloudinit_pre_nodeadm,
    [{
      content_type = "application/node.eks.aws"
      content      = base64decode(local.user_data)
    }],
    var.cloudinit_post_nodeadm
  ) : var.cloudinit_pre_nodeadm
}

data "cloudinit_config" "al2023_eks_managed_node_group" {
  count = var.create && local.user_data_type == "al2023" && length(local.nodeadm_cloudinit) > 0 ? 1 : 0

  base64_encode = true
  gzip          = false
  boundary      = "MIMEBOUNDARY"

  dynamic "part" {
    # Using the index is fine in this context since any change in user data will be a replacement
    for_each = { for i, v in local.nodeadm_cloudinit : i => v }

    content {
      content      = part.value.content
      content_type = try(part.value.content_type, null)
      filename     = try(part.value.filename, null)
      merge_type   = try(part.value.merge_type, null)
    }
  }
}
