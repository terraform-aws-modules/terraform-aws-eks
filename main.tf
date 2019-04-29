module "eks" {
  source       = "./terraform-aws-eks"
  cluster_name = "terraform-eks-${terraform.workspace}"
  subnets      = ["${data.terraform_remote_state.vpc.public_subnets}"]
  vpc_id       = "${data.terraform_remote_state.vpc.vpc_id}"
  map_roles    = "${local.eks_map_roles}"

  worker_groups = [
    {
      instance_type = "m5.large"
      asg_max_size  = 5
    },
  ]

  tags {
    Name = "terraform-eks-${terraform.workspace}"
  }
}

data "aws_caller_identity" "current" {}

locals {
  eks_map_roles = [
    {
      role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/*"
      username = "admin:{{SessionName}}"
      group    = "system:masters"
    },
    {
      role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/*"
      username = "admin:{{SessionName}}"
      group    = "system:masters"
    },
  ]
}
