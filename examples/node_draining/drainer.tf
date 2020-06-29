data "archive_file" "node_drainer" {
  count = var.drainer_enabled ? 1 : 0
  type          = "zip"
  source_dir = "${path.module}/drainer/dist"
  output_path   = "${path.module}/lambda_function.zip"
}

resource "aws_iam_role" "node_drainer" {
  count = var.drainer_enabled ? 1 : 0
  name = "NodeDrainerRole"
  assume_role_policy = data.aws_iam_policy_document.node_drainer_assume_role[0].json
}

data "aws_iam_policy_document" "node_drainer_assume_role" {
  count = var.drainer_enabled ? 1 : 0
  statement {
    sid = "AssumeRolePolicy"
    effect    = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "node_drainer" {
  count = var.drainer_enabled ? 1 : 0
  statement {
    sid = "LoggingPolicy"
    effect    = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }
  statement {
    sid = "AutoscalePolicy"
    effect    = "Allow"
    actions = [
      "autoscaling:CompleteLifecycleAction",
      "ec2:DescribeInstances",
      "eks:DescribeCluster",
      "sts:GetCallerIdentity",
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role_policy" "node_drainer" {
  count = var.drainer_enabled ? 1 : 0
  role = aws_iam_role.node_drainer[0].id
  policy = data.aws_iam_policy_document.node_drainer[0].json
}

resource "aws_lambda_function" "node_drainer" {
  count = var.drainer_enabled ? 1 : 0
  filename      = data.archive_file.node_drainer[0].output_path
  function_name = var.drainer_lambda_function_name
  role          = aws_iam_role.node_drainer[0].arn
  handler       = "handler.lambda_handler"
  memory_size = 300
  timeout = var.drainer_lambda_timeout

  source_code_hash = filebase64sha256(data.archive_file.node_drainer[0].output_path)

  runtime = "python3.7"

  environment {
    variables = {
      CLUSTER_NAME = var.cluster_name
    }
  }
  depends_on = [
    aws_iam_role.node_drainer,
    aws_cloudwatch_log_group.node_drainer,
    data.archive_file.node_drainer,
  ]
}

# This is to optionally manage the CloudWatch Log Group for the Lambda Function.
# If skipping this resource configuration, also add "logs:CreateLogGroup" to the IAM policy below.
resource "aws_cloudwatch_log_group" "node_drainer" {
  count = var.drainer_enabled ? 1 : 0
  name              = "/aws/lambda/${var.drainer_lambda_function_name}"
  retention_in_days = 14
}

resource "aws_lambda_permission" "node_drainer" {
  count = var.drainer_enabled ? 1 : 0
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.node_drainer[0].function_name
  principal = "events.amazonaws.com"
}

resource "aws_cloudwatch_event_rule" "terminating_events" {
  count = var.drainer_enabled ? 1 : 0
  name = "asg-terminate-events-${var.cluster_name}"
  description = "Capture all terminating autoscaling events for cluster ${var.cluster_name}"

  event_pattern = templatefile("${path.module}/event-rule.tpl", { cluster_name = var.cluster_name })
}

resource "aws_cloudwatch_event_target" "terminating_events" {
  count = var.drainer_enabled ? 1 : 0
  rule = aws_cloudwatch_event_rule.terminating_events[0].name
  arn = aws_lambda_function.node_drainer[0].arn
}
