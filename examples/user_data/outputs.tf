################################################################################
# We are writing to local file so that we can better track diffs across changes
#
# Its harder to verify changes and diffs when we use the standard `output`
# route, writing to file makes this easier and better highlights changes
# to avoid unintended disruptions
################################################################################

################################################################################
# EKS managed node group - AL2
################################################################################

resource "local_file" "eks_mng_al2_no_op" {
  content  = base64decode(module.eks_mng_al2_no_op.user_data)
  filename = "${path.module}/rendered/al2/eks-mng-no-op.sh"
}

resource "local_file" "eks_mng_al2_additional" {
  content  = base64decode(module.eks_mng_al2_additional.user_data)
  filename = "${path.module}/rendered/al2/eks-mng-additional.txt"
}

resource "local_file" "eks_mng_al2_custom_ami" {
  content  = base64decode(module.eks_mng_al2_custom_ami.user_data)
  filename = "${path.module}/rendered/al2/eks-mng-custom-ami.sh"
}

resource "local_file" "eks_mng_al2_custom_ami_ipv6" {
  content  = base64decode(module.eks_mng_al2_custom_ami_ipv6.user_data)
  filename = "${path.module}/rendered/al2/eks-mng-custom-ami-ipv6.sh"
}

resource "local_file" "eks_mng_al2_custom_template" {
  content  = base64decode(module.eks_mng_al2_custom_template.user_data)
  filename = "${path.module}/rendered/al2/eks-mng-custom-template.sh"
}

################################################################################
# EKS managed node group - AL2023
################################################################################

resource "local_file" "eks_mng_al2023_no_op" {
  content  = base64decode(module.eks_mng_al2023_no_op.user_data)
  filename = "${path.module}/rendered/al2023/eks-mng-no-op.txt"
}

resource "local_file" "eks_mng_al2023_additional" {
  content  = base64decode(module.eks_mng_al2023_additional.user_data)
  filename = "${path.module}/rendered/al2023/eks-mng-additional.txt"
}

resource "local_file" "eks_mng_al2023_custom_ami" {
  content  = base64decode(module.eks_mng_al2023_custom_ami.user_data)
  filename = "${path.module}/rendered/al2023/eks-mng-custom-ami.txt"
}

resource "local_file" "eks_mng_al2023_custom_template" {
  content  = base64decode(module.eks_mng_al2023_custom_template.user_data)
  filename = "${path.module}/rendered/al2023/eks-mng-custom-template.txt"
}

################################################################################
# EKS managed node group - Bottlerocket
################################################################################

resource "local_file" "eks_mng_bottlerocket_no_op" {
  content  = base64decode(module.eks_mng_bottlerocket_no_op.user_data)
  filename = "${path.module}/rendered/bottlerocket/eks-mng-no-op.toml"
}

resource "local_file" "eks_mng_bottlerocket_additional" {
  content  = base64decode(module.eks_mng_bottlerocket_additional.user_data)
  filename = "${path.module}/rendered/bottlerocket/eks-mng-additional.toml"
}

resource "local_file" "eks_mng_bottlerocket_custom_ami" {
  content  = base64decode(module.eks_mng_bottlerocket_custom_ami.user_data)
  filename = "${path.module}/rendered/bottlerocket/eks-mng-custom-ami.toml"
}

resource "local_file" "eks_mng_bottlerocket_custom_template" {
  content  = base64decode(module.eks_mng_bottlerocket_custom_template.user_data)
  filename = "${path.module}/rendered/bottlerocket/eks-mng-custom-template.toml"
}

################################################################################
# EKS managed node group - Windows
################################################################################

resource "local_file" "eks_mng_windows_no_op" {
  content  = base64decode(module.eks_mng_windows_no_op.user_data)
  filename = "${path.module}/rendered/windows/eks-mng-no-op.ps1"
}

