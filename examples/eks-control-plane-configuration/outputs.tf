output "api_server_kube_api_server_config" {
  description = "The Kubernetes API server configuration"
  value       = module.eks_api_server.cluster_kube_api_server_config
}

output "hpa_kube_controller_manager_config" {
  description = "The Kubernetes controller manager configuration"
  value       = module.eks_hpa_sync.cluster_kube_controller_manager_config
}

output "combined_kube_api_server_config" {
  description = "The Kubernetes API server configuration for the combined cluster"
  value       = module.eks_combined.cluster_kube_api_server_config
}

output "combined_kube_controller_manager_config" {
  description = "The Kubernetes controller manager configuration for the combined cluster"
  value       = module.eks_combined.cluster_kube_controller_manager_config
}
