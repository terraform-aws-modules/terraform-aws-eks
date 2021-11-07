locals {

  # EKS Cluster
  cluster_id                        = coalescelist(aws_eks_cluster.this[*].id, [""])[0]
  cluster_arn                       = coalescelist(aws_eks_cluster.this[*].arn, [""])[0]
  cluster_name                      = coalescelist(aws_eks_cluster.this[*].name, [""])[0]
  cluster_endpoint                  = coalescelist(aws_eks_cluster.this[*].endpoint, [""])[0]
  cluster_auth_base64               = coalescelist(aws_eks_cluster.this[*].certificate_authority[0].data, [""])[0]
  cluster_oidc_issuer_url           = flatten(concat(aws_eks_cluster.this[*].identity[*].oidc[0].issuer, [""]))[0]
  cluster_primary_security_group_id = coalescelist(aws_eks_cluster.this[*].vpc_config[0].cluster_security_group_id, [""])[0]

  cluster_security_group_id = var.cluster_create_security_group ? join("", aws_security_group.cluster.*.id) : var.cluster_security_group_id
  cluster_iam_role_name     = var.manage_cluster_iam_resources ? join("", aws_iam_role.cluster.*.name) : var.cluster_iam_role_name
  cluster_iam_role_arn      = var.manage_cluster_iam_resources ? join("", aws_iam_role.cluster.*.arn) : join("", data.aws_iam_role.custom_cluster_iam_role.*.arn)

  # Worker groups
  worker_security_group_id = var.worker_create_security_group ? join("", aws_security_group.workers.*.id) : var.worker_security_group_id

  default_iam_role_id     = concat(aws_iam_role.workers.*.id, [""])[0]
  worker_groups_platforms = [for x in var.worker_groups : try(x.platform, var.default_platform)]

  worker_ami_name_filter         = coalesce(var.worker_ami_name_filter, "amazon-eks-node-${coalesce(var.cluster_version, "cluster_version")}-v*")
  worker_ami_name_filter_windows = coalesce(var.worker_ami_name_filter_windows, "Windows_Server-2019-English-Core-EKS_Optimized-${coalesce(var.cluster_version, "cluster_version")}-*")

  ec2_principal     = "ec2.${data.aws_partition.current.dns_suffix}"
  sts_principal     = "sts.${data.aws_partition.current.dns_suffix}"
  client_id_list    = distinct(compact(concat([local.sts_principal], var.openid_connect_audiences)))
  policy_arn_prefix = "arn:${data.aws_partition.current.partition}:iam::aws:policy"

  kubeconfig = var.create_eks ? templatefile("${path.module}/templates/kubeconfig.tpl", {
    kubeconfig_name                         = coalesce(var.kubeconfig_name, "eks_${var.cluster_name}")
    endpoint                                = local.cluster_endpoint
    cluster_auth_base64                     = local.cluster_auth_base64
    aws_authenticator_kubeconfig_apiversion = var.kubeconfig_api_version
    aws_authenticator_command               = var.kubeconfig_aws_authenticator_command
    aws_authenticator_command_args          = coalescelist(var.kubeconfig_aws_authenticator_command_args, ["token", "-i", local.cluster_name])
    aws_authenticator_additional_args       = var.kubeconfig_aws_authenticator_additional_args
    aws_authenticator_env_variables         = var.kubeconfig_aws_authenticator_env_variables
  }) : ""

  launch_template_userdata_rendered = [
    for index in range(var.create_eks ? local.worker_group_count : 0) : templatefile(
      lookup(
        var.worker_groups[index],
        "userdata_template_file",
        lookup(var.worker_groups[index], "platform", var.platform_default) == "windows"
        ? "${path.module}/templates/userdata_windows.tpl"
        : "${path.module}/templates/userdata.sh.tpl"
      ),
      merge({
        platform             = lookup(var.worker_groups[index], "platform", var.platform_default)
        cluster_name         = local.cluster_name
        endpoint             = local.cluster_endpoint
        cluster_auth_base64  = local.cluster_auth_base64
        pre_userdata         = lookup(var.worker_groups[index], "pre_userdata", "")
        additional_userdata  = lookup(var.worker_groups[index], "additional_userdata", "")
        bootstrap_extra_args = lookup(var.worker_groups[index], "bootstrap_extra_args", "")
        kubelet_extra_args   = lookup(var.worker_groups[index], "kubelet_extra_args", "")
        },
        lookup(var.worker_groups[index], "userdata_template_extra_args", "")
      )
    )
  ]
}
