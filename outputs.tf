output "config_map_aws_auth" {
  description = "description"
  value       = "${local.config_map_aws_auth}"
}

output "kubeconfig" {
  description = "description"
  value       = "${local.kubeconfig}"
}

output "cluster_id" {
  description = "The name of the cluster."
  value       = "${aws_eks_cluster.demo.id}"
}

# Though documented: not yet supported
# output "cluster_arn" {
#   description = "The Amazon Resource Name (ARN) of the cluster."
#   value       = "${aws_eks_cluster.demo.arn}"
# }

output "cluster_certificate_authority_data" {
  description = "Nested attribute containing certificate-authority-data for your cluster. Tis is the base64 encoded certificate data required to communicate with your cluster."
  value       = "${aws_eks_cluster.demo.certificate_authority.0.data}"
}

output "cluster_endpoint" {
  description = "The endpoint for your Kubernetes API server."
  value       = "${aws_eks_cluster.demo.endpoint}"
}

output "cluster_version" {
  description = "The Kubernetes server version for the cluster."
  value       = "${aws_eks_cluster.demo.version}"
}

output "cluster_vpc_config" {
  description = "description"
  value       = "${aws_eks_cluster.demo.vpc_config}"
}
