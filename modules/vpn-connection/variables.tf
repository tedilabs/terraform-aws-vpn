variable "name" {
  description = "(Required) A name for the VPN connection."
  type        = string
  nullable    = false
}

variable "routing_type" {
  description = <<EOF
  (Optional) A type of routing depend on the make and model of the customer gateway device. Valid values are `DYNAMIC` and `STATIC`. Defaults to `DYNAMIC`.
    `DYNAMIC` - The customer gateway device supports Border Gateway Protocol (BGP).
    `STATIC` - The customer gateway device does not support BGP.
  EOF
  type        = string
  default     = "DYNAMIC"
  nullable    = false

  validation {
    condition     = contains(["DYNAMIC", "STATIC"], var.routing_type)
    error_message = "Valid values for `routing_type` are `DYNAMIC`, `STATIC`."
  }
}

variable "static_routing_destination_cidrs" {
  description = <<EOF
  (Optional) A set of the CIDR blocks associated with the local subnet of the customer data center.
  EOF
  type        = set(string)
  default     = []
  nullable    = false

  validation {
    condition = alltrue([
      for cidr in var.static_routing_destination_cidrs :
      provider::assert::cidr(cidr)
    ])
    error_message = "Valid values for `static_routing_destination_cidrs` are IPv4 CIDR or IPv6 CIDR."
  }
}

variable "acceleration_enabled" {
  description = "(Optional) Whether to enable acceleration for the VPN connection. Supports only for a `TRANSIT_GATEWAY` type target gateway. Defaults to `false`."
  type        = bool
  default     = false
  nullable    = false
}

variable "customer_gateway" {
  description = <<EOF
  (Required) The configuration for the customer gateway of the VPN connection. `customer_gateway` block as defined below.
    (Required) `id` - The ID of the customer gateway.
    (Optional) `outside_ip_address_type` - Whether the customer gateway device is using a public or private IPv4 address. Valid values are `PublicIpv4` and `PrivateIpv4`. Defaults to `PublicIpv4`. Configure `PrivateIpv4` if you are creating a private IP VPN connection over AWS Direct Connect.
  EOF
  type = object({
    id                      = string
    outside_ip_address_type = optional(string, "PublicIpv4")
  })
  nullable = false

  validation {
    condition     = contains(["PublicIpv4", "PrivateIpv4"], var.customer_gateway.outside_ip_address_type)
    error_message = "Valid values for `customer_gateway.outside_ip_address_type` are `PublicIpv4`, `PrivateIpv4`."
  }
}

variable "target_gateway" {
  description = <<EOF
  (Optional) The configuration for the target gateway of the VPN connection. `target_gateway` block as defined below.
    (Optional) `type` - A type of the target gateway. Valid values are `TRANSIT_GATEWAY`, `VPN_GATEWAY`, `NONE`.
    (Optional) `id` - The ID of the EC2 Transit Gateway or the Virtual Private Gateway.
  EOF
  type = object({
    type = optional(string, "NONE")
    id   = optional(string)
  })
  default  = {}
  nullable = false

  validation {
    condition     = contains(["TRANSIT_GATEWAY", "VPN_GATEWAY", "NONE"], var.target_gateway.type)
    error_message = "Valid values for `target_gateway.type` are `TRANSIT_GATEWAY`, `VPN_GATEWAY`, `NONE`."
  }
}

variable "tunnel_inside_ip_version" {
  description = <<EOF
  (Optional) The IP address version of the traffic from the VPN tunnels. Valid values are `IPv4` and `IPv6`. Defaults to `IPv4`. Supports only for a `TRANSIT_GATEWAY` type target gateway
  EOF
  type        = string
  default     = "IPv4"
  nullable    = false

  validation {
    condition     = contains(["IPv4", "IPv6"], var.tunnel_inside_ip_version)
    error_message = "Valid values for `tunnel_inside_ip_version` are `IPv4`, `IPv6`."
  }
}

