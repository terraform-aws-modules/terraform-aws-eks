locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")

  ami_name = "${var.ami_name_prefix}-${var.eks_version}-amd64-${local.timestamp}"

  tags = {
    SourceAMI    = "{{ .SourceAMI }}"
    Name         = local.ami_name
    Architecture = "amd64"
  }
}

data "amazon-parameterstore" "this" {
  name = "/aws/service/canonical/ubuntu/server-minimal/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id"
  region = var.region
}

################################################################################
# EBS Source
################################################################################

source "amazon-ebs" "this" {

  # AMI Configuration
  dynamic "ami_block_device_mappings" {
    for_each = var.ami_block_device_mappings

    content {
      delete_on_termination = try(ami_block_device_mappings.value.delete_on_termination, true)
      device_name           = try(ami_block_device_mappings.value.device_name, null)
      encrypted             = try(ami_block_device_mappings.value.encrypted, null)
      iops                  = try(ami_block_device_mappings.value.iops, null)
      no_device             = try(ami_block_device_mappings.value.no_device, null)
      snapshot_id           = try(ami_block_device_mappings.value.snapshot_id, null)
      throughput            = try(ami_block_device_mappings.value.throughput, null)
      virtual_name          = try(ami_block_device_mappings.value.virtual_name, null)
      volume_size           = try(ami_block_device_mappings.value.volume_size, 4)
      volume_type           = try(ami_block_device_mappings.value.volume_type, "gp3")
      kms_key_id            = try(ami_block_device_mappings.value.kms_key_id, null)
    }
  }

  ami_description         = var.ami_description
  ami_groups              = var.ami_groups
  ami_name                = local.ami_name
  ami_org_arns            = var.ami_org_arns
  ami_ou_arns             = var.ami_ou_arns
  ami_regions             = var.ami_regions
  ami_users               = var.ami_users
  ami_virtualization_type = var.ami_virtualization_type
  deprecate_at            = var.deprecate_at
  ena_support             = var.ena_support
  encrypt_boot            = var.encrypt_boot
  force_deregister        = var.force_deregister
  force_delete_snapshot   = var.force_delete_snapshot
  imds_support            = var.imds_support
  kms_key_id              = var.kms_key_id

  dynamic "launch_block_device_mappings" {
    for_each = length(var.launch_block_device_mappings) > 0 ? var.launch_block_device_mappings : var.ami_block_device_mappings

    content {
      delete_on_termination = try(launch_block_device_mappings.value.delete_on_termination, true)
      device_name           = try(launch_block_device_mappings.value.device_name, null)
      encrypted             = try(launch_block_device_mappings.value.encrypted, null)
      iops                  = try(launch_block_device_mappings.value.iops, null)
      no_device             = try(launch_block_device_mappings.value.no_device, null)
      snapshot_id           = try(launch_block_device_mappings.value.snapshot_id, null)
      throughput            = try(launch_block_device_mappings.value.throughput, null)
      virtual_name          = try(launch_block_device_mappings.value.virtual_name, null)
      volume_size           = try(launch_block_device_mappings.value.volume_size, 4)
      volume_type           = try(launch_block_device_mappings.value.volume_type, "gp3")
    }
  }

  region_kms_key_ids     = var.region_kms_key_ids
  run_volume_tags        = var.run_volume_tags
  skip_create_ami        = var.skip_create_ami
  skip_region_validation = var.skip_region_validation
  skip_save_build_region = var.skip_save_build_region
  sriov_support          = var.sriov_support
  snapshot_groups        = var.snapshot_groups
  snapshot_tags          = var.snapshot_tags
  snapshot_users         = var.snapshot_users
  tags                   = merge(local.tags, var.tags)

  # Access Configuration
  access_key = var.access_key

  dynamic "assume_role" {
    for_each = length(var.assume_role) > 0 ? [var.assume_role] : []

    content {
      duration_seconds    = try(assume_role.value.duration_seconds, null)
      external_id         = try(assume_role.value.external_id, null)
      policy              = try(assume_role.value.policy, null)
      policy_arns         = try(assume_role.value.policy_arns, null)
      role_arn            = try(assume_role.value.role_arn, null)
      session_name        = try(assume_role.value.session_name, null)
      tag                 = try(assume_role.value.tag, null)
      transitive_tag_keys = try(assume_role.value.transitive_tag_keys, null)
    }
  }

  dynamic "aws_polling" {
    for_each = length(var.aws_polling) > 0 ? [var.aws_polling] : []

    content {
      delay_seconds = try(aws_polling.value.delay_seconds, null)
      max_attempts  = try(aws_polling.value.max_attempts, null)
    }
  }

  custom_endpoint_ec2           = var.custom_endpoint_ec2
  decode_authorization_messages = var.decode_authorization_messages
  insecure_skip_tls_verify      = var.insecure_skip_tls_verify
  max_retries                   = var.max_retries
  mfa_code                      = var.mfa_code
  profile                       = var.profile
  region                        = var.region
  secret_key                    = var.secret_key
  shared_credentials_file       = var.shared_credentials_file
  skip_credential_validation    = var.skip_credential_validation
  skip_metadata_api_check       = var.skip_metadata_api_check
  token                         = var.token

  # Communicator
  communicator                 = var.communicator
  pause_before_connecting      = var.pause_before_connecting
  ssh_agent_auth               = var.ssh_agent_auth
  ssh_bastion_agent_auth       = var.ssh_bastion_agent_auth
  ssh_bastion_certificate_file = var.ssh_bastion_certificate_file
  ssh_bastion_host             = var.ssh_bastion_host
  ssh_bastion_interactive      = var.ssh_bastion_interactive
  ssh_bastion_password         = var.ssh_bastion_password
  ssh_bastion_port             = var.ssh_bastion_port
  ssh_bastion_private_key_file = var.ssh_bastion_private_key_file
  ssh_bastion_username         = var.ssh_bastion_username
  ssh_ciphers                  = var.ssh_ciphers
  ssh_certificate_file         = var.ssh_certificate_file
  ssh_clear_authorized_keys    = var.ssh_clear_authorized_keys
  ssh_disable_agent_forwarding = var.ssh_disable_agent_forwarding
  ssh_file_transfer_method     = var.ssh_file_transfer_method
  ssh_handshake_attempts       = var.ssh_handshake_attempts
  ssh_host                     = var.ssh_host
  ssh_interface                = var.ssh_interface # "public_dns"
  ssh_keep_alive_interval      = var.ssh_keep_alive_interval
  ssh_key_exchange_algorithms  = var.ssh_key_exchange_algorithms
  ssh_keypair_name             = var.ssh_keypair_name
  ssh_local_tunnels            = var.ssh_local_tunnels
  ssh_password                 = var.ssh_password
  ssh_port                     = var.ssh_port
  ssh_private_key_file         = var.ssh_private_key_file
  ssh_proxy_host               = var.ssh_proxy_host
  ssh_proxy_password           = var.ssh_proxy_password
  ssh_proxy_port               = var.ssh_proxy_port
  ssh_proxy_username           = var.ssh_proxy_username
  ssh_pty                      = var.ssh_pty
  ssh_read_write_timeout       = var.ssh_read_write_timeout
  ssh_remote_tunnels           = var.ssh_remote_tunnels
  ssh_timeout                  = var.ssh_timeout
  ssh_username                 = var.ssh_username
  temporary_key_pair_bits      = var.temporary_key_pair_bits
  temporary_key_pair_type      = var.temporary_key_pair_type

  # Run Configuration
  associate_public_ip_address     = var.associate_public_ip_address
  capacity_reservation_preference = var.capacity_reservation_preference
  capacity_reservation_group_arn  = var.capacity_reservation_group_arn
  capacity_reservation_id         = var.capacity_reservation_id
  disable_stop_instance           = var.disable_stop_instance
  ebs_optimized                   = var.ebs_optimized
  enable_nitro_enclave            = var.enable_nitro_enclave
  enable_unlimited_credits        = var.enable_unlimited_credits
  iam_instance_profile            = var.iam_instance_profile
  instance_type                   = var.instance_type
  fleet_tags                      = var.fleet_tags
  pause_before_ssm                = var.pause_before_ssm

  dynamic "placement" {
    for_each = length(var.placement) > 0 ? [var.placement] : []

    content {
      host_resource_group_arn = try(placement.value.host_resource_group_arn, null)
      tenancy                 = try(placement.value.tenancy, null)
    }
  }

  run_tags           = merge(local.tags, var.run_tags)
  security_group_ids = var.security_group_ids

  dynamic "security_group_filter" {
    for_each = length(var.security_group_filter) > 0 ? var.security_group_filter : []

    content {
      filters = try(security_group_filter.value.filters, null)
    }
  }

  session_manager_port    = var.session_manager_port
  shutdown_behavior       = var.shutdown_behavior
  skip_profile_validation = var.skip_profile_validation
  source_ami              = data.amazon-parameterstore.this.value

  dynamic "subnet_filter" {
    for_each = length(var.subnet_filter) > 0 ? [var.subnet_filter] : []

    content {
      filters   = try(subnet_filter.value.filters, null)
      most_free = try(subnet_filter.value.most_free, null)
      random    = try(subnet_filter.value.random, null)
    }
  }

  subnet_id = var.subnet_id

  dynamic "temporary_iam_instance_profile_policy_document" {
    for_each = length(var.temporary_iam_instance_profile_policy_document) > 0 ? [var.temporary_iam_instance_profile_policy_document] : []

    content {
      dynamic "Statement" {
        for_each = temporary_iam_instance_profile_policy_document.value

        content {
          Action   = try(Statement.value.Action, [])
          Effect   = try(Statement.value.Effect, "Allow")
          Resource = try(Statement.value.Resource, ["*"])
        }
      }
      Version = "2012-10-17"
    }
  }

  temporary_security_group_source_cidrs     = var.temporary_security_group_source_cidrs
  temporary_security_group_source_public_ip = var.temporary_security_group_source_public_ip
  user_data                                 = var.user_data
  user_data_file                            = var.user_data_file

  dynamic "vpc_filter" {
    for_each = length(var.vpc_filter) > 0 ? var.vpc_filter : []

    content {
      filters = try(vpc_filter.value.filters, null)
    }
  }

  vpc_id = var.vpc_id

  dynamic "metadata_options" {
    for_each = length(var.metadata_options) > 0 ? [var.metadata_options] : []

    content {
      http_endpoint               = try(metadata_options.value.http_endpoint, null)
      http_put_response_hop_limit = try(metadata_options.value.http_put_response_hop_limit, null)
      http_tokens                 = try(metadata_options.value.http_tokens, null)
      instance_metadata_tags      = try(metadata_options.value.instance_metadata_tags, null)
    }
  }
}

