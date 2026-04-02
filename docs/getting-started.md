# Getting Started

## Prerequisites

Before you begin, ensure you have:

- An AWS account with permissions to create EKS clusters, IAM roles, security groups, and related resources
- Terraform >= 1.5.7 installed ([download](https://developer.hashicorp.com/terraform/downloads))
- AWS CLI configured with valid credentials (`aws configure`)
- A VPC with subnets — the module does not create a VPC. Use [terraform-aws-modules/vpc/aws](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest) if you need one
- kubectl for interacting with your cluster after creation ([install](https://kubernetes.io/docs/tasks/tools/))

## Your first cluster

The fastest path to a working cluster is EKS Auto Mode. Create a file named `main.tf`:

```hcl
provider "aws" {
  region = "us-west-2"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "eks-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  # Use one NAT per AZ in production for high availability
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "my-first-cluster"
  kubernetes_version = "1.35"

  # EKS Auto Mode manages compute, networking, DNS,
  # storage, load balancing, and pod identity
  compute_config = {
    enabled    = true
    node_pools = ["general-purpose"]
  }

  # Allow access to the cluster from your local machine
  endpoint_public_access = true

  # Make the current IAM caller a cluster admin
  enable_cluster_creator_admin_permissions = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_name" {
  value = module.eks.cluster_name
}
```

Deploy the cluster:

```bash
terraform init
terraform plan
terraform apply
```

Cluster creation takes approximately 10-15 minutes.

## Connect to your cluster

Once the cluster is created, configure kubectl:

```bash
aws eks update-kubeconfig --region us-west-2 --name my-first-cluster
```

Verify connectivity:

```bash
kubectl get nodes
kubectl get pods -A
```

## What was created

The module provisions an EKS cluster, IAM roles, security groups, a CloudWatch log group, an OIDC provider, and a cluster access entry — with Auto Mode handling EC2 instance provisioning as workloads require them.

## Next steps

- More compute control? Use [EKS Managed Node Groups](compute/eks-managed-node-groups.md) or [Self-Managed Node Groups](compute/self-managed-node-groups.md) instead of Auto Mode
- Autoscaling? Set up [Karpenter](compute/karpenter.md) for intelligent node provisioning
- Add-ons? Configure [cluster add-ons](cluster/addons.md) like CoreDNS, VPC CNI, and kube-proxy
- Access control? Set up [access entries](cluster/access-entries.md) for team members
- Serverless? Run pods on [Fargate](compute/fargate.md) without managing nodes
- All examples? Browse the [examples gallery](examples.md)