variable "local_ipv4_cidr" {
  description = "(Optional) The IPv4 CIDR on the customer gateway (on-premises) side of the VPN connection. Defaults to `0.0.0.0/0`."
  type        = string
  default     = "0.0.0.0/0"
  nullable    = false

  validation {
    condition     = provider::assert::cidrv4(var.local_ipv4_cidr)
    error_message = "The value of `local_ipv4_cidr` is invalid IPv4 CIDR."
  }
}

variable "local_ipv6_cidr" {
  description = "(Optional) The IPv6 CIDR on the customer gateway (on-premises) side of the VPN connection. Defaults to `::/0`."
  type        = string
  default     = "::/0"
  nullable    = false

  validation {
    condition     = provider::assert::cidrv6(var.local_ipv6_cidr)
    error_message = "The value of `local_ipv6_cidr` is invalid IPv6 CIDR."
  }
}

variable "remote_ipv4_cidr" {
  description = "(Optional) The IPv4 CIDR on the AWS side of the VPN connection. Defaults to `0.0.0.0/0`."
  type        = string
  default     = "0.0.0.0/0"
  nullable    = false

  validation {
    condition     = provider::assert::cidrv4(var.remote_ipv4_cidr)
    error_message = "The value of `remote_ipv4_cidr` is invalid IPv4 CIDR."
  }
}

variable "remote_ipv6_cidr" {
  description = "(Optional) The IPv6 CIDR on the AWS side of the VPN connection. Defaults to `::/0`."
  type        = string
  default     = "::/0"
  nullable    = false

  validation {
    condition     = provider::assert::cidrv6(var.remote_ipv6_cidr)
    error_message = "The value of `remote_ipv6_cidr` is invalid IPv6 CIDR."
  }
}

variable "tunnel1_inside_ipv4_cidr" {
  description = "(Optional) The IPv4 CIDR of the inside IP addresses for the first VPN tunnel. Valid value is a size `/30` CIDR block from the `169.254.0.0/16` range. Defaults to be randomly generated by Amazon."
  type        = string
  default     = null
  nullable    = true

  validation {
    condition = (var.tunnel1_inside_ipv4_cidr != null
      ? provider::assert::cidrv4(var.tunnel1_inside_ipv4_cidr)
      : true
    )
    error_message = "The value of `tunnel1_inside_ipv4_cidr` is invalid IPv4 CIDR."
  }
}

variable "tunnel1_inside_ipv6_cidr" {
  description = "(Optional) The IPv6 CIDR of the inside IP addresses for the first VPN tunnel. Valid value is a size `/126` CIDR block from the local `fd00::/8` range. Supports only for a `TRANSIT_GATEWAY` type target gateway. Defaults to be randomly generated by Amazon."
  type        = string
  default     = null
  nullable    = true

  validation {
    condition = (var.tunnel1_inside_ipv6_cidr != null
      ? provider::assert::cidrv6(var.tunnel1_inside_ipv6_cidr)
      : true
    )
    error_message = "The value of `tunnel1_inside_ipv6_cidr` is invalid IPv6 CIDR."
  }
}

variable "tunnel1_tunnel_endpoint_lifecycle_control_enabled" {
  description = "(Optional) Whether to turn on or off tunnel endpoint lifecycle control feature for the first VPN tunnel. Tunnel endpoint lifecycle control provides control over the schedule of endpoint replacements. With this feature, you can choose to accept AWS managed updates to tunnel endpoints at a time that works best for your business. Defaults to `false`."
  type        = bool
  default     = false
  nullable    = false
}

variable "tunnel1_preshared_key" {
  description = "(Optional) The preshared key of the first VPN tunnel. The preshared key must be between 8 and 64 characters in length and cannot start with zero(0). Allowed characters are alphanumeric characters, periods(.) and underscores(_). Defaults to be randomly generated by Amazon."
  type        = string
  default     = null
  nullable    = true
  sensitive   = true

  validation {
    condition = (var.tunnel1_preshared_key != null
      ? can(regex("^(?!0)[a-zA-Z0-9._]{8,64}$", var.tunnel1_preshared_key))
      : true
    )
    error_message = "The preshared key must be between 8 and 64 characters, cannot start with '0', and can only contain alphanumeric characters, periods (.), or underscores (_)."
  }
}

