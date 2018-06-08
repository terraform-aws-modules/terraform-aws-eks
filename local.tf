locals {
  # Mapping from the node type that we selected and the max number of pods that it can run
  # Taken from https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-06-05/amazon-eks-nodegroup.yaml
  max_pod_per_node = {
    c4.large    = 29
    c4.xlarge   = 58
    c4.2xlarge  = 58
    c4.4xlarge  = 234
    c4.8xlarge  = 234
    c5.large    = 29
    c5.xlarge   = 58
    c5.2xlarge  = 58
    c5.4xlarge  = 234
    c5.9xlarge  = 234
    c5.18xlarge = 737
    i3.large    = 29
    i3.xlarge   = 58
    i3.2xlarge  = 58
    i3.4xlarge  = 234
    i3.8xlarge  = 234
    i3.16xlarge = 737
    m3.medium   = 12
    m3.large    = 29
    m3.xlarge   = 58
    m3.2xlarge  = 118
    m4.large    = 20
    m4.xlarge   = 58
    m4.2xlarge  = 58
    m4.4xlarge  = 234
    m4.10xlarge = 234
    m5.large    = 29
    m5.xlarge   = 58
    m5.2xlarge  = 58
    m5.4xlarge  = 234
    m5.12xlarge = 234
    m5.24xlarge = 737
    p2.xlarge   = 58
    p2.8xlarge  = 234
    p2.16xlarge = 234
    p3.2xlarge  = 58
    p3.8xlarge  = 234
    p3.16xlarge = 234
    r3.xlarge   = 58
    r3.2xlarge  = 58
    r3.4xlarge  = 234
    r3.8xlarge  = 234
    r4.large    = 29
    r4.xlarge   = 58
    r4.2xlarge  = 58
    r4.4xlarge  = 234
    r4.8xlarge  = 234
    r4.16xlarge = 737
    t2.small    = 8
    t2.medium   = 17
    t2.large    = 35
    t2.xlarge   = 44
    t2.2xlarge  = 44
    x1.16xlarge = 234
    x1.32xlarge = 234
  }

  asg_tags = ["${null_resource.tags_as_list_of_maps.*.triggers}"]

  # More information: https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-06-05/amazon-eks-nodegroup.yaml
  config_map_aws_auth = <<CONFIGMAPAWSAUTH
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.workers.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAPAWSAUTH

  kubeconfig = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.this.endpoint}
    certificate-authority-data: ${aws_eks_cluster.this.certificate_authority.0.data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: heptio-authenticator-aws
      args:
        - "token"
        - "-i"
        - "${var.cluster_name}"
KUBECONFIG
}
