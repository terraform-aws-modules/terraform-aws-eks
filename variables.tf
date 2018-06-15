variable "cluster_name" {
  description = "Name of the EKS cluster. Also used as a prefix in names of related resources."
}

variable "cluster_security_group_id" {
  description = "If provided, the EKS cluster will be attached to this security group. If not given, a security group will be created with necessary ingres/egress to work with the workers and provide API access to your current IP/32."
  default     = ""
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster."
  default     = "1.10"
}

variable "config_output_path" {
  description = "Determines where config files are placed if using configure_kubectl_session and you want config files to land outside the current working directory."
  default     = "./"
}

variable "configure_kubectl_session" {
  description = "Configure the current session's kubectl to use the instantiated EKS cluster."
  default     = true
}

variable "subnets" {
  description = "A list of subnets to place the EKS cluster and workers within."
  type        = "list"
}

variable "tags" {
  description = "A map of tags to add to all resources."
  default     = {}
}

variable "vpc_id" {
  description = "VPC where the cluster and workers will be deployed."
}

variable "worker_groups" {
  description = "A list of maps defining worker group configurations. See workers_group_defaults for valid keys."
  type        = "list"

  default = [{
    "name" = "default"
  }]
}

variable "workers_group_defaults" {
  description = "Default values for target groups as defined by the list of maps."
  type        = "map"

  default = {
    name                 = "count.index" # Name of the worker group. Literal count.index will never be used but if name is not set, the count.index interpolation will be used.
    ami_id               = ""            # AMI ID for the eks workers. If none is provided, Terraform will search for the latest version of their EKS optimized worker AMI.
    asg_desired_capacity = "1"           # Desired worker capacity in the autoscaling group.
    asg_max_size         = "3"           # Maximum worker capacity in the autoscaling group.
    asg_min_size         = "1"           # Minimum worker capacity in the autoscaling group.
    instance_type        = "m4.large"    # Size of the workers instances.
    additional_userdata  = ""            # userdata to append to the default userdata.
    ebs_optimized        = true          # sets whether to use ebs optimization on supported types.
    public_ip            = false         # Associate a public ip address with a worker
  }
}

variable "worker_security_group_id" {
  description = "If provided, all workers will be attached to this security group. If not given, a security group will be created with necessary ingres/egress to work with the EKS cluster."
  default     = ""
}
