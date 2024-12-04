variable "ami_name_prefix" {
  description = "The prefix to use when creating the AMI name. i.e. - `<ami_name_prefix>-<eks_version>-<architecture>-<timestamp>"
  type        = string
  default     = "eks-hybrid-ubuntu"
}

variable "eks_version" {
  description = "The EKS cluster version associated with the AMI created"
  type        = string
  default     = "1.31"
}

variable "credential_provider" {
  description = "The credential provider to use with the Hybrid Node role"
  type        = string
  default     = "ssm"
}

variable "cpu_architecture" {
  description = "The CPU architecture. Either `amd64` or `arm64`"
  type        = string
  default     = "amd64"
}

################################################################################
# EBS Source
################################################################################

variable "ami_block_device_mappings" {
  description = "The block device mappings attached when booting a new instance from the AMI created"
  type        = list(map(string))
  default = [
    {
      device_name           = "/dev/sda1"
      volume_size           = 24
      volume_type           = "gp3"
      delete_on_termination = true
    },
  ]
}

variable "ami_description" {
  description = "The description to use when creating the AMI"
  type        = string
  default     = "EKS Hybrid Node demonstration AMI"
}

variable "ami_groups" {
  description = "A list of groups that have access to launch the resulting AMI(s). By default no groups have permission to launch the AMI. `all` will make the AMI publicly accessible. AWS currently doesn't accept any value other than `all`"
  type        = list(string)
  default     = null
}

variable "ami_org_arns" {
  description = "A list of Amazon Resource Names (ARN) of AWS Organizations that have access to launch the resulting AMI(s). By default no organizations have permission to launch the AMI"
  type        = list(string)
  default     = null
}

variable "ami_ou_arns" {
  description = "A list of Amazon Resource Names (ARN) of AWS Organizations organizational units (OU) that have access to launch the resulting AMI(s). By default no organizational units have permission to launch the AMI"
  type        = list(string)
  default     = null
}

variable "ami_regions" {
  description = "A list of regions to copy the AMI to. Tags and attributes are copied along with the AMI. AMI copying takes time depending on the size of the AMI, but will generally take many minutes"
  type        = list(string)
  default     = null
}

variable "ami_users" {
  description = "A list of account IDs that have access to launch the resulting AMI(s). By default no additional users other than the user creating the AMI has permissions to launch it"
  type        = list(string)
  default     = null
}

variable "ami_virtualization_type" {
  description = "The type of virtualization used to create the AMI. Can be one of `hvm` or `paravirtual`"
  type        = string
  default     = "hvm"
}

variable "deprecate_at" {
  description = "The date and time to deprecate the AMI, in UTC, in the following format: YYYY-MM-DDTHH:MM:SSZ. If you specify a value for seconds, Amazon EC2 rounds the seconds to the nearest minute"
  type        = string
  default     = null
}

variable "ena_support" {
  description = "Enable enhanced networking (ENA but not SriovNetSupport) on HVM-compatible AMIs"
  type        = bool
  default     = null
}

variable "encrypt_boot" {
  description = "Whether or not to encrypt the resulting AMI when copying a provisioned instance to an AMI. By default, Packer will keep the encryption setting to what it was in the source image"
  type        = bool
  default     = null
}

variable "force_deregister" {
  description = "Force Packer to first deregister an existing AMI if one with the same name already exists. Default `false`"
  type        = bool
  default     = null
}

variable "force_delete_snapshot" {
  description = "Force Packer to delete snapshots associated with AMIs, which have been deregistered by force_deregister. Default `false`"
  type        = bool
  default     = null
}

variable "imds_support" {
  description = "Enforce version of the Instance Metadata Service on the built AMI. Valid options are `unset` (legacy) and `v2.0`"
  type        = string
  default     = "v2.0"
}

variable "kms_key_id" {
  description = "ID, alias or ARN of the KMS key to use for AMI encryption. This only applies to the main `region` -- any regions the AMI gets copied to copied will be encrypted by the default EBS KMS key for that region, unless you set region-specific keys in `region_kms_key_ids`"
  type        = string
  default     = null
}

variable "launch_block_device_mappings" {
  description = "The block device mappings to use when creating the AMI. If you add instance store volumes or EBS volumes in addition to the root device volume, the created AMI will contain block device mapping information for those volumes. Amazon creates snapshots of the source instance's root volume and any other EBS volumes described here. When you launch an instance from this new AMI, the instance automatically launches with these additional volumes, and will restore them from snapshots taken from the source instance"
  type        = list(map(string))
  default = [
    {
      device_name           = "/dev/sda1"
      volume_size           = 24
      volume_type           = "gp3"
      delete_on_termination = true
    },
  ]
}

