resource "aws_eks_cluster" "this" {
  name     = "${var.cluster_name}"
  role_arn = "${aws_iam_role.cluster.arn}"
  version  = "${var.cluster_version}"

  vpc_config {
    security_group_ids = ["${aws_security_group.cluster.id}"]
    subnet_ids         = ["${var.subnets}"]
  }

  depends_on = [
    "aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.cluster_AmazonEKSServicePolicy",
  ]
}

resource "aws_security_group" "cluster" {
  name_prefix = "${var.cluster_name}"
  description = "Cluster communication with workers nodes"
  vpc_id      = "${var.vpc_id}"
  tags        = "${merge(var.tags, map("Name", "${var.cluster_name}-eks_cluster_sg"))}"
}

resource "aws_security_group_rule" "cluster_egress_internet" {
  description       = "Allow cluster egress to the Internet."
  protocol          = "-1"
  security_group_id = "${aws_security_group.cluster.id}"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "cluster_https_worker_ingress" {
  description              = "Allow pods to communicate with the cluster API Server."
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.cluster.id}"
  source_security_group_id = "${aws_security_group.workers.id}"
  from_port                = 443
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "cluster_https_cidr_ingress" {
  cidr_blocks       = ["${var.cluster_ingress_cidrs}"]
  description       = "Allow communication with the cluster API Server."
  protocol          = "tcp"
  security_group_id = "${aws_security_group.cluster.id}"
  from_port         = 443
  to_port           = 443
  type              = "ingress"
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
