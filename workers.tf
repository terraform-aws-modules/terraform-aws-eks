

resource "aws_security_group" "workers" {
  count       = var.worker_security_group_id == "" && var.create_eks ? 1 : 0
  name_prefix = aws_eks_cluster.this[0].name
  description = "Security group for all nodes in the cluster."
  vpc_id      = var.vpc_id
  tags = merge(
    var.tags,
    {
      "Name"                                                  = "${aws_eks_cluster.this[0].name}-eks_worker_sg"
      "kubernetes.io/cluster/${aws_eks_cluster.this[0].name}" = "owned"
      #"karpenter.sh/discovery"                                = aws_eks_cluster.this[0].name
    },
  )
}

resource "aws_security_group_rule" "workers_egress_whole_internet" {
  count             = var.worker_security_group_id == "" && var.create_eks && var.allow_all_egress ? 1 : 0
  description       = "Allow nodes all egress to the Internet."
  protocol          = "-1"
  security_group_id = local.worker_security_group_id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "workers_egress_cidr_blocks_internet" {
  count             = var.worker_security_group_id == "" && var.create_eks && ! var.allow_all_egress ? 1 : 0
  description       = "Allow nodes all egress to these cidr blocks."
  protocol          = "-1"
  security_group_id = local.worker_security_group_id
  cidr_blocks       = var.egress_cidr_blocks_allowed
  from_port         = 0
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "workers_egress_internet_ports" {
  count             = var.worker_security_group_id == "" && var.create_eks && ! var.allow_all_egress ? length(var.egress_ports_allowed) : 0
  description       = "Allow nodes all egress to the Internet on these ports."
  protocol          = "tcp"
  security_group_id = local.worker_security_group_id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = var.egress_ports_allowed[count.index]
  to_port           = var.egress_ports_allowed[count.index]
  type              = "egress"
}

resource "aws_security_group_rule" "workers_egress_custom_rules" {
  count             = var.worker_security_group_id == "" && var.create_eks && ! var.allow_all_egress ? length(var.egress_custom_allowed) : 0
  description       = "Allow nodes all egress to these custom blocks and ports."
  protocol          = "tcp"
  security_group_id = local.worker_security_group_id
  cidr_blocks       = var.egress_custom_allowed[count.index].cidr_blocks
  from_port         = var.egress_custom_allowed[count.index].from_port
  to_port           = var.egress_custom_allowed[count.index].to_port
  type              = "egress"
}

resource "aws_security_group_rule" "workers_ingress_self" {
  count                    = var.worker_security_group_id == "" && var.create_eks ? 1 : 0
  description              = "Allow node to communicate with each other."
  protocol                 = "-1"
  security_group_id        = local.worker_security_group_id
  source_security_group_id = local.worker_security_group_id
  from_port                = 0
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster" {
  count                    = var.worker_security_group_id == "" && var.create_eks ? 1 : 0
  description              = "Allow workers pods to receive communication from the cluster control plane."
  protocol                 = "tcp"
  security_group_id        = local.worker_security_group_id
  source_security_group_id = local.cluster_security_group_id
  from_port                = var.worker_sg_ingress_from_port
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster_kubelet" {
  count                    = var.worker_security_group_id == "" && var.create_eks ? var.worker_sg_ingress_from_port > 10250 ? 1 : 0 : 0
  description              = "Allow workers Kubelets to receive communication from the cluster control plane."
  protocol                 = "tcp"
  security_group_id        = local.worker_security_group_id
  source_security_group_id = local.cluster_security_group_id
  from_port                = 10250
  to_port                  = 10250
  type                     = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster_https" {
  count                    = var.worker_security_group_id == "" && var.create_eks ? 1 : 0
  description              = "Allow pods running extension API servers on port 443 to receive communication from cluster control plane."
  protocol                 = "tcp"
  security_group_id        = local.worker_security_group_id
  source_security_group_id = local.cluster_security_group_id
  from_port                = 443
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_iam_role" "workers" {
  count                 = var.manage_worker_iam_resources && var.create_eks ? 1 : 0
  name_prefix           = var.workers_role_name != "" ? null : aws_eks_cluster.this[0].name
  name                  = var.workers_role_name != "" ? var.workers_role_name : null
  assume_role_policy    = data.aws_iam_policy_document.workers_assume_role_policy.json
  permissions_boundary  = var.permissions_boundary
  path                  = var.iam_path
  force_detach_policies = true
  tags                  = var.tags
}

resource "aws_iam_role_policy_attachment" "workers_AmazonEKSWorkerNodePolicy" {
  count      = var.manage_worker_iam_resources && var.create_eks ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.workers[0].name
}

resource "aws_iam_role_policy_attachment" "workers_AmazonEKS_CNI_Policy" {
  count      = var.manage_worker_iam_resources && var.attach_worker_cni_policy && var.create_eks ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.workers[0].name
}

resource "aws_iam_role_policy_attachment" "workers_AmazonEC2ContainerRegistryReadOnly" {
  count      = var.manage_worker_iam_resources && var.create_eks ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.workers[0].name
}

resource "aws_iam_role_policy_attachment" "workers_additional_policies" {
  count      = var.manage_worker_iam_resources && var.create_eks ? length(var.workers_additional_policies) : 0
  role       = aws_iam_role.workers[0].name
  policy_arn = var.workers_additional_policies[count.index]
}