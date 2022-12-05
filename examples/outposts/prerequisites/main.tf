provider "aws" {
  region = var.region
}

locals {
  name = "ex-${basename(path.cwd)}"

  terraform_version = "1.3.6"

  outpost_arn   = element(tolist(data.aws_outposts_outposts.this.arns), 0)
  instance_type = element(tolist(data.aws_outposts_outpost_instance_types.this.instance_types), 0)

  tags = {
    Example    = local.name
    GithubRepo = "terraform-aws-eks"
    GithubOrg  = "terraform-aws-modules"
  }
}

################################################################################
# Pre-Requisites
################################################################################

module "ssm_bastion_ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 4.2"

  name = "${local.name}-bastion"

  create_iam_instance_profile = true
  iam_role_policies = {
    AdministratorAccess = "arn:aws:iam::aws:policy/AdministratorAccess"
  }

  instance_type = local.instance_type

  user_data = <<-EOT
    #!/bin/bash

    # Add ssm-user since it won't exist until first login
    adduser -m ssm-user
    tee /etc/sudoers.d/ssm-agent-users <<'EOF'
    # User rules for ssm-user
    ssm-user ALL=(ALL) NOPASSWD:ALL
    EOF
    chmod 440 /etc/sudoers.d/ssm-agent-users

    cd /home/ssm-user

    # Install git to clone repo
    yum install git -y

    # Install Terraform
    curl -sSO https://releases.hashicorp.com/terraform/${local.terraform_version}/terraform_${local.terraform_version}_linux_amd64.zip
    sudo unzip -qq terraform_${local.terraform_version}_linux_amd64.zip terraform -d /usr/bin/
    rm terraform_${local.terraform_version}_linux_amd64.zip 2> /dev/null

    # Install kubectl
    curl -LO https://dl.k8s.io/release/v1.21.0/bin/linux/amd64/kubectl
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

    # Remove default awscli which is v1 - we want latest v2
    yum remove awscli -y
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip -qq awscliv2.zip
    ./aws/install

    # Clone repo
    git clone https://github.com/bryantbiggs/terraform-aws-eks.git \
    && cd /home/ssm-user/terraform-aws-eks \
    && git checkout refactor/v19

    chown -R ssm-user:ssm-user /home/ssm-user/
  EOT

  vpc_security_group_ids = [module.bastion_security_group.security_group_id]
  subnet_id              = element(data.aws_subnets.this.ids, 0)

  tags = local.tags
}

module "bastion_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "${local.name}-bastion"
  description = "Security group to allow provisioning ${local.name} EKS local cluster on Outposts"
  vpc_id      = data.aws_vpc.this.id

  ingress_with_cidr_blocks = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = data.aws_vpc.this.cidr_block
    },
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  tags = local.tags
}

################################################################################
# Supporting Resources
################################################################################

data "aws_outposts_outposts" "this" {}

data "aws_outposts_outpost_instance_types" "this" {
  arn = local.outpost_arn
}

# This just grabs the first Outpost and returns its subnets
data "aws_subnets" "lookup" {
  filter {
    name   = "outpost-arn"
    values = [local.outpost_arn]
  }
}

# This grabs a single subnet to reverse lookup those that belong to same VPC
# This is whats used for the cluster
data "aws_subnet" "this" {
  id = element(tolist(data.aws_subnets.lookup.ids), 0)
}

# These are subnets for the Outpost and restricted to the same VPC
# This is whats used for the cluster
data "aws_subnets" "this" {
  filter {
    name   = "outpost-arn"
    values = [local.outpost_arn]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_subnet.this.vpc_id]
  }
}

data "aws_vpc" "this" {
  id = data.aws_subnet.this.vpc_id
}
