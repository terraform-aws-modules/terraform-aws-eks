# Network Connectivity

See [Cluster Overview](../cluster/index.md) for API server endpoint configuration. This page covers node registration troubleshooting. Refer to the [EKS documentation](https://docs.aws.amazon.com/eks/latest/userguide/cluster-endpoint.html) for detailed guidance.

## Node registration troubleshooting

Nodes failing to register with the EKS control plane is generally due to networking misconfiguration. Key things to verify:

- Cluster endpoint reachability — At least one cluster endpoint (public or private) must be enabled, and nodes must be able to reach it. If using the public endpoint with restricted CIDRs (`cluster_endpoint_public_access_cidrs`), ensure the CIDRs include the addresses nodes use to reach the endpoint. Note that when restricting public endpoint CIDRs, nodes themselves may also need to reach the public endpoint if the private endpoint is not enabled.

- Outbound internet access — When using the public endpoint, nodes need outbound internet access:
  - Nodes in private subnets: via a NAT gateway or instance with appropriate routing rules
  - Nodes in public subnets: ensure nodes are launched with public IPs

- Required AWS service connectivity — Nodes must be able to connect to AWS services to function (pull container images, make API calls to assume roles, etc.). The required services are:
  - EC2 API
  - ECR API and ECR DKR
  - S3
  - STS

- Private endpoint and VPC DNS — When the private endpoint is enabled, ensure that VPC DNS resolution and hostnames are also enabled for your VPC. EKS requires both DNS hostnames and DNS resolution to be enabled — without these, nodes cannot resolve the cluster endpoint or AWS service endpoints.

- VPC endpoints for air-gapped environments — If outbound internet access cannot be enabled for nodes, VPC endpoints for the services listed above (EC2, ECR API, ECR DKR, S3, STS) can be used instead. When the public endpoint is disabled entirely, VPC endpoints are required — nodes will be unable to pull images or register without them.

Refer to the [EKS troubleshooting documentation](https://docs.aws.amazon.com/eks/latest/userguide/troubleshooting.html) and [EKS Networking Best Practices](https://docs.aws.amazon.com/eks/latest/best-practices/networking.html) for additional help.
