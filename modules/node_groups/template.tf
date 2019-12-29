data "template_file" "node_group_arns" {
  for_each = aws_eks_node_group.workers
  template = file("${path.module}/../../templates/worker-role.tpl")

  vars = {
    worker_role_arn = each.value.node_role_arn
    platform        = "linux" # Hardcoded because the EKS API currently only supports linux for managed node groups
  }
}
