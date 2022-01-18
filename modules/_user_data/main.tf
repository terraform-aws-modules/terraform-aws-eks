
locals {
  merge_user_data = var.is_eks_managed_node_group && length(var.ami_id) == 0 && var.platform == "linux"

  user_data_env = merge(var.bootstrap_extra_args != null ? { BOOTSTRAP_EXTRA_ARGS = var.bootstrap_extra_args } : {}, var.user_data_env, {
    CLUSTER_NAME   = var.cluster_name
    API_SERVER_URL = var.cluster_endpoint
    B64_CLUSTER_CA = var.cluster_auth_base64
  }, var.cluster_service_ipv4_cidr != null ? { SERVICE_IPV4_CIDR = var.cluster_service_ipv4_cidr } : {})

  template_args = {
    cluster_name               = var.cluster_name
    cluster_endpoint           = var.cluster_endpoint
    cluster_auth_base64        = var.cluster_auth_base64
    cluster_service_ipv4_cidr  = var.cluster_service_ipv4_cidr != null ? var.cluster_service_ipv4_cidr : ""
    platform                   = var.platform
    is_eks_managed_node_group  = var.is_eks_managed_node_group
    merge_user_data            = local.merge_user_data
    enable_bootstrap_user_data = (var.enable_bootstrap_user_data || length(var.ami_id) == 0) && !local.merge_user_data
    pre_bootstrap_user_data    = var.pre_bootstrap_user_data
    post_bootstrap_user_data   = var.post_bootstrap_user_data
    bootstrap_extra_args       = var.bootstrap_extra_args
    user_data_env              = local.user_data_env
  }

  default_template_paths = {
    "bottlerocket" = "${path.module}/../../templates/bottlerocket_user_data.tpl"
    "linux"        = "${path.module}/../../templates/linux_user_data.tpl"
    "windows"      = "${path.module}/../../templates/windows_user_data.tpl"
    "linuxmerge"   = "${path.module}/../../templates/linux_mng_merge_user_data.tpl"
  }

  default_template_path = local.merge_user_data ? local.default_template_paths.linuxmerge : lookup(local.default_template_paths, var.platform, "")

  template_path = coalesce(var.user_data_template_path, local.default_template_path)

  raw_user_data = var.create && length(local.template_path) > 0 ? templatefile(local.template_path, local.template_args) : ""

  user_data = try(data.cloudinit_config.merge_user_data[0].rendered, base64encode(local.raw_user_data))
}

# https://github.com/aws/containers-roadmap/issues/596#issuecomment-675097667
# An important note is that user data must in MIME multi-part archive format,
# as by default, EKS will merge the bootstrapping command required for nodes to join the
# cluster with your user data. If you use a custom AMI in your launch template,
# this merging will NOT happen and you are responsible for nodes joining the cluster.
# See docs for more details -> https://docs.aws.amazon.com/eks/latest/userguide/launch-templates.html#launch-template-user-data

data "cloudinit_config" "merge_user_data" {
  count = var.create && local.merge_user_data ? 1 : 0

  base64_encode = true
  gzip          = false
  boundary      = "//"

  # Prepend to existing user data suppled by AWS EKS
  part {
    content_type = "text/x-shellscript"
    content      = local.raw_user_data
  }
}
