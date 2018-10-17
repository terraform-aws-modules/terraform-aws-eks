resource "aws_eks_cluster" "this" {
  name     = "${var.cluster_name}"
  role_arn = "${aws_iam_role.cluster.arn}"
  version  = "${var.cluster_version}"

  vpc_config {
    security_group_ids = ["${local.cluster_security_group_id}"]
    subnet_ids         = ["${var.subnets}"]
  }

  timeouts {
    create = "${var.cluster_create_timeout}"
    delete = "${var.cluster_delete_timeout}"
  }

  depends_on = [
    "aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.cluster_AmazonEKSServicePolicy",
  ]
}

resource "aws_security_group" "cluster" {
  name_prefix = "${var.cluster_name}"
  description = "EKS cluster security group."
  vpc_id      = "${var.vpc_id}"
  tags        = "${merge(var.tags, map("Name", "${var.cluster_name}-eks_cluster_sg"))}"
  count       = "${var.cluster_security_group_id == "" ? 1 : 0}"
}

resource "aws_security_group_rule" "cluster_egress_internet" {
  description       = "Allow cluster egress access to the Internet."
  protocol          = "-1"
  security_group_id = "${aws_security_group.cluster.id}"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  type              = "egress"
  count             = "${var.cluster_security_group_id == "" ? 1 : 0}"
}

resource "aws_security_group_rule" "cluster_https_worker_ingress" {
  description              = "Allow pods to communicate with the EKS cluster API."
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.cluster.id}"
  source_security_group_id = "${local.worker_security_group_id}"
  from_port                = 443
  to_port                  = 443
  type                     = "ingress"
  count                    = "${var.cluster_security_group_id == "" ? 1 : 0}"
}

resource "aws_iam_role" "cluster" {
  name_prefix        = "${var.cluster_name}"
  assume_role_policy = "${data.aws_iam_policy_document.cluster_assume_role_policy.json}"
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.cluster.name}"
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.cluster.name}"
}