variable "tunnel1_startup_action" {
  description = <<EOF
  (Optional) The action to take when the establishing the tunnel for the first VPN connection. Valid values are `ADD` and `START`. Defaults to `ADD`.
    `ADD` - Initiate the IKE negotiation and bring up the tunnel by the customer gateway device.
    `START` - Initiate the IKE negotiation and bring up the tunnel by AWS.
  EOF
  type        = string
  default     = "ADD"
  nullable    = false

  validation {
    condition     = contains(["ADD", "START"], var.tunnel1_startup_action)
    error_message = "Valid values for `tunnel1_startup_action` are `ADD`, `START`."
  }
}

variable "tunnel1_dpd" {
  description = <<EOF
  (Optional) A configuration of DPD (Dead Peer Detection) for the first VPN tunnel. `tunnel1_dpd` block as defined below.
    (Optional) `timeout` - The number of seconds after which a DPD timeout occurs for the first VPN tunnel. Valid value is equal or higher than `30`. Defaults to `30`.
    (Optional) `timeout_action` - The action to take after DPD timeout occurs for the first VPN tunnel. Valid values are `CLEAR`, `NONE`, `RESTART`. Defaults to `CLEAR`.
      `CLEAR` - End the IKE session.
      `NONE` - Do nothing.
      `RESTART` - Restart the IKE initiation.
  EOF
  type = object({
    timeout        = optional(number, 30),
    timeout_action = optional(string, "CLEAR"),
  })
  default  = {}
  nullable = false

  validation {
    condition     = var.tunnel1_dpd.timeout >= 30
    error_message = "Valid value for `tunnel1_dpd.timeout` is equal or higher than `30`."
  }
  validation {
    condition     = contains(["CLEAR", "NONE", "RESTART"], var.tunnel1_dpd.timeout_action)
    error_message = "Valid values for `tunnel1_dpd.timeout_action` are `CLEAR`, `NONE`, `RESTART`."
  }
}

variable "tunnel1_ike_versions" {
  description = "(Optional) A set of the internet key exchange (IKE) version permitted for the first VPN tunnel. Valid values are `ikev1`, `ikev2`. Defaults to all."
  type        = set(string)
  default     = ["ikev1", "ikev2"]
  nullable    = false

  validation {
    condition = alltrue([
      for version in var.tunnel1_ike_versions :
      contains(["ikev1", "ikev2"], version)
    ])
    error_message = "Valid values for `tunnel1_ike_versions` are `ikev1`, `ikev2`."
  }
}

variable "tunnel1_ike_rekey" {
  description = <<EOF
  (Optional) A configuration of IKE rekey for the first VPN tunnel. `tunnel1_ike_rekey` block as defined below.
    (Optional) `margin_time` - The period of time before phase 1 and 2 lifetimes expire, during which AWS initiates an IKE rekey. Valid value is between `60` and half of phase2 lifetime. Defaults to `270`.
    (Optional) `fuzz` - The percentage of the rekey window for the first VPN tunnel (determined by the rekey margin time) within which the rekey time is randomly selected. Valid value is between `0` and `100`. Defaults to `100`.
  EOF
  type = object({
    margin_time = optional(number, 270),
    fuzz        = optional(number, 100),
  })
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      var.tunnel1_ike_rekey.margin_time >= 60,
      var.tunnel1_ike_rekey.margin_time <= var.tunnel1_ike_phase2.lifetime,
    ])
    error_message = "Valid value for `tunnel1_ike_rekey.margin_time` is between `60` and half of phase 2 lifetime."
  }
  validation {
    condition = alltrue([
      var.tunnel1_ike_rekey.fuzz >= 0,
      var.tunnel1_ike_rekey.fuzz <= 100,
    ])
    error_message = "Valid value for `tunnel1_ike_rekey.fuzz` is between `0` and `100`."
  }
}