variable "region_kms_key_ids" {
  description = "regions to copy the ami to, along with the custom kms key id (alias or arn) to use for encryption for that region. Keys must match the regions provided in `ami_regions`"
  type        = map(string)
  default     = null
}

variable "run_volume_tags" {
  description = "Tags to apply to the volumes that are launched to create the AMI. These tags are not applied to the resulting AMI"
  type        = map(string)
  default     = null
}

variable "skip_create_ami" {
  description = "If `true`, Packer will not create the AMI. Useful for setting to `true` during a build test stage. Default `false`"
  type        = bool
  default     = null
}

variable "skip_region_validation" {
  description = "Set to `true` if you want to skip validation of the `ami_regions` configuration option. Default `false`"
  type        = bool
  default     = null
}

variable "skip_save_build_region" {
  description = "If true, Packer will not check whether an AMI with the ami_name exists in the region it is building in. It will use an intermediary AMI name, which it will not convert to an AMI in the build region. Default `false`"
  type        = bool
  default     = null
}

variable "sriov_support" {
  description = "Enable enhanced networking (SriovNetSupport but not ENA) on HVM-compatible AMIs"
  type        = bool
  default     = null
}

variable "snapshot_groups" {
  description = "A list of groups that have access to create volumes from the snapshot(s). By default no groups have permission to create volumes from the snapshot(s). all will make the snapshot publicly accessible"
  type        = list(string)
  default     = null
}

variable "snapshot_tags" {
  description = "Key/value pair tags to apply to snapshot. They will override AMI tags if already applied to snapshot"
  type        = map(string)
  default     = null
}

variable "snapshot_users" {
  description = "A list of account IDs that have access to create volumes from the snapshot(s). By default no additional users other than the user creating the AMI has permissions to create volumes from the backing snapshot(s)"
  type        = list(string)
  default     = null
}

variable "tags" {
  description = "Key/value pair tags applied to the AMI"
  type        = map(string)
  default     = {}
}

# Access Configuration

variable "access_key" {
  description = "The access key used to communicate with AWS"
  type        = string
  default     = null
}

variable "assume_role" {
  description = "If provided with a role ARN, Packer will attempt to assume this role using the supplied credentials"
  type        = map(string)
  default     = {}
}

variable "aws_polling" {
  description = "Polling configuration for the AWS waiter. Configures the waiter for resources creation or actions like attaching volumes or importing image"
  type        = map(string)
  default     = {}
}

variable "custom_endpoint_ec2" {
  description = "This option is useful if you use a cloud provider whose API is compatible with aws EC2"
  type        = string
  default     = null
}

variable "decode_authorization_messages" {
  description = "Enable automatic decoding of any encoded authorization (error) messages using the sts:DecodeAuthorizationMessage API"
  type        = bool
  default     = null
}

variable "insecure_skip_tls_verify" {
  description = "This allows skipping TLS verification of the AWS EC2 endpoint. The default is `false`"
  type        = bool
  default     = null
}

variable "max_retries" {
  description = "This is the maximum number of times an API call is retried, in the case where requests are being throttled or experiencing transient failures. The delay between the subsequent API calls increases exponentially"
  type        = number
  default     = null
}

variable "mfa_code" {
  description = "The MFA TOTP code. This should probably be a user variable since it changes all the time"
  type        = string
  default     = null
}

variable "profile" {
  description = "The profile to use in the shared credentials file for AWS"
  type        = string
  default     = null
}

variable "region" {
  description = "The name of the region, such as us-east-1, in which to launch the EC2 instance to create the AMI"
  type        = string
  default     = "us-east-1"
}

variable "secret_key" {
  description = "The secret key used to communicate with AWS"
  type        = string
  default     = null
}

variable "shared_credentials_file" {
  description = "Path to a credentials file to load credentials from"
  type        = string
  default     = null
}

variable "skip_credential_validation" {
  description = "Set to true if you want to skip validating AWS credentials before runtime"
  type        = bool
  default     = null
}

variable "skip_metadata_api_check" {
  description = "Skip Metadata Api Check"
  type        = bool
  default     = null
}

