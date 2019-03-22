data "aws_availability_zones" "available" {}

resource "aws_vpc_ipv4_cidr_block_association" "kube" {
  vpc_id     = "${var.vpc_id}"
  cidr_block = "${var.cni_cidr_block}"
  count      = "${length(var.cni_cidr_block) > 0 ? 1 : 0}"
}

resource "aws_subnet" "kube" {
  count = "${length(var.cni_cidr_block) > 0 ? length(data.aws_availability_zones.available.names) : 0}"

  vpc_id            = "${aws_vpc_ipv4_cidr_block_association.kube.0.vpc_id}"
  availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"
  cidr_block        = "${cidrsubnet(aws_vpc_ipv4_cidr_block_association.kube.0.cidr_block, length(data.aws_availability_zones.available.names) - 1, count.index)}"

  tags = "${merge(
    var.tags,
    map(
      "Name", "${var.cluster_name}-${element(data.aws_availability_zones.available.names, count.index)}",
      "kubernetes.io/cluster/${var.cluster_name}", "shared"
      )
  )}"
}