variable "tunnel1_ike_replay_window_size" {
  description = "(Optional) The number of packets in an IKE replay window for the first VPN tunnel. Valid value is between `64` and `2048`. Defaults to `1024`."
  type        = number
  default     = 1024
  nullable    = false

  validation {
    condition = alltrue([
      var.tunnel1_ike_replay_window_size >= 64,
      var.tunnel1_ike_replay_window_size <= 2048,
    ])
    error_message = "Valid value for `tunnel1_ike_replay_window_size` is between `64` and `2048`."
  }
}

variable "tunnel1_ike_phase1" {
  description = <<EOF
  (Optional) A configuration of phase 1 IKE negotiations for the first VPN tunnel. `tunnel1_ike_phase1` block as defined below.
    (Optional) `encryption_algorithms` - A set of one or more encryption algorithms that are permitted for the first VPN tunnel for phase 1 IKE negotiations. Valid values are `AES128`, `AES256`, `AES128-GCM-16`, `AES256-GCM-16`. Defaults to all.
    (Optional) `integrity_algorithms` - A set of one or more integrity algorithms that are permitted for the first VPN tunnel for phase 1 IKE negotiations. Valid values are `SHA1`, `SHA2-256`, `SHA2-384`, `SHA2-512`. Defaults to all.
    (Optional) `dh_group_numbers` - A set of one or more Diffie-Hellman group numbers that are permitted for the first VPN tunnel for phase 1 IKE negotiations. Valid values are `2`, `14`, `15`, `16`, `17`, `18`, `19`, `20`, `21`, `22`, `23`, `24`. Defaults to all.
    (Optional) `lifetime` - The lifetime for phase 1 of the IKE negotiation for the first VPN tunnel, in seconds. Valid value is between `900` and `28800`. Defaults to `28800`.
  EOF
  type = object({
    encryption_algorithms = optional(set(string), ["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"]),
    integrity_algorithms  = optional(set(string), ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"]),
    dh_group_numbers      = optional(set(number), [2, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24])
    lifetime              = optional(number, 28800)
  })
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      for algorithm in var.tunnel1_ike_phase1.encryption_algorithms :
      contains(["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"], algorithm)
    ])
    error_message = "Valid values for `tunnel1_ike_phase1.encryption_algorithms` are `AES128`, `AES256`, `AES128-GCM-16`, `AES256-GCM-16`."
  }
  validation {
    condition = alltrue([
      for algorithm in var.tunnel1_ike_phase1.integrity_algorithms :
      contains(["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"], algorithm)
    ])
    error_message = "Valid values for `tunnel1_ike_phase1.integrity_algorithms` are `SHA1`, `SHA2-256`, `SHA2-384`, `SHA2-512`."
  }
  validation {
    condition = alltrue([
      for n in var.tunnel1_ike_phase1.dh_group_numbers :
      contains([2, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24], n)
    ])
    error_message = "Valid values for `tunnel1_ike_phase1.dh_group_numbers` are `2`, `14`, `15`, `16`, `17`, `18`, `19`, `20`, `21`, `22`, `23`, `24`."
  }
  validation {
    condition = alltrue([
      var.tunnel1_ike_phase1.lifetime >= 900,
      var.tunnel1_ike_phase1.lifetime <= 28800,
    ])
    error_message = "Valid value for `tunnel1_ike_phase1.lifetime` is between `900` and `28800`."
  }
}

