resource "aws_eks_fargate_profile" "workers" {
  for_each = local.fargate_profiles
  
  fargate_profile_name = join("-", [var.cluster_name, each.key, random_pet.fargate_profiles[each.key].id])

  cluster_name           = var.cluster_name
  pod_execution_role_arn = lookup(each.value, "iam_role_arn", aws_iam_role.fargate[0].arn)
  subnet_ids             = lookup(each.value, "subnets", local.fargate_profiles_defaults["subnets"])

  selector {
    namespace = lookup(each.value, "namespace", local.fargate_profiles_defaults["namespace"])
    labels    = lookup(each.value, "labels", local.fargate_profiles_defaults["labels"])
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "random_pet" "fargate_profiles" {
  for_each = local.fargate_profiles

  separator = "-"
  length    = 2

  keepers = {
    fargate_profile_name = join("-", [var.cluster_name, each.value["name"]])
    namespace            = lookup(each.value, "namespace", local.fargate_profiles_defaults["namespace"])
  }
}

resource "aws_iam_role" "fargate" {
  count                 = var.create_eks && local.fargate_profiles_count > 0 ? 1 : 0
  name                  = "${var.fargate_iam_role_name != "" ? var.fargate_iam_role_name : aws_eks_cluster.this[0].name}-fargate-profile"
  assume_role_policy    = data.aws_iam_policy_document.fargate_assume_role_policy.json
  permissions_boundary  = var.permissions_boundary
  path                  = var.iam_path
  force_detach_policies = true
  tags                  = var.tags
}

resource "aws_iam_role_policy_attachment" "fargate_AmazonEKSFargatePodExecutionRolePolicy" {
  count      = var.create_eks && local.fargate_profiles_count > 0 ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate[0].name
}
