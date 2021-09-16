# Based on the official aws-node-termination-handler setup guide at https://github.com/aws/aws-node-termination-handler#infrastructure-setup

provider "aws" {
  region = local.region
}

data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

data "aws_availability_zones" "available" {
}

locals {
  cluster_name = "test-refresh-${random_string.suffix.result}"
  region       = "eu-west-1"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0.0"

  name                 = local.cluster_name
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_dns_hostnames = true
}

data "aws_iam_policy_document" "aws_node_termination_handler" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeTags",
    ]
    resources = [
      "*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "autoscaling:CompleteLifecycleAction",
    ]
    resources = module.eks.workers_asg_arns
  }
  statement {
    effect = "Allow"
    actions = [
      "sqs:DeleteMessage",
      "sqs:ReceiveMessage"
    ]
    resources = [
      module.aws_node_termination_handler_sqs.sqs_queue_arn
    ]
  }
}

resource "aws_iam_policy" "aws_node_termination_handler" {
  name   = "${local.cluster_name}-aws-node-termination-handler"
  policy = data.aws_iam_policy_document.aws_node_termination_handler.json
}

data "aws_iam_policy_document" "aws_node_termination_handler_events" {
  statement {
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
        "sqs.amazonaws.com",
      ]
    }
    actions = [
      "sqs:SendMessage",
    ]
    resources = [
      "arn:aws:sqs:${local.region}:${data.aws_caller_identity.current.account_id}:${local.cluster_name}",
    ]
  }
}

module "aws_node_termination_handler_sqs" {
  source                    = "terraform-aws-modules/sqs/aws"
  version                   = "~> 3.0.0"
  name                      = local.cluster_name
  message_retention_seconds = 300
  policy                    = data.aws_iam_policy_document.aws_node_termination_handler_events.json
}

resource "aws_cloudwatch_event_rule" "aws_node_termination_handler_asg" {
  name        = "${local.cluster_name}-asg-termination"
  description = "Node termination event rule"
  event_pattern = jsonencode(
    {
      "source" : [
        "aws.autoscaling"
      ],
      "detail-type" : [
        "EC2 Instance-terminate Lifecycle Action"
      ]
      "resources" : module.eks.workers_asg_arns
    }
  )
}

resource "aws_cloudwatch_event_target" "aws_node_termination_handler_asg" {
  target_id = "${local.cluster_name}-asg-termination"
  rule      = aws_cloudwatch_event_rule.aws_node_termination_handler_asg.name
  arn       = module.aws_node_termination_handler_sqs.sqs_queue_arn
}

resource "aws_cloudwatch_event_rule" "aws_node_termination_handler_spot" {
  name        = "${local.cluster_name}-spot-termination"
  description = "Node termination event rule"
  event_pattern = jsonencode(
    {
      "source" : [
        "aws.ec2"
      ],
      "detail-type" : [
        "EC2 Spot Instance Interruption Warning"
      ]
      "resources" : module.eks.workers_asg_arns
    }
  )
}

resource "aws_cloudwatch_event_target" "aws_node_termination_handler_spot" {
  target_id = "${local.cluster_name}-spot-termination"
  rule      = aws_cloudwatch_event_rule.aws_node_termination_handler_spot.name
  arn       = module.aws_node_termination_handler_sqs.sqs_queue_arn
}

module "aws_node_termination_handler_role" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "4.1.0"
  create_role                   = true
  role_description              = "IRSA role for ANTH, cluster ${local.cluster_name}"
  role_name_prefix              = local.cluster_name
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.aws_node_termination_handler.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.namespace}:${var.serviceaccount}"]
}

resource "helm_release" "aws_node_termination_handler" {
  depends_on = [
    module.eks
  ]

  name             = "aws-node-termination-handler"
  namespace        = var.namespace
  repository       = "https://aws.github.io/eks-charts"
  chart            = "aws-node-termination-handler"
  version          = var.aws_node_termination_handler_chart_version
  create_namespace = true

  set {
    name  = "awsRegion"
    value = local.region
  }
  set {
    name  = "serviceAccount.name"
    value = var.serviceaccount
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
}

# Creating the lifecycle-hook outside of the ASG resource's `initial_lifecycle_hook`
# ensures that node termination does not require the lifecycle action to be completed,
# and thus allows the ASG to be destroyed cleanly.
resource "aws_autoscaling_lifecycle_hook" "aws_node_termination_handler" {
  count                  = length(module.eks.workers_asg_names)
  name                   = "aws-node-termination-handler"
  autoscaling_group_name = module.eks.workers_asg_names[count.index]
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_TERMINATING"
  heartbeat_timeout      = 300
  default_result         = "CONTINUE"
}

module "eks" {
  source          = "../.."
  cluster_name    = local.cluster_name
  cluster_version = "1.20"
  subnets         = module.vpc.public_subnets
  vpc_id          = module.vpc.vpc_id
  enable_irsa     = true
  worker_groups_launch_template = [
    {
      name                                 = "refresh"
      asg_max_size                         = 2
      asg_desired_capacity                 = 2
      instance_refresh_enabled             = true
      instance_refresh_instance_warmup     = 60
      public_ip                            = true
      metadata_http_put_response_hop_limit = 3
      update_default_version               = true
      instance_refresh_triggers            = ["tag"]
      tags = [
        {
          key                 = "aws-node-termination-handler/managed"
          value               = ""
          propagate_at_launch = true
        },
        {
          key                 = "foo"
          value               = "buzz"
          propagate_at_launch = true
        }
      ]
    }
  ]
}