variable "token" {
  description = "The access token to use. This is different from the access key and secret key"
  type        = string
  default     = null
}

# Communicator

variable "communicator" {
  description = "The communicator to use to communicate with the EC2 instance. Valid values are `none`, `ssh`, `winrm`, and `ssh+winrm`"
  type        = string
  default     = "ssh"
}

variable "pause_before_connecting" {
  description = "We recommend that you enable SSH or WinRM as the very last step in your guest's bootstrap script, but sometimes you may have a race condition where you need Packer to wait before attempting to connect to your guest"
  type        = string
  default     = null
}

variable "ssh_agent_auth" {
  description = "If true, the local SSH agent will be used to authenticate connections to the source instance. No temporary keypair will be created, and the values of `ssh_password` and `ssh_private_key_file` will be ignored. The environment variable `SSH_AUTH_SOCK` must be set for this option to work properly"
  type        = bool
  default     = null
}

variable "ssh_bastion_agent_auth" {
  description = "If `true`, the local SSH agent will be used to authenticate with the bastion host. Defaults to `false`"
  type        = bool
  default     = null
}

variable "ssh_bastion_certificate_file" {
  description = "Path to user certificate used to authenticate with bastion host. The ~ can be used in path and will be expanded to the home directory of current user"
  type        = string
  default     = null
}

variable "ssh_bastion_host" {
  description = "A bastion host to use for the actual SSH connection"
  type        = string
  default     = null
}

variable "ssh_bastion_interactive" {
  description = "If `true`, the keyboard-interactive used to authenticate with bastion host"
  type        = bool
  default     = null
}

variable "ssh_bastion_password" {
  description = "The password to use to authenticate with the bastion host"
  type        = string
  default     = null
}

variable "ssh_bastion_port" {
  description = "The port of the bastion host. Defaults to `22`"
  type        = number
  default     = null
}

variable "ssh_bastion_private_key_file" {
  description = "Path to a PEM encoded private key file to use to authenticate with the bastion host. The `~` can be used in path and will be expanded to the home directory of current user"
  type        = string
  default     = null
}

variable "ssh_bastion_username" {
  description = "The username to connect to the bastion host"
  type        = string
  default     = null
}

variable "ssh_ciphers" {
  description = "This overrides the value of ciphers supported by default by Golang. The default value is `[\"aes128-gcm@openssh.com\", \"chacha20-poly1305@openssh.com\", \"aes128-ctr\", \"aes192-ctr\", \"aes256-ctr\"]`"
  type        = list(string)
  default     = null
}

variable "ssh_certificate_file" {
  description = "Path to user certificate used to authenticate with SSH. The `~` can be used in path and will be expanded to the home directory of current user"
  type        = string
  default     = null
}

variable "ssh_clear_authorized_keys" {
  description = "If true, Packer will attempt to remove its temporary key from `~/.ssh/authorized_keys` and `/root/.ssh/authorized_keys`"
  type        = bool
  default     = null
}

variable "ssh_disable_agent_forwarding" {
  description = "If `true`, SSH agent forwarding will be disabled. Defaults to `false`"
  type        = bool
  default     = null
}

variable "ssh_file_transfer_method" {
  description = "How to transfer files, Secure copy (`scp` default) or SSH File Transfer Protocol (`sftp`)"
  type        = string
  default     = null
}

variable "ssh_handshake_attempts" {
  description = "The number of handshakes to attempt with SSH once it can connect. This defaults to `10`, unless a `ssh_timeout` is set"
  type        = number
  default     = null
}

variable "ssh_host" {
  description = "The address to SSH to. This usually is automatically configured by the builder"
  type        = string
  default     = null
}

variable "ssh_interface" {
  description = "One of `public_ip`, `private_ip`, `public_dns`, `private_dns` or `session_manager`. If set, either the public IP address, private IP address, public DNS name or private DNS name will be used as the host for SSH. The default behavior if inside a VPC is to use the public IP address if available, otherwise the private IP address will be used. If not in a VPC the public DNS name will be used"
  type        = string
  default     = "public_ip"
}

variable "ssh_keep_alive_interval" {
  description = "How often to send \"keep alive\" messages to the server. Set to a negative value (`-1s`) to disable. Defaults to `5s`"
  type        = string
  default     = null
}

