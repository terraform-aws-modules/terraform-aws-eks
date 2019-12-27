data "template_file" "node_group_arns" {
  for_each = local.node_groups
  template = file("${path.module}/../../templates/worker-role.tpl")

  vars = {
    worker_role_arn = aws_eks_node_group.workers[each.key].node_role_arn
    platform        = "linux" # Hardcoded because the EKS API currently only supports linux for managed node groups
  }
}
