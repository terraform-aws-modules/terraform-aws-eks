provider "aws" {
  region = var.region
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
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

data "aws_availability_zones" "available" {
}

locals {
  cluster_name = "test-refresh-${random_string.suffix.result}"
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

data "aws_iam_policy_document" "node_term" {
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
      module.node_term_sqs.sqs_queue_arn
    ]
  }
}

resource "aws_iam_policy" "node_term" {
  name   = "node-term-${local.cluster_name}"
  policy = data.aws_iam_policy_document.node_term.json
}

resource "aws_iam_role_policy_attachment" "node_term_policy" {
  policy_arn = aws_iam_policy.node_term.arn
  role       = module.eks.worker_iam_role_name
}

data "aws_iam_policy_document" "node_term_events" {
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
      "arn:aws:sqs:${var.region}:${data.aws_caller_identity.current.account_id}:${local.cluster_name}",
    ]
  }
}

module "node_term_sqs" {
  source                    = "terraform-aws-modules/sqs/aws"
  version                   = "~> 3.0.0"
  name                      = local.cluster_name
  message_retention_seconds = 300
  policy                    = data.aws_iam_policy_document.node_term_events.json
}

resource "aws_cloudwatch_event_rule" "node_term_event_rule" {
  name        = "${local.cluster_name}-nth-rule"
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

resource "aws_cloudwatch_event_target" "node_term_event_target" {
  rule      = aws_cloudwatch_event_rule.node_term_event_rule.name
  target_id = "ANTHandler"
  arn       = module.node_term_sqs.sqs_queue_arn
}

module "node_term_role" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "4.1.0"
  create_role                   = true
  role_description              = "IRSA role for ANTH, cluster ${local.cluster_name}"
  role_name_prefix              = local.cluster_name
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.node_term.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.namespace}:${var.serviceaccount}"]
}

resource "helm_release" "anth" {
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
    value = var.region
  }
  set {
    name  = "serviceAccount.name"
    value = var.serviceaccount
  }
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.node_term_role.iam_role_arn
    type  = "string"
  }
  set {
    name  = "enableSqsTerminationDraining"
    value = "true"
  }
  set {
    name  = "queueURL"
    value = module.node_term_sqs.sqs_queue_id
  }
  set {
    name  = "logLevel"
    value = "DEBUG"
  }
}

# Creating the lifecycle-hook outside of the ASG resource's `initial_lifecycle_hook`
# ensures that node termination does not require the lifecycle action to be completed,
# and thus allows the ASG to be destroyed cleanly.
resource "aws_autoscaling_lifecycle_hook" "node_term" {
  name                   = "node_term-${local.cluster_name}"
  autoscaling_group_name = module.eks.workers_asg_names[0]
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_TERMINATING"
  heartbeat_timeout      = 300
  default_result         = "CONTINUE"
}

module "eks" {
  source          = "../.."
  cluster_name    = local.cluster_name
  cluster_version = "1.19"
  subnets         = module.vpc.public_subnets
  vpc_id          = module.vpc.vpc_id
  enable_irsa     = true
  worker_groups_launch_template = [
    {
      name                                 = "refresh"
      asg_max_size                         = 2
      asg_desired_capacity                 = 2
      instance_refresh_enabled             = true
      instance_refresh_triggers            = ["tag"]
      public_ip                            = true
      metadata_http_put_response_hop_limit = 3
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
        },
      ]
    },
  ]
}
