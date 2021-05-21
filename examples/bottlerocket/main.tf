terraform {
  required_version = ">= 0.13.0"
}

resource "tls_private_key" "nodes" {
  algorithm = "RSA"
}

resource "aws_key_pair" "nodes" {
  key_name   = "bottlerocket-nodes"
  public_key = tls_private_key.nodes.public_key_openssh
}

module "eks" {
  source          = "../.."
  cluster_name    = "bottlerocket"
  cluster_version = var.k8s_version
  subnets         = data.aws_subnet_ids.default.ids

  vpc_id = data.aws_vpc.default.id

  write_kubeconfig = false
  manage_aws_auth  = false

  worker_groups_launch_template = [
    {
      name = "bottlerocket-nodes"
      # passing bottlerocket ami id
      ami_id               = data.aws_ami.bottlerocket_ami.id
      instance_type        = "t3a.small"
      asg_desired_capacity = 2
      key_name             = aws_key_pair.nodes.key_name

      # Since we are using default VPC there is no NAT gateway so we need to
      # attach public ip to nodes so they can reach k8s API server
      # do not repeat this at home (i.e. production)
      public_ip = true

      # This section overrides default userdata template to pass bottlerocket
      # specific user data
      userdata_template_file = "${path.module}/userdata.toml"
      # we are using this section to pass additional arguments for
      # userdata template rendering
      userdata_template_extra_args = {
        enable_admin_container   = var.enable_admin_container
        enable_control_container = var.enable_control_container
        aws_region               = data.aws_region.current.name
      }
      # example of k8s/kubelet configuration via additional_userdata
      additional_userdata = <<EOT
[settings.kubernetes.node-labels]
ingress = "allowed"
EOT
    }
  ]
}

# SSM policy for bottlerocket control container access
# https://github.com/bottlerocket-os/bottlerocket/blob/develop/QUICKSTART-EKS.md#enabling-ssm
resource "aws_iam_policy_attachment" "ssm" {
  name       = "ssm"
  roles      = [module.eks.worker_iam_role_name]
  policy_arn = data.aws_iam_policy.ssm.arn
}
