output "cluster_id" {
  description = "The name/id of the EKS cluster."
  value       = "${aws_eks_cluster.this.id}"
}

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster."
  value       = "${aws_eks_cluster.this.arn}"
}

output "cluster_certificate_authority_data" {
  description = "Nested attribute containing certificate-authority-data for your cluster. This is the base64 encoded certificate data required to communicate with your cluster."
  value       = "${aws_eks_cluster.this.certificate_authority.0.data}"
}

output "cluster_endpoint" {
  description = "The endpoint for your EKS Kubernetes API."
  value       = "${aws_eks_cluster.this.endpoint}"
}

output "cluster_version" {
  description = "The Kubernetes server version for the EKS cluster."
  value       = "${aws_eks_cluster.this.version}"
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster."
  value       = "${local.cluster_security_group_id}"
}

output "config_map_aws_auth" {
  description = "A kubernetes configuration to authenticate to this EKS cluster."
  value       = "${data.template_file.config_map_aws_auth.rendered}"
}

output "cluster_iam_role_name" {
  description = "IAM role name of the EKS cluster."
  value       = "${local.cluster_iam_role_name}"
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster."
  value       = "${local.cluster_iam_role_arn}"
}

output "kubeconfig" {
  description = "kubectl config file contents for this EKS cluster."
  value       = "${data.template_file.kubeconfig.rendered}"
}

output "kubeconfig_filename" {
  description = "The filename of the generated kubectl config."
  value       = "${element(concat(local_file.kubeconfig.*.filename, list("")), 0)}"
}

output "workers_asg_arns" {
  description = "IDs of the autoscaling groups containing workers."
  value       = "${concat(aws_autoscaling_group.workers.*.arn, aws_autoscaling_group.workers_launch_template.*.arn, aws_autoscaling_group.workers_launch_template_mixed.*.arn)}"
}

output "workers_asg_names" {
  description = "Names of the autoscaling groups containing workers."
  value       = "${concat(aws_autoscaling_group.workers.*.id, aws_autoscaling_group.workers_launch_template.*.id, aws_autoscaling_group.workers_launch_template_mixed.*.id)}"
}

output "workers_user_data" {
  description = "User data of worker groups"
  value       = "${concat(data.template_file.userdata.*.rendered, data.template_file.launch_template_userdata.*.rendered)}"
}

output "workers_default_ami_id" {
  description = "ID of the default worker group AMI"
  value       = "${data.aws_ami.eks_worker.id}"
}

output "workers_launch_template_ids" {
  description = "IDs of the worker launch templates."
  value       = "${aws_launch_template.workers_launch_template.*.id}"
}

output "workers_launch_template_arns" {
  description = "ARNs of the worker launch templates."
  value       = "${aws_launch_template.workers_launch_template.*.arn}"
}

output "workers_launch_template_latest_versions" {
  description = "Latest versions of the worker launch templates."
  value       = "${aws_launch_template.workers_launch_template.*.latest_version}"
}

output "worker_security_group_id" {
  description = "Security group ID attached to the EKS workers."
  value       = "${local.worker_security_group_id}"
}

output "worker_iam_instance_profile_arns" {
  description = "default IAM instance profile ARN for EKS worker groups"
  value       = "${aws_iam_instance_profile.workers.*.arn}"
}

output "worker_iam_instance_profile_names" {
  description = "default IAM instance profile name for EKS worker groups"
  value       = "${aws_iam_instance_profile.workers.*.name}"
}

output "worker_iam_role_name" {
  description = "default IAM role name for EKS worker groups"
  value       = "${element(coalescelist(aws_iam_role.workers.*.name, data.aws_iam_instance_profile.custom_worker_group_iam_instance_profile.*.role_name, data.aws_iam_instance_profile.custom_worker_group_launch_template_iam_instance_profile.*.role_name, data.aws_iam_instance_profile.custom_worker_group_launch_template_mixed_iam_instance_profile.*.role_name), 0)}"
}

output "worker_iam_role_arn" {
  description = "default IAM role ARN for EKS worker groups"
  value       = "${element(coalescelist(aws_iam_role.workers.*.arn, data.aws_iam_instance_profile.custom_worker_group_iam_instance_profile.*.role_arn, data.aws_iam_instance_profile.custom_worker_group_launch_template_iam_instance_profile.*.role_arn, data.aws_iam_instance_profile.custom_worker_group_launch_template_mixed_iam_instance_profile.*.role_arn), 0)}"
}
