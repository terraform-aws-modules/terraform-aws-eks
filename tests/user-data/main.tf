locals {
  name = "ex-${replace(basename(path.cwd), "_", "-")}"

  cluster_endpoint          = "https://012345678903AB2BAE5D1E0BFE0E2B50.gr7.us-east-1.eks.amazonaws.com"
  cluster_auth_base64       = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUM1ekNDQWMrZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKbXFqQ1VqNGdGR2w3ZW5PeWthWnZ2RjROOTVOUEZCM2o0cGhVZUsrWGFtN2ZSQnZya0d6OGxKZmZEZWF2b2plTwpQK2xOZFlqdHZncmxCUEpYdHZIZmFzTzYxVzdIZmdWQ2EvamdRM2w3RmkvL1dpQmxFOG9oWUZkdWpjc0s1SXM2CnNkbk5KTTNYUWN2TysrSitkV09NT2ZlNzlsSWdncmdQLzgvRU9CYkw3eUY1aU1hS3lsb1RHL1V3TlhPUWt3ZUcKblBNcjdiUmdkQ1NCZTlXYXowOGdGRmlxV2FOditsTDhsODBTdFZLcWVNVlUxbjQyejVwOVpQRTd4T2l6L0xTNQpYV2lXWkVkT3pMN0xBWGVCS2gzdkhnczFxMkI2d1BKZnZnS1NzWllQRGFpZTloT1NNOUJkNFNPY3JrZTRYSVBOCkVvcXVhMlYrUDRlTWJEQzhMUkVWRDdCdVZDdWdMTldWOTBoL3VJUy9WU2VOcEdUOGVScE5DakszSjc2aFlsWm8KWjNGRG5QWUY0MWpWTHhiOXF0U1ROdEp6amYwWXBEYnFWci9xZzNmQWlxbVorMzd3YWM1eHlqMDZ4cmlaRUgzZgpUM002d2lCUEVHYVlGeWN5TmNYTk5aYW9DWDJVL0N1d2JsUHAKLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQ=="
  cluster_service_ipv4_cidr = "172.16.0.0/16"
  cluster_service_ipv6_cidr = "fdd3:7636:68bc::/108"
  cluster_service_cidr      = "192.168.0.0/16"
}

################################################################################
# EKS managed node group - AL2
################################################################################

module "eks_mng_al2_disabled" {
  source = "../../modules/_user_data"

  create = false
}

module "eks_mng_al2_no_op" {
  source = "../../modules/_user_data"

  # Hard requirement
  cluster_service_cidr = local.cluster_service_cidr
}

module "eks_mng_al2_additional" {
  source = "../../modules/_user_data"

  # Hard requirement
  cluster_service_cidr = local.cluster_service_cidr

  pre_bootstrap_user_data = <<-EOT
    export USE_MAX_PODS=false
  EOT
}

module "eks_mng_al2_custom_ami" {
  source = "../../modules/_user_data"

  cluster_name         = local.name
  cluster_endpoint     = local.cluster_endpoint
  cluster_auth_base64  = local.cluster_auth_base64
  cluster_service_cidr = local.cluster_service_ipv4_cidr

  enable_bootstrap_user_data = true

  pre_bootstrap_user_data = <<-EOT
    export FOO=bar
  EOT

  bootstrap_extra_args = "--kubelet-extra-args '--instance-type t3a.large'"

  post_bootstrap_user_data = <<-EOT
    echo "All done"
  EOT
}

module "eks_mng_al2_custom_ami_ipv6" {
  source = "../../modules/_user_data"

  cluster_name         = local.name
  cluster_endpoint     = local.cluster_endpoint
  cluster_auth_base64  = local.cluster_auth_base64
  cluster_ip_family    = "ipv6"
  cluster_service_cidr = local.cluster_service_ipv6_cidr

  enable_bootstrap_user_data = true

  pre_bootstrap_user_data = <<-EOT
    export FOO=bar
  EOT

  bootstrap_extra_args = "--kubelet-extra-args '--instance-type t3a.large'"

  post_bootstrap_user_data = <<-EOT
    echo "All done"
  EOT
}

module "eks_mng_al2_custom_template" {
  source = "../../modules/_user_data"

