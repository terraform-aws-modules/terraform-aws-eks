locals {

  # EKS Cluster
  cluster_id                        = try(aws_eks_cluster.this[0].id, "")
  cluster_arn                       = try(aws_eks_cluster.this[0].arn, "")
  cluster_endpoint                  = try(aws_eks_cluster.this[0].endpoint, "")
  cluster_auth_base64               = try(aws_eks_cluster.this[0].certificate_authority[0].data, "")
  cluster_primary_security_group_id = try(aws_eks_cluster.this[0].vpc_config[0].cluster_security_group_id, "")

  cluster_security_group_id = var.create_cluster_security_group ? join("", aws_security_group.cluster.*.id) : var.cluster_security_group_id

  # Worker groups
  worker_security_group_id = var.worker_create_security_group ? join("", aws_security_group.workers.*.id) : var.worker_security_group_id
  worker_groups_platforms  = [for x in var.worker_groups : try(x.platform, var.default_platform)]

  worker_ami_name_filter         = coalesce(var.worker_ami_name_filter, "amazon-eks-node-${coalesce(var.cluster_version, "cluster_version")}-v*")
  worker_ami_name_filter_windows = coalesce(var.worker_ami_name_filter_windows, "Windows_Server-2019-English-Core-EKS_Optimized-${coalesce(var.cluster_version, "cluster_version")}-*")

  ec2_principal     = "ec2.${data.aws_partition.current.dns_suffix}"
  sts_principal     = "sts.${data.aws_partition.current.dns_suffix}"
  policy_arn_prefix = "arn:${data.aws_partition.current.partition}:iam::aws:policy"

  kubeconfig = var.create ? templatefile("${path.module}/templates/kubeconfig.tpl", {
    kubeconfig_name                         = coalesce(var.kubeconfig_name, "eks_${var.cluster_name}")
    endpoint                                = local.cluster_endpoint
    cluster_auth_base64                     = local.cluster_auth_base64
    aws_authenticator_kubeconfig_apiversion = var.kubeconfig_api_version
    aws_authenticator_command               = var.kubeconfig_aws_authenticator_command
    aws_authenticator_command_args          = coalescelist(var.kubeconfig_aws_authenticator_command_args, ["token", "-i", var.cluster_name])
    aws_authenticator_additional_args       = var.kubeconfig_aws_authenticator_additional_args
    aws_authenticator_env_variables         = var.kubeconfig_aws_authenticator_env_variables
  }) : ""

  launch_template_userdata_rendered = [
    for key, group in(var.create ? var.worker_groups : {}) : templatefile(
      try(
        group.userdata_template_file,
        lookup(group, "platform", var.default_platform) == "windows"
        ? "${path.module}/templates/userdata_windows.tpl"
        : "${path.module}/templates/userdata.sh.tpl"
      ),
      merge({
        platform             = lookup(group, "platform", var.default_platform)
        cluster_name         = var.cluster_name
        endpoint             = local.cluster_endpoint
        cluster_auth_base64  = local.cluster_auth_base64
        pre_userdata         = lookup(group, "pre_userdata", "")
        additional_userdata  = lookup(group, "additional_userdata", "")
        bootstrap_extra_args = lookup(group, "bootstrap_extra_args", "")
        kubelet_extra_args   = lookup(group, "kubelet_extra_args", "")
        },
        lookup(group, "userdata_template_extra_args", "")
      )
    )
  ]
}