resource "local_file" "eks_mng_windows_additional" {
  content  = base64decode(module.eks_mng_windows_additional.user_data)
  filename = "${path.module}/rendered/windows/eks-mng-additional.ps1"
}

resource "local_file" "eks_mng_windows_custom_ami" {
  content  = base64decode(module.eks_mng_windows_custom_ami.user_data)
  filename = "${path.module}/rendered/windows/eks-mng-custom-ami.ps1"
}

resource "local_file" "eks_mng_windows_custom_template" {
  content  = base64decode(module.eks_mng_windows_custom_template.user_data)
  filename = "${path.module}/rendered/windows/eks-mng-custom-template.ps1"
}

################################################################################
# Self-managed node group - AL2
################################################################################

resource "local_file" "self_mng_al2_no_op" {
  content  = base64decode(module.self_mng_al2_no_op.user_data)
  filename = "${path.module}/rendered/al2/self-mng-no-op.sh"
}

resource "local_file" "self_mng_al2_bootstrap" {
  content  = base64decode(module.self_mng_al2_bootstrap.user_data)
  filename = "${path.module}/rendered/al2/self-mng-bootstrap.sh"
}

resource "local_file" "self_mng_al2_bootstrap_ipv6" {
  content  = base64decode(module.self_mng_al2_bootstrap_ipv6.user_data)
  filename = "${path.module}/rendered/al2/self-mng-bootstrap-ipv6.sh"
}

resource "local_file" "self_mng_al2_custom_template" {
  content  = base64decode(module.self_mng_al2_custom_template.user_data)
  filename = "${path.module}/rendered/al2/self-mng-custom-template.sh"
}

################################################################################
# Self-managed node group - AL2023
################################################################################

resource "local_file" "self_mng_al2023_no_op" {
  content  = base64decode(module.self_mng_al2023_no_op.user_data)
  filename = "${path.module}/rendered/al2023/self-mng-no-op.txt"
}

resource "local_file" "self_mng_al2023_bootstrap" {
  content  = base64decode(module.self_mng_al2023_bootstrap.user_data)
  filename = "${path.module}/rendered/al2023/self-mng-bootstrap.txt"
}

resource "local_file" "self_mng_al2023_custom_template" {
  content  = base64decode(module.self_mng_al2023_custom_template.user_data)
  filename = "${path.module}/rendered/al2023/self-mng-custom-template.txt"
}

################################################################################
# Self-managed node group - Bottlerocket
################################################################################

resource "local_file" "self_mng_bottlerocket_no_op" {
  content  = base64decode(module.self_mng_bottlerocket_no_op.user_data)
  filename = "${path.module}/rendered/bottlerocket/self-mng-no-op.toml"
}

resource "local_file" "self_mng_bottlerocket_bootstrap" {
  content  = base64decode(module.self_mng_bottlerocket_bootstrap.user_data)
  filename = "${path.module}/rendered/bottlerocket/self-mng-bootstrap.toml"
}

resource "local_file" "self_mng_bottlerocket_custom_template" {
  content  = base64decode(module.self_mng_bottlerocket_custom_template.user_data)
  filename = "${path.module}/rendered/bottlerocket/self-mng-custom-template.toml"
}

################################################################################
# Self-managed node group - Windows
################################################################################

resource "local_file" "self_mng_windows_no_op" {
  content  = base64decode(module.self_mng_windows_no_op.user_data)
  filename = "${path.module}/rendered/windows/self-mng-no-op.ps1"
}

resource "local_file" "self_mng_windows_bootstrap" {
  content  = base64decode(module.self_mng_windows_bootstrap.user_data)
  filename = "${path.module}/rendered/windows/self-mng-bootstrap.ps1"
}

resource "local_file" "self_mng_windows_custom_template" {
  content  = base64decode(module.self_mng_windows_custom_template.user_data)
  filename = "${path.module}/rendered/windows/self-mng-custom-template.ps1"
}
