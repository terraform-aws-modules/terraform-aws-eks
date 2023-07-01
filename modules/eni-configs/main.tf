###############################################################################
# ENI Config Generator
###############################################################################
## Generates the vpc-cni eniconfigs automatically
resource "kubernetes_manifest" "eniconfig" {
  for_each = {
    for subnet in data.aws_subnet.subnet_eniconfig : subnet.id => subnet
  }
  manifest = {
    "apiVersion" = "crd.k8s.amazonaws.com/v1alpha1"
    "kind"       = "ENIConfig"
    "metadata" = {
      "name" = each.value.availability_zone
    }
    "spec" = {
      "subnet" = each.value.id
    }
  }
}
