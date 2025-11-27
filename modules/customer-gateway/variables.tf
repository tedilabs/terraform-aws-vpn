variable "region" {
  description = "(Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region."
  type        = string
  default     = null
  nullable    = true
}

variable "name" {
  description = "(Required) A name for the customer gateway."
  type        = string
  nullable    = false
}

variable "device" {
  description = "(Optional) A name for the customer gateway device."
  type        = string
  default     = ""
  nullable    = false
}

variable "ip_address" {
  description = "(Required) The IPv4 address for the customer gateway device's outside interface."
  type        = string
  nullable    = false

  validation {
    condition     = provider::assert::ipv4(var.ip_address)
    error_message = "The value of `ip_address` is invalid IPv4 address."
  }
}

variable "asn" {
  description = "(Optional) The ASN (Autonomous System Number) of the customer gateway device. Valid values are between `1` and `4294967295`. Defaults to `65000.`"
  type        = number
  default     = 65000
  nullable    = false

  validation {
    condition = alltrue([
      var.asn >= 1,
      var.asn <= 4294967295,
    ])
    error_message = "Valid values are between `1` and `4294967295`."
  }
}

variable "certificate" {
  description = "(Optional) The ARN (Amazon Resource Name) of the certificate for the customer gateway."
  type        = string
  default     = null
  nullable    = true
}

variable "tags" {
  description = "(Optional) A map of tags to add to all resources."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "module_tags_enabled" {
  description = "(Optional) Whether to create AWS Resource Tags for the module informations."
  type        = bool
  default     = true
  nullable    = false
}


###################################################
# Resource Group
###################################################

variable "resource_group" {
  description = <<EOF
  (Optional) A configurations of Resource Group for this module. `resource_group` as defined below.
    (Optional) `enabled` - Whether to create Resource Group to find and group AWS resources which are created by this module. Defaults to `true`.
    (Optional) `name` - The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. If not provided, a name will be generated using the module name and instance name.
    (Optional) `description` - The description of Resource Group. Defaults to `Managed by Terraform.`.
  EOF
  type = object({
    enabled     = optional(bool, true)
    name        = optional(string, "")
    description = optional(string, "Managed by Terraform.")
  })
  default  = {}
  nullable = false
}
