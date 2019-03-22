# CNI Custom Networking

[CNI Custom Networking](https://docs.aws.amazon.com/eks/latest/userguide/cni-custom-network.html) can be enabled by passing in a CIDR in the `cni_cidr_block` variable.


## What it does

Attaches the provided `cni_cidr_block` to the VPC.

Creates one subnet per discovered VPC availability zone. They will be as large as possible (depends on the CIDR block size and how many availability zones are discovered). Example for an Amazon region with 3 AZs and the provided `cni_cidr_block="100.65.0.0/16"`:

- `100.65.0.0/8`
- `100.65.64.0/18`
- `100.65.128.0/18`

Creates [ENIConfig](../templates/config-map-eni-config-part.yaml.tpl) resources for each of the discovered Availability Zones in the current Amazon region:

```yaml
# Definition of ENIConfig for zone: eu-west-1a
---
apiVersion: crd.k8s.amazonaws.com/v1alpha1
kind: ENIConfig
metadata:
  name: eu-west-1a
spec:
  subnet: subnet-abc123
  securityGroups:
  - sg-workersecuritygroup
---
# Definition of ENIConfig for zone: eu-west-1b
# ...

```

[Patches](../templates/patch-vpc_cni_custom_network.yaml) the `aws-node` deployment to use a custom container image and include environment variables to make nodes choose its correct `ENIConfig`:

- `AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG="true"`
- `ENI_CONFIG_LABEL_DEF="failure-domain.beta.kubernetes.io/zone"`


