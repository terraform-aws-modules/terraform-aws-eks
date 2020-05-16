provider "aws" {
  region = var.region
}

module "eks" {
  source     = "../.."
  create_eks = false

  vpc_id       = ""
  cluster_name = ""
  subnets      = []
}
