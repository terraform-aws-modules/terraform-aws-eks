resource "aws_autoscaling_group" "workers" {
  name_prefix          = "${var.cluster_name}"
  launch_configuration = "${aws_launch_configuration.workers.id}"
  desired_capacity     = "${var.workers_asg_desired_capacity}"
  max_size             = "${var.workers_asg_max_size}"
  min_size             = "${var.workers_asg_min_size}"
  vpc_zone_identifier  = ["${var.subnets}"]

  tags = ["${concat(
    list(
      map("key", "Name", "value", "${var.cluster_name}-eks_asg", "propagate_at_launch", true),
      map("key", "kubernetes.io/cluster/${var.cluster_name}", "value", "owned", "propagate_at_launch", true),
    ),
    local.asg_tags)
  }"]
}

resource "aws_launch_configuration" "workers" {
  associate_public_ip_address = true
  name_prefix                 = "${var.cluster_name}"
  iam_instance_profile        = "${aws_iam_instance_profile.workers.name}"
  image_id                    = "${var.workers_ami_id}"
  instance_type               = "${var.workers_instance_type}"
  security_groups             = ["${aws_security_group.workers.id}"]
  user_data_base64            = "${base64encode(local.workers_userdata)}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "workers" {
  name_prefix = "${var.cluster_name}"
  description = "Security group for all nodes in the cluster."
  vpc_id      = "${var.vpc_id}"
  tags        = "${merge(var.tags, map("Name", "${var.cluster_name}-eks_worker_sg", "kubernetes.io/cluster/${var.cluster_name}", "owned"
  ))}"
}

resource "aws_security_group_rule" "workers_egress_internet" {
  description       = "Allow nodes all egress to the Internet."
  protocol          = "-1"
  security_group_id = "${aws_security_group.workers.id}"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "workers_ingress_self" {
  description              = "Allow node to communicate with each other."
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.workers.id}"
  source_security_group_id = "${aws_security_group.workers.id}"
  from_port                = 0
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster" {
  description              = "Allow workers Kubelets and pods to receive communication from the cluster control plane."
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.workers.id}"
  source_security_group_id = "${aws_security_group.cluster.id}"
  from_port                = 1025
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_iam_role" "workers" {
  name_prefix        = "${var.cluster_name}"
  assume_role_policy = "${data.aws_iam_policy_document.workers_assume_role_policy.json}"
}

resource "aws_iam_instance_profile" "workers" {
  name_prefix = "${var.cluster_name}"
  role        = "${aws_iam_role.workers.name}"
}

resource "aws_iam_role_policy_attachment" "workers_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.workers.name}"
}

resource "aws_iam_role_policy_attachment" "workers_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.workers.name}"
}

resource "aws_iam_role_policy_attachment" "workers_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.workers.name}"
}
