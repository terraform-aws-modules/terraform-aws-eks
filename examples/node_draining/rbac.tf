resource "kubernetes_cluster_role" "node_drainer" {
  metadata {
    name = "node-drainer"
  }
  rule {
    api_groups = [""]
    resources = ["pods", "pods/eviction", "nodes"]
    verbs = ["create", "list", "patch"]
  }
  depends_on = [
    module.eks.kubeconfig
  ]
}

resource "kubernetes_cluster_role_binding" "node_drainer" {
  metadata {
    name = "node-drainer"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = kubernetes_cluster_role.node_drainer.metadata[0].name
  }
  subject {
    kind = "User"
    name = "lambda"
    api_group = "rbac.authorization.k8s.io"
  }
  depends_on = [
    module.eks.kubeconfig
  ]
}