variable "tunnel1_ike_phase2" {
  description = <<EOF
  (Optional) A configuration of phase 2 IKE negotiations for the first VPN tunnel. `tunnel1_ike_phase2` block as defined below.
    (Optional) `encryption_algorithms` - A set of one or more encryption algorithms that are permitted for the first VPN tunnel for phase 2 IKE negotiations. Valid values are `AES128`, `AES256`, `AES128-GCM-16`, `AES256-GCM-16`. Defaults to all.
    (Optional) `integrity_algorithms` - A set of one or more integrity algorithms that are permitted for the first VPN tunnel for phase 2 IKE negotiations. Valid values are `SHA1`, `SHA2-256`, `SHA2-384`, `SHA2-512`. Defaults to all.
    (Optional) `dh_group_numbers` - A set of one or more Diffie-Hellman group numbers that are permitted for the first VPN tunnel for phase 2 IKE negotiations. Valid values are `2`, `5`, `14`, `15`, `16`, `17`, `18`, `19`, `20`, `21`, `22`, `23`, `24`. Defaults to all.
    (Optional) `lifetime` - The lifetime for phase 2 of the IKE negotiation for the first VPN tunnel, in seconds. Valid value is between `900` and `3600`. Defaults to `3600`.
  EOF
  type = object({
    encryption_algorithms = optional(set(string), ["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"]),
    integrity_algorithms  = optional(set(string), ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"]),
    dh_group_numbers      = optional(set(number), [2, 5, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24])
    lifetime              = optional(number, 3600)
  })
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      for algorithm in var.tunnel1_ike_phase2.encryption_algorithms :
      contains(["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"], algorithm)
    ])
    error_message = "Valid values for `tunnel1_ike_phase2.encryption_algorithms` are `AES128`, `AES256`, `AES128-GCM-16`, `AES256-GCM-16`."
  }
  validation {
    condition = alltrue([
      for algorithm in var.tunnel1_ike_phase2.integrity_algorithms :
      contains(["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"], algorithm)
    ])
    error_message = "Valid values for `tunnel1_ike_phase2.integrity_algorithms` are `SHA1`, `SHA2-256`, `SHA2-384`, `SHA2-512`."
  }
  validation {
    condition = alltrue([
      for n in var.tunnel1_ike_phase2.dh_group_numbers :
      contains([2, 5, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24], n)
    ])
    error_message = "Valid values for `tunnel1_ike_phase2.dh_group_numbers` are `2`, `5`, `14`, `15`, `16`, `17`, `18`, `19`, `20`, `21`, `22`, `23`, `24`."
  }
  validation {
    condition = alltrue([
      var.tunnel1_ike_phase2.lifetime >= 900,
      var.tunnel1_ike_phase2.lifetime <= 3600,
    ])
    error_message = "Valid value for `tunnel1_ike_phase2.lifetime` is between `900` and `3600`."
  }
}

variable "tunnel2_inside_ipv4_cidr" {
  description = "(Optional) The IPv4 CIDR of the inside IP addresses for the second VPN tunnel. Valid value is a size `/30` CIDR block from the `169.254.0.0/16` range. Defaults to be randomly generated by Amazon."
  type        = string
  default     = null
  nullable    = true

  validation {
    condition = (var.tunnel2_inside_ipv4_cidr != null
      ? provider::assert::cidrv4(var.tunnel2_inside_ipv4_cidr)
      : true
    )
    error_message = "The value of `tunnel2_inside_ipv4_cidr` is invalid IPv4 CIDR."
  }
}

variable "tunnel2_inside_ipv6_cidr" {
  description = "(Optional) The IPv6 CIDR of the inside IP addresses for the second VPN tunnel. Valid value is a size `/126` CIDR block from the local `fd00::/8` range. Supports only for a `TRANSIT_GATEWAY` type target gateway. Defaults to be randomly generated by Amazon."
  type        = string
  default     = null
  nullable    = true

  validation {
    condition = (var.tunnel2_inside_ipv6_cidr != null
      ? provider::assert::cidrv6(var.tunnel2_inside_ipv6_cidr)
      : true
    )
    error_message = "The value of `tunnel2_inside_ipv6_cidr` is invalid IPv6 CIDR."
  }
}

