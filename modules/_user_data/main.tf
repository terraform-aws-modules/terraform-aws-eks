
locals {
  int_linux_default_user_data = var.create && var.platform == "linux" && (var.enable_bootstrap_user_data || var.user_data_template_path != "") ? base64encode(templatefile(
    coalesce(var.user_data_template_path, "${path.module}/../../templates/linux_user_data.tpl"),
    {
      # https://docs.aws.amazon.com/eks/latest/userguide/launch-templates.html#launch-template-custom-ami
      enable_bootstrap_user_data = var.enable_bootstrap_user_data
      # Required to bootstrap node
      cluster_name        = var.cluster_name
      cluster_endpoint    = var.cluster_endpoint
      cluster_auth_base64 = var.cluster_auth_base64
      # Optional
      cluster_service_ipv4_cidr = var.cluster_service_ipv4_cidr != null ? var.cluster_service_ipv4_cidr : ""
      bootstrap_extra_args      = var.bootstrap_extra_args
      pre_bootstrap_user_data   = var.pre_bootstrap_user_data
      post_bootstrap_user_data  = var.post_bootstrap_user_data
    }
  )) : ""
  platform = {
    bottlerocket = {
      user_data = var.create && var.platform == "bottlerocket" && (var.enable_bootstrap_user_data || var.user_data_template_path != "" || var.bootstrap_extra_args != "") ? base64encode(templatefile(
        coalesce(var.user_data_template_path, "${path.module}/../../templates/bottlerocket_user_data.tpl"),
        {
          # https://docs.aws.amazon.com/eks/latest/userguide/launch-templates.html#launch-template-custom-ami
          enable_bootstrap_user_data = var.enable_bootstrap_user_data
          # Required to bootstrap node
          cluster_name        = var.cluster_name
          cluster_endpoint    = var.cluster_endpoint
          cluster_auth_base64 = var.cluster_auth_base64
          # Optional - is appended if using EKS managed node group without custom AMI
          # cluster_service_ipv4_cidr = var.cluster_service_ipv4_cidr # Bottlerocket pulls this automatically https://github.com/bottlerocket-os/bottlerocket/issues/1866
          bootstrap_extra_args = var.bootstrap_extra_args
        }
      )) : ""
    }
    linux = {
      user_data = try(data.cloudinit_config.linux_eks_managed_node_group[0].rendered, local.int_linux_default_user_data)

    }
    windows = {
      user_data = var.create && var.platform == "windows" && var.enable_bootstrap_user_data ? base64encode(templatefile(
        coalesce(var.user_data_template_path, "${path.module}/../../templates/windows_user_data.tpl"),
        {
          # Required to bootstrap node
          cluster_name        = var.cluster_name
          cluster_endpoint    = var.cluster_endpoint
          cluster_auth_base64 = var.cluster_auth_base64
          # Optional - is appended if using EKS managed node group without custom AMI
          # cluster_service_ipv4_cidr = var.cluster_service_ipv4_cidr # Not supported yet: https://github.com/awslabs/amazon-eks-ami/issues/805
          bootstrap_extra_args     = var.bootstrap_extra_args
          pre_bootstrap_user_data  = var.pre_bootstrap_user_data
          post_bootstrap_user_data = var.post_bootstrap_user_data
        }
      )) : ""
    }
  }
}

# https://github.com/aws/containers-roadmap/issues/596#issuecomment-675097667
# An important note is that user data must in MIME multi-part archive format,
# as by default, EKS will merge the bootstrapping command required for nodes to join the
# cluster with your user data. If you use a custom AMI in your launch template,
# this merging will NOT happen and you are responsible for nodes joining the cluster.
# See docs for more details -> https://docs.aws.amazon.com/eks/latest/userguide/launch-templates.html#launch-template-user-data

data "cloudinit_config" "linux_eks_managed_node_group" {
  count = var.create && var.platform == "linux" && var.is_eks_managed_node_group && !var.enable_bootstrap_user_data && var.pre_bootstrap_user_data != "" && var.user_data_template_path == "" ? 1 : 0

  base64_encode = true
  gzip          = false
  boundary      = "//"

  # Prepend to existing user data supplied by AWS EKS
  part {
    content_type = "text/x-shellscript"
    content      = var.pre_bootstrap_user_data
  }
}
