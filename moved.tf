moved {
  from = aws_iam_role.cluster[0]
  to   = aws_iam_role.this[0]
}

moved {
  from = aws_security_group.workers[0]
  to   = aws_security_group.node[0]
}

moved {
  from = module.node_groups.aws_eks_node_group.workers["preview"]
  to   = module.eks_managed_node_group["preview"].aws_eks_node_group.this[0]
}

moved {
  from = module.node_groups.aws_launch_template.workers["preview"]
  to   = module.eks_managed_node_group["preview"].aws_launch_template.this[0]
}

moved {
  from =   aws_iam_role.workers[0]
  to = module.eks_managed_node_group["preview"].aws_iam_role.this[0]
}

moved {
    from = aws_iam_role_policy_attachment.workers_AmazonEC2ContainerRegistryReadOnly[0]
    to = module.eks_managed_node_group["preview"].aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"]
}

moved {
  from = aws_iam_role_policy_attachment.workers_AmazonEKSWorkerNodePolicy[0]
  to = module.eks_managed_node_group["preview"].aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"]
}

moved {
  from = aws_iam_role_policy_attachment.workers_AmazonEKS_CNI_Policy[0]
  to = module.eks_managed_node_group["preview"].aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"]
}