variable "tunnel2_tunnel_endpoint_lifecycle_control_enabled" {
  description = "(Optional) Whether to turn on or off tunnel endpoint lifecycle control feature for the second VPN tunnel. Tunnel endpoint lifecycle control provides control over the schedule of endpoint replacements. With this feature, you can choose to accept AWS managed updates to tunnel endpoints at a time that works best for your business. Defaults to `false`."
  type        = bool
  default     = false
  nullable    = false
}

variable "tunnel2_preshared_key" {
  description = "(Optional) The preshared key of the second VPN tunnel. The preshared key must be between 8 and 64 characters in length and cannot start with zero(0). Allowed characters are alphanumeric characters, periods(.) and underscores(_). Defaults to be randomly generated by Amazon."
  type        = string
  default     = null
  nullable    = true
  sensitive   = true

  validation {
    condition = (var.tunnel2_preshared_key != null
      ? can(regex("^(?!0)[a-zA-Z0-9._]{8,64}$", var.tunnel2_preshared_key))
      : true
    )
    error_message = "The preshared key must be between 8 and 64 characters, cannot start with '0', and can only contain alphanumeric characters, periods (.), or underscores (_)."
  }
}

variable "tunnel2_startup_action" {
  description = <<EOF
  (Optional) The action to take when the establishing the tunnel for the second VPN connection. Valid values are `ADD` and `START`. Defaults to `ADD`.
    `ADD` - Initiate the IKE negotiation and bring up the tunnel by the customer gateway device.
    `START` - Initiate the IKE negotiation and bring up the tunnel by AWS.
  EOF
  type        = string
  default     = "ADD"
  nullable    = false

  validation {
    condition     = contains(["ADD", "START"], var.tunnel2_startup_action)
    error_message = "Valid values for `tunnel2_startup_action` are `ADD`, `START`."
  }
}

variable "tunnel2_dpd" {
  description = <<EOF
  (Optional) A configuration of DPD (Dead Peer Detection) for the second VPN tunnel. `tunnel2_dpd` block as defined below.
    (Optional) `timeout` - The number of seconds after which a DPD timeout occurs for the second VPN tunnel. Valid value is equal or higher than `30`. Defaults to `30`.
    (Optional) `timeout_action` - The action to take after DPD timeout occurs for the second VPN tunnel. Valid values are `CLEAR`, `NONE`, `RESTART`. Defaults to `CLEAR`.
      `CLEAR` - End the IKE session.
      `NONE` - Do nothing.
      `RESTART` - Restart the IKE initiation.
  EOF
  type = object({
    timeout        = optional(number, 30),
    timeout_action = optional(string, "CLEAR"),
  })
  default  = {}
  nullable = false

  validation {
    condition     = var.tunnel2_dpd.timeout >= 30
    error_message = "Valid value for `tunnel2_dpd.timeout` is equal or higher than `30`."
  }
  validation {
    condition     = contains(["CLEAR", "NONE", "RESTART"], var.tunnel2_dpd.timeout_action)
    error_message = "Valid values for `tunnel2_dpd.timeout_action` are `CLEAR`, `NONE`, `RESTART`."
  }
}

variable "tunnel2_ike_versions" {
  description = "(Optional) A set of the internet key exchange (IKE) version permitted for the second VPN tunnel. Valid values are `ikev1`, `ikev2`. Defaults to all."
  type        = set(string)
  default     = ["ikev1", "ikev2"]
  nullable    = false

  validation {
    condition = alltrue([
      for version in var.tunnel2_ike_versions :
      contains(["ikev1", "ikev2"], version)
    ])
    error_message = "Valid values for `tunnel2_ike_versions` are `ikev1`, `ikev2`."
  }
}

