module "eks" {
  source                          = "../.."
  cluster_name                    = local.cluster_name
  cluster_version                 = var.cluster_version
  vpc_id                          = module.vpc.vpc_id
  subnets                         = module.vpc.private_subnets
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  write_kubeconfig = false
  manage_aws_auth  = true

  worker_groups_launch_template = [
    {
      name                 = "bottlerocket-nodes"
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
        enable_admin_container   = false
        enable_control_container = true
        aws_region               = var.region
      }
      # example of k8s/kubelet configuration via additional_userdata
      additional_userdata = <<EOT
[settings.kubernetes.node-labels]
ingress = "allowed"
EOT
    }
  ]

  tags = {
    Example    = var.example_name
    GithubRepo = "terraform-aws-eks"
    GithubOrg  = "terraform-aws-modules"
  }
}

# SSM policy for bottlerocket control container access
# https://github.com/bottlerocket-os/bottlerocket/blob/develop/QUICKSTART-EKS.md#enabling-ssm
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = module.eks.worker_iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

################################################################################
# Supporting Resources
################################################################################

data "aws_ami" "bottlerocket_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["bottlerocket-aws-k8s-${var.cluster_version}-x86_64-*"]
  }
}

resource "tls_private_key" "nodes" {
  algorithm = "RSA"
}

resource "aws_key_pair" "nodes" {
  key_name   = "bottlerocket-nodes-${random_string.suffix.result}"
  public_key = tls_private_key.nodes.public_key_openssh
}
