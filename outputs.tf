output "config_map_aws_auth" {
  description = ""
  value       = "${local.config_map_aws_auth}"
}

output "kubeconfig" {
  description = "kubectl config file contents for this cluster."
  value       = "${local.kubeconfig}"
}

output "cluster_id" {
  description = "The name/id of the cluster."
  value       = "${aws_eks_cluster.this.id}"
}

# Though documented, not yet supported
# output "cluster_arn" {
#   description = "The Amazon Resource Name (ARN) of the cluster."
#   value       = "${aws_eks_cluster.this.arn}"
# }

output "cluster_certificate_authority_data" {
  description = "Nested attribute containing certificate-authority-data for your cluster. Tis is the base64 encoded certificate data required to communicate with your cluster."
  value       = "${aws_eks_cluster.this.certificate_authority.0.data}"
}

output "cluster_endpoint" {
  description = "The endpoint for your Kubernetes API server."
  value       = "${aws_eks_cluster.this.endpoint}"
}

output "cluster_version" {
  description = "The Kubernetes server version for the cluster."
  value       = "${aws_eks_cluster.this.version}"
}

output "cluster_security_group_ids" {
  description = "description"
  value       = "${aws_eks_cluster.this.vpc_config.0.security_group_ids}"
}