variable "ssh_key_exchange_algorithms" {
  description = "If set, Packer will override the value of key exchange (kex) algorithms supported by default by Golang. Acceptable values include: `curve25519-sha256@libssh.org`, `ecdh-sha2-nistp256`, `ecdh-sha2-nistp384`, `ecdh-sha2-nistp521`, `diffie-hellman-group14-sha1`, and `diffie-hellman-group1-sha1`"
  type        = list(string)
  default     = null
}

variable "ssh_keypair_name" {
  description = "If specified, this is the key that will be used for SSH with the machine. The key must match a key pair name loaded up into the remote"
  type        = string
  default     = null
}

variable "ssh_local_tunnels" {
  description = "A list of local tunnels to use when connecting to the host"
  type        = list(string)
  default     = null
}

variable "ssh_password" {
  description = "A plaintext password to use to authenticate with SSH"
  type        = string
  default     = null
}

variable "ssh_port" {
  description = "The port to connect to SSH. This defaults to `22`"
  type        = number
  default     = null
}

variable "ssh_private_key_file" {
  description = "Path to a PEM encoded private key file to use to authenticate with SSH. The ~ can be used in path and will be expanded to the home directory of current user"
  type        = string
  default     = null
}

variable "ssh_proxy_host" {
  description = "A SOCKS proxy host to use for SSH connection"
  type        = string
  default     = null
}

variable "ssh_proxy_password" {
  description = "The optional password to use to authenticate with the proxy server"
  type        = string
  default     = null
}

variable "ssh_proxy_port" {
  description = "A port of the SOCKS proxy. Defaults to `1080`"
  type        = number
  default     = null
}

variable "ssh_proxy_username" {
  description = "The optional username to authenticate with the proxy server"
  type        = string
  default     = null
}

variable "ssh_pty" {
  description = "If `true`, a PTY will be requested for the SSH connection. This defaults to `false`"
  type        = bool
  default     = null
}

variable "ssh_read_write_timeout" {
  description = "The amount of time to wait for a remote command to end. This might be useful if, for example, packer hangs on a connection after a reboot. Example: `5m`. Disabled by default"
  type        = string
  default     = null
}

variable "ssh_remote_tunnels" {
  description = "A list of remote tunnels to use when connecting to the host"
  type        = list(string)
  default     = null
}

variable "ssh_timeout" {
  description = "The time to wait for SSH to become available. Packer uses this to determine when the machine has booted so this is usually quite long. This defaults to `5m`, unless `ssh_handshake_attempts` is set"
  type        = string
  default     = null
}

variable "ssh_username" {
  description = "The username to connect to SSH with. Required if using SSH"
  type        = string
  default     = "ubuntu"
}

variable "temporary_key_pair_type" {
  description = "Specifies the type of key to create. The possible values are 'dsa', 'ecdsa', 'ed25519', or 'rsa'. Default is `ed25519`"
  type        = string
  default     = "ed25519"
}

variable "temporary_key_pair_bits" {
  description = "Specifies the number of bits in the key to create. For RSA keys, the minimum size is 1024 bits and the default is 4096 bits. Generally, 3072 bits is considered sufficient"
  type        = number
  default     = null
}

# Run Configuration

variable "associate_public_ip_address" {
  description = "If using a non-default VPC, public IP addresses are not provided by default. If this is true, your new instance will get a Public IP"
  type        = bool
  default     = true
}

variable "capacity_reservation_preference" {
  description = "Set the preference for using a capacity reservation if one exists. Either will be `open` or `none`. Defaults to `none`"
  type        = string
  default     = null
}

variable "capacity_reservation_group_arn" {
  description = "Provide the EC2 Capacity Reservation Group ARN that will be used by Packer"
  type        = string
  default     = null
}

variable "capacity_reservation_id" {
  description = "Provide the specific EC2 Capacity Reservation ID that will be used by Packer"
  type        = string
  default     = null
}

variable "disable_stop_instance" {
  description = "If this is set to true, Packer will not stop the instance but will assume that you will send the stop signal yourself through your final provisioner"
  type        = bool
  default     = null
}

variable "ebs_optimized" {
  description = "Mark instance as EBS Optimized. Default `false`"
  type        = bool
  default     = null
}

variable "enable_nitro_enclave" {
  description = "Enable support for Nitro Enclaves on the instance"
  type        = bool
  default     = null
}

variable "enable_unlimited_credits" {
  description = "Enabling Unlimited credits allows the source instance to burst additional CPU beyond its available CPU Credits for as long as the demand exists"
  type        = bool
  default     = null
}

