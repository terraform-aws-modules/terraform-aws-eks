module "eks" {
  source                          = "../.."
  cluster_name                    = local.cluster_name
  cluster_version                 = var.cluster_version
  vpc_id                          = module.vpc.vpc_id
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  subnets         = [module.vpc.private_subnets[0], module.vpc.public_subnets[1]]
  fargate_subnets = [module.vpc.private_subnets[2]]

  fargate_profiles = {
    default = {
      name = "default"
      selectors = [
        {
          namespace = "kube-system"
          labels = {
            k8s-app = "kube-dns"
          }
        },
        {
          namespace = "default"
          labels = {
            WorkerType = "fargate"
          }
        }
      ]

      tags = {
        Owner = "default"
      }
    }

    secondary = {
      name = "secondary"
      selectors = [
        {
          namespace = "default"
          labels = {
            Environment = "test"
            GithubRepo  = "terraform-aws-eks"
            GithubOrg   = "terraform-aws-modules"
          }
        }
      ]

      # Using specific subnets instead of the ones configured in EKS (`subnets` and `fargate_subnets`)
      subnets = [module.vpc.private_subnets[1]]

      tags = {
        Owner = "secondary"
      }
    }
  }

  manage_aws_auth = false

  tags = {
    Example    = var.example_name
    GithubRepo = "terraform-aws-eks"
    GithubOrg  = "terraform-aws-modules"
  }
}