  cluster_name         = local.name
  cluster_endpoint     = local.cluster_endpoint
  cluster_auth_base64  = local.cluster_auth_base64
  cluster_service_cidr = local.cluster_service_ipv4_cidr

  user_data_template_path = "${path.module}/templates/linux_custom.tpl"

  pre_bootstrap_user_data = <<-EOT
    echo "foo"
    export FOO=bar
  EOT

  bootstrap_extra_args = "--kubelet-extra-args '--node-labels=node.kubernetes.io/lifecycle=spot'"

  post_bootstrap_user_data = <<-EOT
    echo "All done"
  EOT
}

################################################################################
# EKS managed node group - AL2023
################################################################################

module "eks_mng_al2023_no_op" {
  source = "../../modules/_user_data"

  ami_type = "AL2023_x86_64_STANDARD"

  # Hard requirement
  cluster_service_cidr = local.cluster_service_cidr
}

module "eks_mng_al2023_additional" {
  source = "../../modules/_user_data"

  ami_type = "AL2023_x86_64_STANDARD"

  # Hard requirement
  cluster_service_cidr = local.cluster_service_cidr

  cloudinit_pre_nodeadm = [{
    content      = <<-EOT
      ---
      apiVersion: node.eks.aws/v1alpha1
      kind: NodeConfig
      spec:
        kubelet:
          config:
            shutdownGracePeriod: 30s
            featureGates:
              DisableKubeletCloudCredentialProviders: true
    EOT
    content_type = "application/node.eks.aws"
  }]
}

module "eks_mng_al2023_custom_ami" {
  source = "../../modules/_user_data"

  ami_type = "AL2023_x86_64_STANDARD"

  cluster_name         = local.name
  cluster_endpoint     = local.cluster_endpoint
  cluster_auth_base64  = local.cluster_auth_base64
  cluster_service_cidr = local.cluster_service_cidr

  enable_bootstrap_user_data = true

  cloudinit_pre_nodeadm = [{
    content      = <<-EOT
      ---
      apiVersion: node.eks.aws/v1alpha1
      kind: NodeConfig
      spec:
        kubelet:
          config:
            shutdownGracePeriod: 30s
            featureGates:
              DisableKubeletCloudCredentialProviders: true
    EOT
    content_type = "application/node.eks.aws"
  }]

  cloudinit_post_nodeadm = [{
    content      = <<-EOT
      echo "All done"
    EOT
    content_type = "text/x-shellscript; charset=\"us-ascii\""
  }]
}

module "eks_mng_al2023_custom_template" {
  source = "../../modules/_user_data"

  ami_type = "AL2023_x86_64_STANDARD"

  cluster_name         = local.name
  cluster_endpoint     = local.cluster_endpoint
  cluster_auth_base64  = local.cluster_auth_base64
  cluster_service_cidr = local.cluster_service_cidr

  enable_bootstrap_user_data = true
  user_data_template_path    = "${path.module}/templates/al2023_custom.tpl"

  cloudinit_pre_nodeadm = [{
    content      = <<-EOT
      ---
      apiVersion: node.eks.aws/v1alpha1
      kind: NodeConfig
      spec:
        kubelet:
          config:
            shutdownGracePeriod: 30s
            featureGates:
              DisableKubeletCloudCredentialProviders: true
    EOT
    content_type = "application/node.eks.aws"
  }]

  cloudinit_post_nodeadm = [{
    content      = <<-EOT
      echo "All done"
    EOT
    content_type = "text/x-shellscript; charset=\"us-ascii\""
  }]
}

################################################################################
# EKS managed node group - Bottlerocket
################################################################################

module "eks_mng_bottlerocket_no_op" {
  source = "../../modules/_user_data"

  ami_type = "BOTTLEROCKET_x86_64"

  # Hard requirement
  cluster_service_cidr = local.cluster_service_cidr
}

module "eks_mng_bottlerocket_additional" {
  source = "../../modules/_user_data"

  ami_type             = "BOTTLEROCKET_x86_64"
  cluster_service_cidr = local.cluster_service_cidr

  bootstrap_extra_args = <<-EOT
    # extra args added
    [settings.kernel]
    lockdown = "integrity"
  EOT
}

module "eks_mng_bottlerocket_custom_ami" {
  source = "../../modules/_user_data"