variable "iam_instance_profile" {
  description = "The name of an IAM instance profile to launch the EC2 instance with"
  type        = string
  default     = null
}

variable "instance_type" {
  description = "The EC2 instance type to use while building the AMI, such as `m5.large`"
  type        = string
  default     = "c5.xlarge"
}

variable "fleet_tags" {
  description = "Key/value pair tags to apply tags to the fleet that is issued"
  type        = map(string)
  default     = null
}

variable "pause_before_ssm" {
  description = "The time to wait before establishing the Session Manager session"
  type        = string
  default     = null
}

variable "placement" {
  description = "Describes the placement of an instance"
  type        = map(string)
  default     = {}
}

variable "run_tags" {
  description = "Key/value pair tags to apply to the generated key-pair, security group, iam profile and role, snapshot, network interfaces and instance that is launched to create the EBS volumes. The resulting AMI will also inherit these tags"
  type        = map(string)
  default     = null
}

variable "security_group_ids" {
  description = "A list of security group IDs to assign to the instance. By default this is not set and Packer will automatically create a new temporary security group to allow SSH access"
  type        = list(string)
  default     = null
}

variable "security_group_filter" {
  description = "Filters used to populate the `security_group_ids` field. `security_group_ids` take precedence over this"
  type        = list(map(string))
  default     = []
}

variable "session_manager_port" {
  description = "Which port to connect the local end of the session tunnel to. If left blank, Packer will choose a port for you from available ports. This option is only used when `ssh_interface` is set `session_manager`"
  type        = number
  default     = null
}

variable "shutdown_behavior" {
  description = "Automatically terminate instances on shutdown in case Packer exits ungracefully. Possible values are `stop` and `terminate`. Defaults to `stop`"
  type        = string
  default     = null
}

variable "skip_profile_validation" {
  description = "Whether or not to check if the IAM instance profile exists. Defaults to `false`"
  type        = bool
  default     = null
}

variable "subnet_filter" {
  description = "Filters used to populate the subnet_id field. `subnet_id` take precedence over this"
  default = {
    filters = {
      "tag:eks-hybrid-packer" = "true"
    }
    random = true
  }
}

variable "subnet_id" {
  description = "f using VPC, the ID of the subnet, such as subnet-12345def, where Packer will launch the EC2 instance. This field is required if you are using an non-default VPC"
  type        = string
  default     = null
}

variable "temporary_iam_instance_profile_policy_document" {
  description = "Creates a temporary instance profile policy document to grant permissions to the EC2 instance. This is an alternative to using an existing `iam_instance_profile`"
  default = [
    {
      Effect = "Allow"
      Action = [
        "ec2:Describe*",
      ]
      Resource = ["*"]
    },
  ]
}

variable "temporary_security_group_source_cidrs" {
  description = "A list of IPv4 CIDR blocks to be authorized access to the instance, when packer is creating a temporary security group. The default is `[0.0.0.0/0]`"
  type        = list(string)
  default     = null
}

variable "temporary_security_group_source_public_ip" {
  description = "When enabled, use public IP of the host (obtained from https://checkip.amazonaws.com) as CIDR block to be authorized access to the instance, when packer is creating a temporary security group. Defaults to `false`"
  type        = bool
  default     = null
}

variable "user_data" {
  description = "User data to apply when launching the instance"
  type        = string
  default     = null
}

variable "user_data_file" {
  description = "Path to a file that will be used for the user data when launching the instance"
  type        = string
  default     = null
}

variable "vpc_filter" {
  description = "Filters used to populate the `vpc_id` field. `vpc_id` take precedence over this"
  type        = list(map(string))
  default     = []
}

variable "vpc_id" {
  description = "If launching into a VPC subnet, Packer needs the VPC ID in order to create a temporary security group within the VPC. Requires `subnet_id` to be set. If this field is left blank, Packer will try to get the VPC ID from the `subnet_id`"
  type        = string
  default     = null
}

variable "metadata_options" {
  description = "Configures the metadata options for the instance launched"
  type        = map(string)
  default = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }
}

################################################################################
# Build
################################################################################

variable "shell_provisioner1" {
  description = "Values passed to the first shell provisioner"
  default     = {}
}

variable "shell_provisioner2" {
  description = "Values passed to the second shell provisioner"
  default     = {}
}

variable "shell_provisioner3" {
  description = "Values passed to the third/last shell provisioner"
  default     = {}
}
