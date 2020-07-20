variable "alert_name_prefix" {
  type        = string
  default     = ""
  description = "String to prefix CloudWatch alerts with to avoid naming collisions"
}

variable "cpu_threshold" {
  type        = string
  default     = 90
  description = "cpu percentage threshold for the alerts"
}

variable "memory_threshold" {
  type        = string
  default     = 90
  description = "memory percentage threshold for the alerts"
}

variable "max_failed_nodes" {
  type        = string
  default     = 0
  description = "the number of nodes allowed to fail"
}

variable "cluster_name" {
  type        = string
  default     = "eks"
  description = "the eks cluster name"
}