variable "tunnel2_ike_rekey" {
  description = <<EOF
  (Optional) A configuration of IKE rekey for the second VPN tunnel. `tunnel2_ike_rekey` block as defined below.
    (Optional) `margin_time` - The period of time before phase 1 and 2 lifetimes expire, during which AWS initiates an IKE rekey. Valid value is between `60` and half of phase2 lifetime. Defaults to `270`.
    (Optional) `fuzz` - The percentage of the rekey window for the second VPN tunnel (determined by the rekey margin time) within which the rekey time is randomly selected. Valid value is between `0` and `100`. Defaults to `100`.
  EOF
  type = object({
    margin_time = optional(number, 270),
    fuzz        = optional(number, 100),
  })
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      var.tunnel2_ike_rekey.margin_time >= 60,
      var.tunnel2_ike_rekey.margin_time <= var.tunnel2_ike_phase2.lifetime,
    ])
    error_message = "Valid value for `tunnel2_ike_rekey.margin_time` is between `60` and half of phase 2 lifetime."
  }
  validation {
    condition = alltrue([
      var.tunnel2_ike_rekey.fuzz >= 0,
      var.tunnel2_ike_rekey.fuzz <= 100,
    ])
    error_message = "Valid value for `tunnel2_ike_rekey.fuzz` is between `0` and `100`."
  }
}

variable "tunnel2_ike_replay_window_size" {
  description = "(Optional) The number of packets in an IKE replay window for the second VPN tunnel. Valid value is between `64` and `2048`. Defaults to `1024`."
  type        = number
  default     = 1024
  nullable    = false

  validation {
    condition = alltrue([
      var.tunnel2_ike_replay_window_size >= 64,
      var.tunnel2_ike_replay_window_size <= 2048,
    ])
    error_message = "Valid value for `tunnel2_ike_replay_window_size` is between `64` and `2048`."
  }
}

variable "tunnel2_ike_phase1" {
  description = <<EOF
  (Optional) A configuration of phase 1 IKE negotiations for the second VPN tunnel. `tunnel2_ike_phase1` block as defined below.
    (Optional) `encryption_algorithms` - A set of one or more encryption algorithms that are permitted for the second VPN tunnel for phase 1 IKE negotiations. Valid values are `AES128`, `AES256`, `AES128-GCM-16`, `AES256-GCM-16`. Defaults to all.
    (Optional) `integrity_algorithms` - A set of one or more integrity algorithms that are permitted for the second VPN tunnel for phase 1 IKE negotiations. Valid values are `SHA1`, `SHA2-256`, `SHA2-384`, `SHA2-512`. Defaults to all.
    (Optional) `dh_group_numbers` - A set of one or more Diffie-Hellman group numbers that are permitted for the second VPN tunnel for phase 1 IKE negotiations. Valid values are `2`, `14`, `15`, `16`, `17`, `18`, `19`, `20`, `21`, `22`, `23`, `24`. Defaults to all.
    (Optional) `lifetime` - The lifetime for phase 1 of the IKE negotiation for the second VPN tunnel, in seconds. Valid value is between `900` and `28800`. Defaults to `28800`.
  EOF
  type = object({
    encryption_algorithms = optional(set(string), ["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"]),
    integrity_algorithms  = optional(set(string), ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"]),
    dh_group_numbers      = optional(set(number), [2, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24])
    lifetime              = optional(number, 28800)
  })
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      for algorithm in var.tunnel2_ike_phase1.encryption_algorithms :
      contains(["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"], algorithm)
    ])
    error_message = "Valid values for `tunnel2_ike_phase1.encryption_algorithms` are `AES128`, `AES256`, `AES128-GCM-16`, `AES256-GCM-16`."
  }
  validation {
    condition = alltrue([
      for algorithm in var.tunnel2_ike_phase1.integrity_algorithms :
      contains(["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"], algorithm)
    ])
    error_message = "Valid values for `tunnel2_ike_phase1.integrity_algorithms` are `SHA1`, `SHA2-256`, `SHA2-384`, `SHA2-512`."
  }
  validation {
    condition = alltrue([
      for n in var.tunnel2_ike_phase1.dh_group_numbers :
      contains([2, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24], n)
    ])
    error_message = "Valid values for `tunnel2_ike_phase1.dh_group_numbers` are `2`, `14`, `15`, `16`, `17`, `18`, `19`, `20`, `21`, `22`, `23`, `24`."
  }
  validation {
    condition = alltrue([
      var.tunnel2_ike_phase1.lifetime >= 900,
      var.tunnel2_ike_phase1.lifetime <= 28800,
    ])
    error_message = "Valid value for `tunnel2_ike_phase1.lifetime` is between `900` and `28800`."
  }
}

