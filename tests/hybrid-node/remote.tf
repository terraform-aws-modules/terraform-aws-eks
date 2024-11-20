locals {
  remote_region = "us-east-1"
}

provider "aws" {
  alias  = "remote"
  region = local.remote_region
}

################################################################################
# Psuedo Hybrid Node
################################################################################

# Activation should be done is same region as cluster
resource "aws_ssm_activation" "this" {
  name               = "hybrid-node"
  iam_role           = module.eks_hybrid_node_role.name
  expiration_date    = "2024-12-11T00:00:00Z"
  registration_limit = 10

  tags = local.tags
}

module "key_pair" {
  source  = "terraform-aws-modules/key-pair/aws"
  version = "~> 2.0"

  providers = {
    aws = aws.remote
  }

  key_name           = "hybrid-node"
  create_private_key = true

  tags = local.tags
}

resource "local_file" "key_pem" {
  content         = module.key_pair.private_key_pem
  filename        = "key.pem"
  file_permission = "0600"
}

resource "local_file" "key_pub_pem" {
  content         = module.key_pair.public_key_pem
  filename        = "key_pub.pem"
  file_permission = "0600"
}

resource "local_file" "join" {
  content  = <<-EOT
    #!/usr/bin/env bash

    cat <<EOF > nodeConfig.yaml
    apiVersion: node.eks.aws/v1alpha1
    kind: NodeConfig
    spec:
      cluster:
        name: ${module.eks.cluster_name}
        region: ${local.region}
      hybrid:
        ssm:
          activationCode: ${aws_ssm_activation.this.activation_code}
          activationId: ${aws_ssm_activation.this.id}
    EOF

    # Use SCP/SSH to execute commands on the remote host
    scp -i ${local_file.key_pem.filename} nodeConfig.yaml ubuntu@${aws_instance.hybrid_node.public_ip}:/home/ubuntu/nodeConfig.yaml
    ssh -n -i ${local_file.key_pem.filename} ubuntu@${aws_instance.hybrid_node.public_ip} sudo nodeadm init -c file://nodeConfig.yaml
    ssh -n -i ${local_file.key_pem.filename} ubuntu@${aws_instance.hybrid_node.public_ip} sudo systemctl daemon-reload

    # Clean up
    rm nodeConfig.yaml
  EOT
  filename = "join.sh"
}

data "aws_ami" "hybrid_node" {
  provider = aws.remote

  most_recent = true
  name_regex  = "amazon-eks-ubuntu-${local.cluster_version}-amd64-*"
  owners      = ["self"]
}

resource "aws_instance" "hybrid_node" {
  provider = aws.remote

  ami                         = data.aws_ami.hybrid_node.id
  associate_public_ip_address = true
  instance_type               = "m5.large"

  # Block IMDS to make instance look less like EC2 and more like vanilla VM
  metadata_options {
    http_endpoint = "disabled"
  }

  vpc_security_group_ids = [aws_security_group.remote_node.id]
  subnet_id              = element(module.remote_node_vpc.public_subnets, 0)

  tags = merge(local.tags, {
    Name = "hybrid-node"
  })
}

################################################################################
# Psuedo Hybrid Node - Security Group
################################################################################

# Retrieve the IP of where the Terraform is running to restrict SSH access to that IP
data "http" "icanhazip" {
  url = "http://icanhazip.com"
}

resource "aws_security_group" "remote_node" {
  provider = aws.remote

  name                   = "hybrid-node"
  vpc_id                 = module.remote_node_vpc.vpc_id
  revoke_rules_on_delete = true

  tags = merge(local.tags,
    { Name = "hybrid-node" }
  )
}

