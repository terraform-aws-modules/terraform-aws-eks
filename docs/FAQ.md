# Frequently Asked Questions

- Setting `instance_refresh_enabled = true` will recreate your worker nodes without draining them first. It is recommended to install [aws-node-termination-handler](https://github.com/aws/aws-node-termination-handler) for proper node draining. See the [instance_refresh](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/irsa_autoscale_refresh) example provided.

<h4>Why are nodes not being registered?</h4>

Often an issue caused by one of two reasons:
1. Networking or endpoint mis-configuration.
2. Permissions (IAM/RBAC)

At least one of the cluster public or private endpoints must be enabled to access the cluster to work. If you require a public endpoint, setting up both (public and private) and restricting the public endpoint via setting `cluster_endpoint_public_access_cidrs` is recommended. More info regarding communication with an endpoint is available [here](https://docs.aws.amazon.com/eks/latest/userguide/cluster-endpoint.html).

Nodes need to be able to contact the EKS cluster endpoint. By default, the module only creates a public endpoint. To access the endpoint, the nodes need outgoing internet access:

- Nodes in private subnets: via a NAT gateway or instance along with the appropriate routing rules
- Nodes in public subnets: ensure that nodes are launched with public IPs is enabled (either through the module here or your subnet setting defaults)

<strong>Important: If you apply only the public endpoint and configure the `cluster_endpoint_public_access_cidrs` to restrict access, know that EKS nodes will also use the public endpoint and you must allow access to the endpoint. If not, then your nodes will fail to work correctly.</strong>

Cluster private endpoint can also be enabled by setting `cluster_endpoint_private_access = true` on this module. Node communication to the endpoint stays within the VPC. Ensure that VPC DNS resolution and hostnames are also enabled for your VPC when the private endpoint is enabled.

Nodes need to be able to connect to other AWS services plus pull down container images from container registries (ECR). If for some reason you cannot enable public internet access for nodes you can add VPC endpoints to the relevant services: EC2 API, ECR API, ECR DKR and S3.

<h4>How can I work with the cluster if I disable the public endpoint?</h4>

You have to interact with the cluster from within the VPC that it is associated with; either through a VPN connection, a bastion EC2 instance, etc.

<h4>How can I stop Terraform from removing the EKS tags from my VPC and subnets?</h4>

You need to add the tags to the Terraform definition of the VPC and subnets yourself. See the [basic example](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/basic).

An alternative is to use the aws provider's [`ignore_tags` variable](https://www.terraform.io/docs/providers/aws/#ignore_tags-configuration-block). However this can also cause terraform to display a perpetual difference.

<h4>Why are there no changes when a node group's desired count is modified?</h4>

The module is configured to ignore this value. Unfortunately, Terraform does not support variables within the `lifecycle` block. The setting is ignored to allow the cluster autoscaler to work correctly so that `terraform apply` does not accidentally remove running workers. You can change the desired count via the CLI or console if you're not using the cluster autoscaler.

If you are not using autoscaling and want to control the number of nodes via terraform, set the `min_size` and `max_size` for node groups. Before changing those values, you must satisfy AWS `desired_size` constraints (which must be between new min/max values).

<h4>Why are nodes not recreated when the `launch_template` is recreated?</h4>

By default the ASG for a self-managed node group is not configured to be recreated when the launch configuration or template changes; you will need to use a process to drain and cycle the nodes.

If you are NOT using the cluster autoscaler:

- Add a new instance
- Drain an old node `kubectl drain --force --ignore-daemonsets --delete-local-data ip-xxxxxxx.eu-west-1.compute.internal`
- Wait for pods to be Running
- Terminate the old node instance. ASG will start a new instance
- Repeat the drain and delete process until all old nodes are replaced

If you are using the cluster autoscaler:

- Drain an old node `kubectl drain --force --ignore-daemonsets --delete-local-data ip-xxxxxxx.eu-west-1.compute.internal`
- Wait for pods to be Running
- Cluster autoscaler will create new nodes when required
- Repeat until all old nodes are drained
- Cluster autoscaler will terminate the old nodes after 10-60 minutes automatically

You can also use a third-party tool like Gruntwork's kubergrunt. See the [`eks deploy`](https://github.com/gruntwork-io/kubergrunt#deploy) subcommand.

Alternatively, use a managed node group instead.
<h4>How can I use Windows workers?</h4>

To enable Windows support for your EKS cluster, you should apply some configuration manually. See the [Enabling Windows Support (Windows/MacOS/Linux)](https://docs.aws.amazon.com/eks/latest/userguide/windows-support.html#enable-windows-support).

Windows based nodes require an additional cluster role (`eks:kube-proxy-windows`).

<h4>Worker nodes with labels do not join a 1.16+ cluster</h4>

As of Kubernetes 1.16, kubelet restricts which labels with names in the `kubernetes.io` namespace can be applied to nodes. Labels such as `kubernetes.io/lifecycle=spot` are no longer allowed; instead use `node.kubernetes.io/lifecycle=spot`

See your Kubernetes version's documentation for  the `--node-labels` kubelet flag for the allowed prefixes. [Documentation for 1.16](https://v1-16.docs.kubernetes.io/docs/reference/command-line-tools-reference/kubelet/)
