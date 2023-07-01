# AZ Eniconfig Module

This module creates eniconfigs compatible with spot and stateful self-managed node groups.
No security groups are added here, and pods will use the security group on the node they're on, this is a good default.

TF Vars [here](submodules/az_eniconfigs_no_sg/TFVARS.md)