resource "aws_vpc_security_group_ingress_rule" "remote_node" {
  provider = aws.remote

  for_each = {
    cluster-all = {
      description = "Allow all traffic from cluster network"
      cidr_ipv4   = module.vpc.vpc_cidr_block
      from_port   = "-1"
      ip_protocol = "all"
    }
    remote-all = {
      description                  = "Allow all traffic from within the remote network itself"
      from_port                    = "-1"
      ip_protocol                  = "all"
      referenced_security_group_id = aws_security_group.remote_node.id
    }
    ssh = {
      description = "Local SSH access to join node to cluster"
      cidr_ipv4   = "${chomp(data.http.icanhazip.response_body)}/32"
      from_port   = "22"
      ip_protocol = "tcp"
    }
  }

  cidr_ipv4                    = try(each.value.cidr_ipv4, null)
  from_port                    = try(each.value.from_port, null)
  ip_protocol                  = try(each.value.ip_protocol, null)
  to_port                      = try(each.value.to_port, each.value.from_port, null)
  referenced_security_group_id = try(each.value.referenced_security_group_id, null)
  security_group_id            = aws_security_group.remote_node.id

  tags = merge(local.tags, {
    Name = "hybrid-node-${each.key}"
  })
}

resource "aws_vpc_security_group_egress_rule" "remote_node" {
  provider = aws.remote

  for_each = {
    all = {
      description = "Allow all egress"
      cidr_ipv4   = "0.0.0.0/0"
      description = "All"
      from_port   = "-1"
      ip_protocol = "all"
      to_port     = "-1"
    }
  }

  cidr_ipv4                    = try(each.value.cidr_ipv4, null)
  from_port                    = try(each.value.from_port, null)
  ip_protocol                  = try(each.value.ip_protocol, null)
  to_port                      = try(each.value.to_port, each.value.from_port, null)
  referenced_security_group_id = try(each.value.referenced_security_group_id, null)
  security_group_id            = aws_security_group.remote_node.id

  tags = merge(local.tags, {
    Name = "hybrid-node-${each.key}"
  })
}

################################################################################
# Cilium CNI
################################################################################

resource "helm_release" "cilium" {
  name       = "cilium"
  repository = "https://helm.cilium.io/"
  chart      = "cilium"
  version    = "1.15.10"
  namespace  = "kube-system"
  wait       = false

  values = [
    <<-EOT
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                - key: eks.amazonaws.com/compute-type
                  operator: In
                  values:
                    - hybrid
      ipam:
        mode: cluster-pool
        operator:
          clusterPoolIPv4MaskSize: 26
          clusterPoolIPv4PodCIDRList:
            - ${local.remote_pod_cidr}
      operator:
        unmanagedPodWatcher:
          restart: false
    EOT
  ]
}

################################################################################
# VPC
################################################################################

locals {
  remote_network_cidr = "172.16.0.0/16"
  remote_node_cidr    = cidrsubnet(local.remote_network_cidr, 2, 0)
  remote_pod_cidr     = cidrsubnet(local.remote_network_cidr, 2, 1)

  remote_node_azs = slice(data.aws_availability_zones.remote.names, 0, 3)
}

data "aws_availability_zones" "remote" {
  provider = aws.remote

  # Exclude local zones
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

module "remote_node_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  providers = {
    aws = aws.remote
  }

  name = local.name
  cidr = local.remote_network_cidr

  azs             = local.remote_node_azs
  private_subnets = [for k, v in local.remote_node_azs : cidrsubnet(local.remote_network_cidr, 4, k)]
  public_subnets  = [for k, v in local.remote_node_azs : cidrsubnet(local.remote_network_cidr, 8, k + 48)]

  public_subnet_tags = {
    # For building the AMI
    "eks-hybrid-packer" : "true"
  }

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = local.tags
}

################################################################################
# VPC Peering Connection
################################################################################

resource "aws_vpc_peering_connection" "remote_node" {
  provider = aws.remote

  auto_accept = false

  peer_vpc_id = module.vpc.vpc_id
  peer_region = local.region

  vpc_id = module.remote_node_vpc.vpc_id

  tags = merge(local.tags, {
    Name = "remote-node"
  })
}

resource "aws_route" "remote_node_private" {
  provider = aws.remote

  route_table_id            = one(module.remote_node_vpc.private_route_table_ids)
  destination_cidr_block    = module.vpc.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.remote_node.id
}

resource "aws_route" "remote_node_public" {
  provider = aws.remote

  route_table_id            = one(module.remote_node_vpc.public_route_table_ids)
  destination_cidr_block    = module.vpc.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.remote_node.id
}