  ami_type = "BOTTLEROCKET_x86_64"

  cluster_name         = local.name
  cluster_endpoint     = local.cluster_endpoint
  cluster_auth_base64  = local.cluster_auth_base64
  cluster_service_cidr = local.cluster_service_cidr
  additional_cluster_dns_ips = [
    "169.254.20.10"
  ]

  enable_bootstrap_user_data = true

  bootstrap_extra_args = <<-EOT
    # extra args added
    [settings.kernel]
    lockdown = "integrity"
  EOT
}

module "eks_mng_bottlerocket_custom_template" {
  source = "../../modules/_user_data"

  ami_type = "BOTTLEROCKET_x86_64"

  cluster_name        = local.name
  cluster_endpoint    = local.cluster_endpoint
  cluster_auth_base64 = local.cluster_auth_base64
  # Hard requirement
  cluster_service_cidr = local.cluster_service_cidr

  user_data_template_path = "${path.module}/templates/bottlerocket_custom.tpl"

  bootstrap_extra_args = <<-EOT
    # extra args added
    [settings.kernel]
    lockdown = "integrity"
  EOT
}

################################################################################
# EKS managed node group - Windows
################################################################################

module "eks_mng_windows_no_op" {
  source = "../../modules/_user_data"

  ami_type = "WINDOWS_CORE_2022_x86_64"

  # Hard requirement
  cluster_service_cidr = local.cluster_service_cidr
}

module "eks_mng_windows_additional" {
  source = "../../modules/_user_data"

  ami_type = "WINDOWS_CORE_2022_x86_64"

  # Hard requirement
  cluster_service_cidr = local.cluster_service_cidr

  pre_bootstrap_user_data = <<-EOT
    [string]$Something = 'IDoNotKnowAnyPowerShell ¯\_(ツ)_/¯'
  EOT
}

module "eks_mng_windows_custom_ami" {
  source = "../../modules/_user_data"

  ami_type = "WINDOWS_CORE_2022_x86_64"

  cluster_name        = local.name
  cluster_endpoint    = local.cluster_endpoint
  cluster_auth_base64 = local.cluster_auth_base64
  # Hard requirement
  cluster_service_cidr = local.cluster_service_cidr

  enable_bootstrap_user_data = true

  pre_bootstrap_user_data = <<-EOT
    [string]$Something = 'IDoNotKnowAnyPowerShell ¯\_(ツ)_/¯'
  EOT
  # I don't know if this is the right way on Windows, but its just a string check here anyways
  bootstrap_extra_args = "-KubeletExtraArgs --node-labels=node.kubernetes.io/lifecycle=spot"

  post_bootstrap_user_data = <<-EOT
    [string]$Something = 'IStillDoNotKnowAnyPowerShell ¯\_(ツ)_/¯'
  EOT
}

module "eks_mng_windows_custom_template" {
  source = "../../modules/_user_data"

  ami_type = "WINDOWS_CORE_2022_x86_64"

  cluster_name        = local.name
  cluster_endpoint    = local.cluster_endpoint
  cluster_auth_base64 = local.cluster_auth_base64

  # Hard requirement
  cluster_service_cidr = local.cluster_service_cidr

  enable_bootstrap_user_data = true

  user_data_template_path = "${path.module}/templates/windows_custom.tpl"

  pre_bootstrap_user_data = <<-EOT
    [string]$Something = 'IDoNotKnowAnyPowerShell ¯\_(ツ)_/¯'
  EOT
  # I don't know if this is the right way on Windows, but its just a string check here anyways
  bootstrap_extra_args = "-KubeletExtraArgs --node-labels=node.kubernetes.io/lifecycle=spot"

  post_bootstrap_user_data = <<-EOT
    [string]$Something = 'IStillDoNotKnowAnyPowerShell ¯\_(ツ)_/¯'
  EOT
}

################################################################################
# Self-managed node group - AL2
################################################################################

module "self_mng_al2_no_op" {
  source = "../../modules/_user_data"

  is_eks_managed_node_group = false

  # Hard requirement
  cluster_service_cidr = local.cluster_service_cidr
}

module "self_mng_al2_bootstrap" {
  source = "../../modules/_user_data"

  enable_bootstrap_user_data = true
  is_eks_managed_node_group  = false

