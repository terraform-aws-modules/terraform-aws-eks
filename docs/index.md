# Terraform AWS EKS

Terraform module for creating and managing Amazon EKS (Kubernetes) clusters on AWS.

## What this module does

Amazon EKS (Elastic Kubernetes Service) runs Kubernetes on AWS. An EKS cluster has two parts: a control plane (the Kubernetes API server, managed by AWS) and a data plane (the EC2 instances or Fargate tasks that run your application containers). This module provisions both, along with the networking, security, IAM roles, and operational add-ons that connect them. It supports multiple ways to run the data plane — from fully AWS-managed ([Auto Mode](cluster/auto-mode.md)) to fully self-managed ([Self-Managed Node Groups](compute/self-managed-node-groups.md)).

External resources: [GitHub](https://github.com/terraform-aws-modules/terraform-aws-eks) · [Terraform Registry](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest) · [AWS EKS Documentation](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html) · [EKS Best Practices Guide](https://docs.aws.amazon.com/eks/latest/best-practices/introduction.html)

## Getting started

The simplest way to create an EKS cluster is with [Auto Mode](cluster/auto-mode.md), which lets AWS manage compute, networking, storage, and other cluster infrastructure. See the [Getting Started](getting-started.md) guide for a walkthrough.
