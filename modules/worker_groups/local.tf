locals {
  ebs_optimized_not_supported = [
    "c1.medium",
    "c3.8xlarge",
    "c3.large",
    "c5d.12xlarge",
    "c5d.24xlarge",
    "c5d.metal",
    "cc2.8xlarge",
    "cr1.8xlarge",
    "g2.8xlarge",
    "g4dn.metal",
    "hs1.8xlarge",
    "i2.8xlarge",
    "m1.medium",
    "m1.small",
    "m2.xlarge",
    "m3.large",
    "m3.medium",
    "m5ad.16xlarge",
    "m5ad.8xlarge",
    "m5dn.metal",
    "m5n.metal",
    "r3.8xlarge",
    "r3.large",
    "r5ad.16xlarge",
    "r5ad.8xlarge",
    "r5dn.metal",
    "r5n.metal",
    "t1.micro",
    "t2.2xlarge",
    "t2.large",
    "t2.medium",
    "t2.micro",
    "t2.nano",
    "t2.small",
    "t2.xlarge"
  ]

  worker_group_configurations = {
    for k, v in var.worker_groups : k => merge(
      var.workers_group_defaults,
      v,
    ) if var.create_workers
  }

  default_platform       = "linux"
  default_ami_id_linux   = var.workers_group_defaults.ami_id != "" ? var.workers_group_defaults.ami_id : concat(data.aws_ami.eks_worker.*.id, [""])[0]
  default_ami_id_windows = var.workers_group_defaults.ami_id_windows != "" ? var.workers_group_defaults.ami_id_windows : concat(data.aws_ami.eks_worker_windows.*.id, [""])[0]

  default_root_block_device_name         = concat(data.aws_ami.eks_worker.*.root_device_name, [""])[0]
  default_root_block_device_name_windows = concat(data.aws_ami.eks_worker_windows.*.root_device_name, [""])[0]

  worker_has_linux_ami   = length([for k, v in local.worker_group_configurations : k if v["platform"] == "linux"]) > 0
  worker_has_windows_ami = length([for k, v in local.worker_group_configurations : k if v["platform"] == "windows"]) > 0

  worker_ami_name_filter = var.worker_ami_name_filter != "" ? var.worker_ami_name_filter : "amazon-eks-node-${var.cluster_version}-v*"
  # Windows nodes are available from k8s 1.14. If cluster version is less than 1.14, fix ami filter to some constant to not fail on 'terraform plan'.
  worker_ami_name_filter_windows = (var.worker_ami_name_filter_windows != "" ?
    var.worker_ami_name_filter_windows : "Windows_Server-2019-English-Core-EKS_Optimized-${tonumber(var.cluster_version) >= 1.14 ? var.cluster_version : 1.14}-*"
  )

  userdata_rendered = {
    for k, v in local.worker_group_configurations : k => templatefile(
      lookup(
        var.worker_groups[k],
        "userdata_template_file",
        v["platform"] == "windows" ?
        "${path.module}/templates/userdata_windows.tpl" :
        "${path.module}/templates/userdata.sh.tpl"
      ),
      merge(
        {
          cluster_name        = var.cluster_name
          endpoint            = var.cluster_endpoint
          cluster_auth_base64 = var.cluster_auth_base64

          platform             = v["platform"]
          pre_userdata         = v["pre_userdata"]
          additional_userdata  = v["additional_userdata"]
          bootstrap_extra_args = v["bootstrap_extra_args"]
          kubelet_extra_args   = v["kubelet_extra_args"]
        },
        v["userdata_template_extra_args"]
      )
    )
  }
}