################################################################################
# Build
################################################################################

build {
  sources = ["source.amazon-ebs.this"]

  provisioner "shell" {
    execute_command = "echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"

    env = {
      DEBIAN_FRONTEND = "noninteractive"
    }

    expect_disconnect = true

    inline = [
      "cloud-init status --wait",
      "apt update",
      "apt upgrade -y",
      "apt install iptables conntrack -y",
      "systemctl reboot",
    ]

    pause_after = "15s"
  }

  provisioner "shell" {
    execute_command = "echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"

    env = {
      DEBIAN_FRONTEND = "noninteractive"
    }

    inline = [

      "snap install aws-cli --classic",
      "snap switch --channel=candidate amazon-ssm-agent",
      "curl -OL 'https://hybrid-assets.eks.amazonaws.com/releases/latest/bin/linux/amd64/nodeadm'",
      "mv nodeadm /usr/bin/nodeadm",
      "chmod +x /usr/bin/nodeadm",
      "nodeadm install ${var.eks_version} --credential-provider ${var.credential_provider}",
    ]
  }

  provisioner "shell" {
    execute_command = "echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"

    env = {
      DEBIAN_FRONTEND = "noninteractive"
    }

    inline = [
      "apt --purge autoremove -y",
      "cloud-init clean --logs --machine-id",
      "mkdir -p /etc/amazon/ssm",
      "cp $(find / -name '*seelog.xml.template') /etc/amazon/ssm/seelog.xml",
    ]
  }
}
