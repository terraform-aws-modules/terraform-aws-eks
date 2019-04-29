data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

data "terraform_remote_state" "vpc" {
  backend   = "s3"
  workspace = "${terraform.workspace}"

  config {
    region = "us-east-1"
    bucket = "traderev-tf-state-store"
    key    = "vpc.tfstate"
  }
}

data "aws_vpc" "app_vpc" {
  id = "${data.terraform_remote_state.vpc.vpc_id}"
}

# Get ARN of DevOps group
data "aws_iam_group" "devops" {
  group_name = "Devops-tf"
}

# Get ARN of Admins group
data "aws_iam_group" "admins" {
  group_name = "Admin-tf"
}