  cluster_name         = local.name
  cluster_endpoint     = local.cluster_endpoint
  cluster_auth_base64  = local.cluster_auth_base64
  cluster_service_cidr = local.cluster_service_ipv4_cidr

  pre_bootstrap_user_data = <<-EOT
    echo "foo"
    export FOO=bar
  EOT

  bootstrap_extra_args = "--kubelet-extra-args '--node-labels=node.kubernetes.io/lifecycle=spot'"

  post_bootstrap_user_data = <<-EOT
    echo "All done"
  EOT
}

module "self_mng_al2_bootstrap_ipv6" {
  source = "../../modules/_user_data"

  enable_bootstrap_user_data = true
  is_eks_managed_node_group  = false

  cluster_name         = local.name
  cluster_endpoint     = local.cluster_endpoint
  cluster_auth_base64  = local.cluster_auth_base64
  cluster_ip_family    = "ipv6"
  cluster_service_cidr = local.cluster_service_ipv6_cidr

  pre_bootstrap_user_data = <<-EOT
    echo "foo"
    export FOO=bar
  EOT

  bootstrap_extra_args = "--kubelet-extra-args '--node-labels=node.kubernetes.io/lifecycle=spot'"

  post_bootstrap_user_data = <<-EOT
    echo "All done"
  EOT
}

module "self_mng_al2_custom_template" {
  source = "../../modules/_user_data"

  enable_bootstrap_user_data = true
  is_eks_managed_node_group  = false

  cluster_name         = local.name
  cluster_endpoint     = local.cluster_endpoint
  cluster_auth_base64  = local.cluster_auth_base64
  cluster_service_cidr = local.cluster_service_ipv4_cidr

  user_data_template_path = "${path.module}/templates/linux_custom.tpl"

  pre_bootstrap_user_data = <<-EOT
    echo "foo"
    export FOO=bar
  EOT

  bootstrap_extra_args = "--kubelet-extra-args '--node-labels=node.kubernetes.io/lifecycle=spot'"

  post_bootstrap_user_data = <<-EOT
    echo "All done"
  EOT
}

################################################################################
# Self-managed node group - AL2023
################################################################################

module "self_mng_al2023_no_op" {
  source = "../../modules/_user_data"

  ami_type = "AL2023_x86_64_STANDARD"

  is_eks_managed_node_group = false

  # Hard requirement
  cluster_service_cidr = local.cluster_service_cidr
}

module "self_mng_al2023_bootstrap" {
  source = "../../modules/_user_data"

  ami_type = "AL2023_x86_64_STANDARD"

  enable_bootstrap_user_data = true
  is_eks_managed_node_group  = false

  cluster_name         = local.name
  cluster_endpoint     = local.cluster_endpoint
  cluster_auth_base64  = local.cluster_auth_base64
  cluster_service_cidr = local.cluster_service_cidr

  cloudinit_pre_nodeadm = [{
    content      = <<-EOT
      ---
      apiVersion: node.eks.aws/v1alpha1
      kind: NodeConfig
      spec:
        kubelet:
          config:
            shutdownGracePeriod: 30s
            featureGates:
              DisableKubeletCloudCredentialProviders: true
    EOT
    content_type = "application/node.eks.aws"
  }]

  cloudinit_post_nodeadm = [{
    content      = <<-EOT
      echo "All done"
    EOT
    content_type = "text/x-shellscript; charset=\"us-ascii\""
  }]
}

module "self_mng_al2023_custom_template" {
  source = "../../modules/_user_data"

  ami_type = "AL2023_x86_64_STANDARD"

  enable_bootstrap_user_data = true
  is_eks_managed_node_group  = false

  cluster_name         = local.name
  cluster_endpoint     = local.cluster_endpoint
  cluster_auth_base64  = local.cluster_auth_base64
  cluster_service_cidr = local.cluster_service_cidr

  user_data_template_path = "${path.module}/templates/al2023_custom.tpl"

  cloudinit_pre_nodeadm = [{
    content      = <<-EOT
      ---
      apiVersion: node.eks.aws/v1alpha1
      kind: NodeConfig
      spec:
        kubelet:
          config:
            shutdownGracePeriod: 30s
            featureGates:
              DisableKubeletCloudCredentialProviders: true
    EOT
    content_type = "application/node.eks.aws"
  }]

