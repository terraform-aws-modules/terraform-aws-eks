variable "tags" {
  description = "The first variable"
  type = map(string)
  default = {}
}

variable "one" {
  description = "The first variable"
  type = object({
    tags = optional(map(string), {})
  })
  default = {}
}

output "something" {
  value = merge(
    var.tags,
    var.one.tags,
  )
}