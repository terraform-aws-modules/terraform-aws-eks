resource "aws_security_group" "this" {
  name_prefix = "${var.name}"
  vpc_id      = var.vpc_id
  description = "${var.name} outpost node security group"
  tags = merge(var.tags, {
    NodeType = "secure"
    Usage    = "private"
  })
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "outpost_subnet_ingress" {
  description       = "outpost node subnet ingress"
  protocol          = "tcp"
  from_port         = 0
  to_port           = 65535
  type              = "ingress"
  cidr_blocks       = [data.aws_subnet.outpost_node_subnet.cidr_block]
  security_group_id = aws_security_group.this.id
  depends_on = [
    aws_security_group.this
  ]
}

resource "aws_security_group_rule" "outpost_subnet_egress" {
  description       = "outpost node subnet egress"
  protocol          = "tcp"
  from_port         = 0
  to_port           = 65535
  type              = "egress"
  cidr_blocks       = [data.aws_subnet.outpost_node_subnet.cidr_block]
  security_group_id = aws_security_group.this.id
  depends_on = [
    aws_security_group.this
  ]
}

resource "aws_security_group_rule" "this" {
  for_each                 = { for key, value in coalesce(var.security_group_rules, {}) : key => value if var.security_group_rules != {} }
  description              = each.value.description
  protocol                 = each.value.protocol
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  type                     = each.value.type
  cidr_blocks              = coalesce(each.value.cidr_blocks, [])
  source_security_group_id = each.value.security_group
  prefix_list_ids          = (each.value.prefix_list_id == null ? (coalesce(each.value.source_cloudfront_prefix_list, false) == false ? [] : [data.aws_ec2_managed_prefix_list.cloudfront.id]) : [each.value.prefix_list_id])
  security_group_id        = aws_security_group.this.id
  depends_on = [
    aws_security_group.this
  ]
}

resource "aws_security_group_rule" "new_rule_to_cluster_security_group" {
  count                    = var.security_group_rules == {} ? 0 : 1
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = var.cluster_security_group_id
  source_security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "new_rule_to_node_security_group" {
  count                    = var.security_group_rules == {} ? 0 : 1
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = var.node_security_group_id
  source_security_group_id = aws_security_group.this.id
}