  cloudinit_post_nodeadm = [{
    content      = <<-EOT
      echo "All done"
    EOT
    content_type = "text/x-shellscript; charset=\"us-ascii\""
  }]
}

################################################################################
# Self-managed node group - Bottlerocket
################################################################################

module "self_mng_bottlerocket_no_op" {
  source = "../../modules/_user_data"

  ami_type = "BOTTLEROCKET_x86_64"

  is_eks_managed_node_group = false

  # Hard requirement
  cluster_service_cidr = local.cluster_service_cidr
}

module "self_mng_bottlerocket_bootstrap" {
  source = "../../modules/_user_data"

  ami_type = "BOTTLEROCKET_x86_64"

  enable_bootstrap_user_data = true
  is_eks_managed_node_group  = false

  cluster_name        = local.name
  cluster_endpoint    = local.cluster_endpoint
  cluster_auth_base64 = local.cluster_auth_base64

  # Hard requirement
  cluster_service_cidr = local.cluster_service_cidr

  bootstrap_extra_args = <<-EOT
    # extra args added
    [settings.kernel]
    lockdown = "integrity"
  EOT
}

module "self_mng_bottlerocket_custom_template" {
  source = "../../modules/_user_data"

  ami_type = "BOTTLEROCKET_x86_64"

  enable_bootstrap_user_data = true
  is_eks_managed_node_group  = false

  cluster_name        = local.name
  cluster_endpoint    = local.cluster_endpoint
  cluster_auth_base64 = local.cluster_auth_base64

  # Hard requirement
  cluster_service_cidr = local.cluster_service_cidr

  user_data_template_path = "${path.module}/templates/bottlerocket_custom.tpl"

  bootstrap_extra_args = <<-EOT
    # extra args added
    [settings.kernel]
    lockdown = "integrity"
  EOT
}

################################################################################
# Self-managed node group - Windows
################################################################################

module "self_mng_windows_no_op" {
  source = "../../modules/_user_data"

  ami_type = "WINDOWS_CORE_2022_x86_64"

  is_eks_managed_node_group = false

  # Hard requirement
  cluster_service_cidr = local.cluster_service_cidr
}

module "self_mng_windows_bootstrap" {
  source = "../../modules/_user_data"

  ami_type = "WINDOWS_CORE_2022_x86_64"

  enable_bootstrap_user_data = true
  is_eks_managed_node_group  = false

  cluster_name        = local.name
  cluster_endpoint    = local.cluster_endpoint
  cluster_auth_base64 = local.cluster_auth_base64

  # Hard requirement
  cluster_service_cidr = local.cluster_service_cidr

  pre_bootstrap_user_data = <<-EOT
    [string]$Something = 'IDoNotKnowAnyPowerShell ¯\_(ツ)_/¯'
  EOT
  # I don't know if this is the right way on Windows, but its just a string check here anyways
  bootstrap_extra_args = "-KubeletExtraArgs --node-labels=node.kubernetes.io/lifecycle=spot"

  post_bootstrap_user_data = <<-EOT
    [string]$Something = 'IStillDoNotKnowAnyPowerShell ¯\_(ツ)_/¯'
  EOT
}

module "self_mng_windows_custom_template" {
  source = "../../modules/_user_data"

  ami_type = "WINDOWS_CORE_2022_x86_64"

  enable_bootstrap_user_data = true
  is_eks_managed_node_group  = false

  cluster_name        = local.name
  cluster_endpoint    = local.cluster_endpoint
  cluster_auth_base64 = local.cluster_auth_base64

  # Hard requirement
  cluster_service_cidr = local.cluster_service_cidr

  user_data_template_path = "${path.module}/templates/windows_custom.tpl"

  pre_bootstrap_user_data = <<-EOT
    [string]$Something = 'IDoNotKnowAnyPowerShell ¯\_(ツ)_/¯'
  EOT
  # I don't know if this is the right way on Windows, but its just a string check here anyways
  bootstrap_extra_args = "-KubeletExtraArgs --node-labels=node.kubernetes.io/lifecycle=spot"

  post_bootstrap_user_data = <<-EOT
    [string]$Something = 'IStillDoNotKnowAnyPowerShell ¯\_(ツ)_/¯'
  EOT
}
