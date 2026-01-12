variable "create" {
  description = "Controls if resources should be created (affects nearly all resources)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "region" {
  description = "Region where the resource(s) will be managed. Defaults to the Region set in the provider configuration"
  type        = string
  default     = null
}

################################################################################
# Capabilities
################################################################################

variable "capabilities" {
  description = "Map of capability definitions to create"
  type = map(object({
    capability_name = optional(string) # will fall back to map key
    configuration = optional(object({
      argo_cd = optional(object({
        aws_idc = object({
          idc_instance_arn = string
          idc_region       = optional(string)
        })
        namespace = optional(string)
        network_access = optional(object({
          vpce_ids = optional(list(string))
        }))
        rbac_role_mapping = optional(object({
          identity = list(object({
            id   = string
            type = string
          }))
          role = string
        }))
      }))
    }))
    delete_propagation_policy = optional(string)
    role_arn                  = string
    type                      = string
    timeouts = optional(object({
      create = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
    tags = optional(map(string))
  }))
  default = null
}