variable "tunnel2_ike_phase2" {
  description = <<EOF
  (Optional) A configuration of phase 2 IKE negotiations for the second VPN tunnel. `tunnel2_ike_phase2` block as defined below.
    (Optional) `encryption_algorithms` - A set of one or more encryption algorithms that are permitted for the second VPN tunnel for phase 2 IKE negotiations. Valid values are `AES128`, `AES256`, `AES128-GCM-16`, `AES256-GCM-16`. Defaults to all.
    (Optional) `integrity_algorithms` - A set of one or more integrity algorithms that are permitted for the second VPN tunnel for phase 2 IKE negotiations. Valid values are `SHA1`, `SHA2-256`, `SHA2-384`, `SHA2-512`. Defaults to all.
    (Optional) `dh_group_numbers` - A set of one or more Diffie-Hellman group numbers that are permitted for the second VPN tunnel for phase 2 IKE negotiations. Valid values are `2`, `5`, `14`, `15`, `16`, `17`, `18`, `19`, `20`, `21`, `22`, `23`, `24`. Defaults to all.
    (Optional) `lifetime` - The lifetime for phase 2 of the IKE negotiation for the second VPN tunnel, in seconds. Valid value is between `900` and `3600`. Defaults to `3600`.
  EOF
  type = object({
    encryption_algorithms = optional(set(string), ["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"]),
    integrity_algorithms  = optional(set(string), ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"]),
    dh_group_numbers      = optional(set(number), [2, 5, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24])
    lifetime              = optional(number, 3600)
  })
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      for algorithm in var.tunnel2_ike_phase2.encryption_algorithms :
      contains(["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"], algorithm)
    ])
    error_message = "Valid values for `tunnel2_ike_phase2.encryption_algorithms` are `AES128`, `AES256`, `AES128-GCM-16`, `AES256-GCM-16`."
  }
  validation {
    condition = alltrue([
      for algorithm in var.tunnel2_ike_phase2.integrity_algorithms :
      contains(["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"], algorithm)
    ])
    error_message = "Valid values for `tunnel2_ike_phase2.integrity_algorithms` are `SHA1`, `SHA2-256`, `SHA2-384`, `SHA2-512`."
  }
  validation {
    condition = alltrue([
      for n in var.tunnel2_ike_phase2.dh_group_numbers :
      contains([2, 5, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24], n)
    ])
    error_message = "Valid values for `tunnel2_ike_phase2.dh_group_numbers` are `2`, `5`, `14`, `15`, `16`, `17`, `18`, `19`, `20`, `21`, `22`, `23`, `24`."
  }
  validation {
    condition = alltrue([
      var.tunnel2_ike_phase2.lifetime >= 900,
      var.tunnel2_ike_phase2.lifetime <= 3600,
    ])
    error_message = "Valid value for `tunnel2_ike_phase2.lifetime` is between `900` and `3600`."
  }
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

variable "resource_group_enabled" {
  description = "(Optional) Whether to create Resource Group to find and group AWS resources which are created by this module."
  type        = bool
  default     = true
  nullable    = false
}

variable "resource_group_name" {
  description = "(Optional) The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`."
  type        = string
  default     = ""
  nullable    = false
}

variable "resource_group_description" {
  description = "(Optional) The description of Resource Group."
  type        = string
  default     = "Managed by Terraform."
  nullable    = false
}
