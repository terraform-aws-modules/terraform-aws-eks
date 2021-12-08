provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

################################################################################
# Cluster Autoscaler
# Based on the official docs at
# https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler
################################################################################

resource "helm_release" "cluster_autoscaler" {
  name             = "cluster-autoscaler"
  namespace        = "kube-system"
  repository       = "https://kubernetes.github.io/autoscaler"
  chart            = "cluster-autoscaler"
  version          = "9.10.8"
  create_namespace = false

  set {
    name  = "awsRegion"
    value = local.region
  }

  set {
    name  = "rbac.serviceAccount.name"
    value = "cluster-autoscaler-aws"
  }

  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.iam_assumable_role_cluster_autoscaler.iam_role_arn
    type  = "string"
  }

  set {
    name  = "autoDiscovery.clusterName"
    value = local.name
  }

  set {
    name  = "autoDiscovery.enabled"
    value = "true"
  }

  set {
    name  = "rbac.create"
    value = "true"
  }

  depends_on = [
    module.eks.cluster_id,
    null_resource.apply,
  ]
}

module "iam_assumable_role_cluster_autoscaler" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 4.0"

  create_role      = true
  role_name_prefix = "cluster-autoscaler"
  role_description = "IRSA role for cluster autoscaler"

  provider_url                   = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns               = [aws_iam_policy.cluster_autoscaler.arn]
  oidc_fully_qualified_subjects  = ["system:serviceaccount:kube-system:cluster-autoscaler-aws"]
  oidc_fully_qualified_audiences = ["sts.amazonaws.com"]

  tags = local.tags
}

resource "aws_iam_policy" "cluster_autoscaler" {
  name   = "KarpenterControllerPolicy-refresh"
  policy = data.aws_iam_policy_document.cluster_autoscaler.json

  tags = local.tags
}

data "aws_iam_policy_document" "cluster_autoscaler" {
  statement {
    sid = "clusterAutoscalerAll"
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "ec2:DescribeLaunchTemplateVersions",
    ]
    resources = ["*"]
  }

  statement {
    sid = "clusterAutoscalerOwn"
    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup",
    ]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/${module.eks.cluster_id}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/enabled"
      values   = ["true"]
    }
  }
}

################################################################################
# Node Termination Handler
# Based on the official docs at
# https://github.com/aws/aws-node-termination-handler
################################################################################

resource "helm_release" "aws_node_termination_handler" {
  name             = "aws-node-termination-handler"
  namespace        = "kube-system"
  repository       = "https://aws.github.io/eks-charts"
  chart            = "aws-node-termination-handler"
  version          = "0.16.0"
  create_namespace = false

  set {
    name  = "awsRegion"
    value = local.region
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-node-termination-handler"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.aws_node_termination_handler_role.iam_role_arn
    type  = "string"
  }

  set {
    name  = "enableSqsTerminationDraining"
    value = "true"
  }

  set {
    name  = "enableSpotInterruptionDraining"
    value = "true"
  }

  set {
    name  = "queueURL"
    value = module.aws_node_termination_handler_sqs.sqs_queue_id
  }

  set {
    name  = "logLevel"
    value = "debug"
  }

  depends_on = [
    module.eks.cluster_id,
    null_resource.apply,
  ]
}

module "aws_node_termination_handler_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 4.0"

  create_role      = true
  role_name_prefix = "node-termination-handler"
  role_description = "IRSA role for node termination handler"

  provider_url                   = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns               = [aws_iam_policy.aws_node_termination_handler.arn]
  oidc_fully_qualified_subjects  = ["system:serviceaccount:kube-system:aws-node-termination-handler"]
  oidc_fully_qualified_audiences = ["sts.amazonaws.com"]

  tags = local.tags
}

resource "aws_iam_policy" "aws_node_termination_handler" {
  name   = "${local.name}-aws-node-termination-handler"
  policy = data.aws_iam_policy_document.aws_node_termination_handler.json

  tags = local.tags
}

data "aws_iam_policy_document" "aws_node_termination_handler" {
  statement {
    actions = [
      "ec2:DescribeInstances",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeTags",
    ]
    resources = ["*"]
  }

  statement {
    actions   = ["autoscaling:CompleteLifecycleAction"]
    resources = [for group in module.eks.self_managed_node_groups : group.autoscaling_group_arn]
  }

  statement {
    actions = [
      "sqs:DeleteMessage",
      "sqs:ReceiveMessage"
    ]
    resources = [module.aws_node_termination_handler_sqs.sqs_queue_arn]
  }
}

module "aws_node_termination_handler_sqs" {
  source  = "terraform-aws-modules/sqs/aws"
  version = "~> 3.0"

  name                      = local.name
  message_retention_seconds = 300
  policy                    = data.aws_iam_policy_document.aws_node_termination_handler_sqs.json

  tags = local.tags
}

data "aws_iam_policy_document" "aws_node_termination_handler_sqs" {
  statement {
    actions   = ["sqs:SendMessage"]
    resources = ["arn:aws:sqs:${local.region}:${data.aws_caller_identity.current.account_id}:${local.name}"]

    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
        "sqs.amazonaws.com",
      ]
    }
  }
}

resource "aws_cloudwatch_event_rule" "aws_node_termination_handler_asg" {
  name        = "${local.name}-asg-termination"
  description = "Node termination event rule"

  event_pattern = jsonencode({
    "source" : ["aws.autoscaling"],
    "detail-type" : ["EC2 Instance-terminate Lifecycle Action"]
    "resources" : [for group in module.eks.self_managed_node_groups : group.autoscaling_group_arn]
  })

  tags = local.tags
}

resource "aws_cloudwatch_event_target" "aws_node_termination_handler_asg" {
  target_id = "${local.name}-asg-termination"
  rule      = aws_cloudwatch_event_rule.aws_node_termination_handler_asg.name
  arn       = module.aws_node_termination_handler_sqs.sqs_queue_arn
}

resource "aws_cloudwatch_event_rule" "aws_node_termination_handler_spot" {
  name        = "${local.name}-spot-termination"
  description = "Node termination event rule"
  event_pattern = jsonencode({
    "source" : ["aws.ec2"],
    "detail-type" : ["EC2 Spot Instance Interruption Warning"]
    "resources" : [for group in module.eks.self_managed_node_groups : group.autoscaling_group_arn]
  })
}

resource "aws_cloudwatch_event_target" "aws_node_termination_handler_spot" {
  target_id = "${local.name}-spot-termination"
  rule      = aws_cloudwatch_event_rule.aws_node_termination_handler_spot.name
  arn       = module.aws_node_termination_handler_sqs.sqs_queue_arn
}

# Creating the lifecycle-hook outside of the ASG resource's `initial_lifecycle_hook`
# ensures that node termination does not require the lifecycle action to be completed,
# and thus allows the ASG to be destroyed cleanly.
resource "aws_autoscaling_lifecycle_hook" "aws_node_termination_handler" {
  for_each = module.eks.self_managed_node_groups

  name                   = "aws-node-termination-handler-${each.value.autoscaling_group_name}"
  autoscaling_group_name = each.value.autoscaling_group_name
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_TERMINATING"
  heartbeat_timeout      = 300
  default_result         = "CONTINUE"
}
