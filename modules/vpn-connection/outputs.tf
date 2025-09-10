output "id" {
  description = "The ID of the VPN connection."
  value       = aws_vpn_connection.this.id
}

output "arn" {
  description = "The ARN (Amazon Resource Name) of the VPN connection."
  value       = aws_vpn_connection.this.arn
}

output "name" {
  description = "The name of the VPN connection."
  value       = local.metadata.name
}

output "type" {
  description = "The type of VPN connection."
  value       = aws_vpn_connection.this.type
}

output "routing_type" {
  description = "The type of routing depend on the make and model of the customer gateway device."
  value       = aws_vpn_connection.this.static_routes_only ? "STATIC" : "DYNAMIC"
}

output "acceleration_enabled" {
  description = "Whether acceleration for the VPN connection is enabled."
  value       = aws_vpn_connection.this.enable_acceleration
}

output "customer_gateway" {
  description = <<EOF
  The information for the customer gateway of the VPN connection.
    `id` - The ID of the customer gateway.
    `outside_ip_address_type` - Whether the customer gateway device is using a public or private IPv4 address.
  EOF
  value = {
    id                      = aws_vpn_connection.this.customer_gateway_id
    outside_ip_address_type = aws_vpn_connection.this.outside_ip_address_type
  }
}

output "customer_gateway_configuration" {
  description = <<EOF
  The configuration for the customer gateway of the VPN connection.
  EOF
  value       = aws_vpn_connection.this.customer_gateway_configuration
  sensitive   = true
}

output "target_gateway" {
  description = <<EOF
  The information for the target gateway of the VPN connection.
    `type` - The type of the target gateway
    `id` - The ID of the target gateway.
  EOF
  value = {
    type = var.target_gateway.type
    id = (var.target_gateway.type == "TRANSIT_GATEWAY"
      ? aws_vpn_connection.this.transit_gateway_id
      : (var.target_gateway.type == "VPN_GATEWAY"
        ? aws_vpn_connection.this.vpn_gateway_id
        : null
      )
    )
  }
}

output "core_network" {
  description = <<EOF
  The configuration for the core network of the VPN connection.
    `arn` - The ARN of the core network.
    `attachment` - The ARN of the core network attachment.
  EOF
  value = {
    arn        = aws_vpn_connection.this.core_network_arn
    attachment = aws_vpn_connection.this.core_network_attachment_arn
  }
}

output "transit_gateway_attachment" {
  description = <<EOF
  The ID of Transit Gateway VPN Attachment.
  EOF
  value       = aws_vpn_connection.this.transit_gateway_attachment_id
}

output "tunnel_inside_ip_version" {
  description = "The IP address version of the traffic from the VPN tunnels."
  value       = aws_vpn_connection.this.tunnel_inside_ip_version
}

output "local_ipv4_cidr" {
  description = "The IPv4 CIDR on the customer gateway (on-premises) side of the VPN connection."
  value       = aws_vpn_connection.this.local_ipv4_network_cidr
}

output "local_ipv6_cidr" {
  description = "The IPv6 CIDR on the customer gateway (on-premises) side of the VPN connection."
  value       = aws_vpn_connection.this.local_ipv6_network_cidr
}

output "remote_ipv4_cidr" {
  description = "The IPv4 CIDR on the AWS side of the VPN connection."
  value       = aws_vpn_connection.this.remote_ipv4_network_cidr
}

output "remote_ipv6_cidr" {
  description = "The IPv6 CIDR on the AWS side of the VPN connection."
  value       = aws_vpn_connection.this.remote_ipv6_network_cidr
}

output "tunnel1" {
  description = <<EOF
  The configuration for the tunnel 1 of the VPN connection.
    `bgp` - The information for the BGP of the first VPN tunnel.
      `asn` - The BGP ASN number of the first VPN tunnel.
      `holdtime` - The BGP holdtime of the first VPN tunnel.
  EOF
  value = {
    inside_ipv4_cidr   = aws_vpn_connection.this.tunnel1_inside_cidr
    inside_ipv6_cidr   = aws_vpn_connection.this.tunnel1_inside_ipv6_cidr
    outside_ip_address = aws_vpn_connection.this.tunnel1_address
    inside_ip_addresses = {
      customer = aws_vpn_connection.this.tunnel1_cgw_inside_address
      target   = aws_vpn_connection.this.tunnel1_vgw_inside_address
    }
    bgp = {
      asn                  = aws_vpn_connection.this.tunnel1_bgp_asn
      holdtime             = aws_vpn_connection.this.tunnel1_bgp_holdtime
      accepted_route_count = local.tunnel_statuses[aws_vpn_connection.this.tunnel1_address].accepted_route_count
    }
    tunnel_endpoint_lifecycle_control_enabled = aws_vpn_connection.this.tunnel1_enable_tunnel_lifecycle_control
    status                                    = local.tunnel_statuses[aws_vpn_connection.this.tunnel1_address].status
    status_message                            = local.tunnel_statuses[aws_vpn_connection.this.tunnel1_address].status_message
    status_changed_at                         = local.tunnel_statuses[aws_vpn_connection.this.tunnel1_address].last_status_change
  }
}

output "tunnel1_preshared_key" {
  description = "The preshared key of the first VPN tunnel."
  value       = aws_vpn_connection.this.tunnel1_preshared_key
  sensitive   = true
}

output "tunnel1_initiation" {
  description = <<EOF
  The initiation options for the first VPN tunnel.
    `startup_action` - The action to take when the establishing the tunnel for the first VPN connection.
    `dpd` - The configuration of DPD (Dead Peer Detection) for the the first VPN tunnel.
  EOF
  value = {
    startup_action = upper(aws_vpn_connection.this.tunnel1_startup_action)
    dpd = {
      timeout        = aws_vpn_connection.this.tunnel1_dpd_timeout_seconds
      timeout_action = upper(aws_vpn_connection.this.tunnel1_dpd_timeout_action)
    }
  }
}

output "tunnel1_ike" {
  description = <<EOF
  The IKE configuration for the first VPN tunnel.
    `versions` - A set of the internet key exchange (IKE) version permitted for the first VPN tunnel.
    `rekey` - The configuration of IKE rekey for the first VPN tunnel.
    `replay_window_size` - The number of packets in an IKE replay window for the first VPN tunnel.
    `phase1` - The configuration of phase 1 IKE negotiations for the first VPN tunnel.
    `phase2` - The configuration of phase 2 IKE negotiations for the first VPN tunnel.
  EOF
  value = {
    versions = aws_vpn_connection.this.tunnel1_ike_versions
    rekey = {
      margin_time = aws_vpn_connection.this.tunnel1_rekey_margin_time_seconds
      fuzz        = aws_vpn_connection.this.tunnel1_rekey_fuzz_percentage
    }
    replay_window_size = aws_vpn_connection.this.tunnel1_replay_window_size
    phase1 = {
      encryption_algorithms = aws_vpn_connection.this.tunnel1_phase1_encryption_algorithms
      integrity_algorithms  = aws_vpn_connection.this.tunnel1_phase1_integrity_algorithms
      dh_group_numbers      = aws_vpn_connection.this.tunnel1_phase1_dh_group_numbers
      lifetime              = aws_vpn_connection.this.tunnel1_phase1_lifetime_seconds
    }
    phase2 = {
      encryption_algorithms = aws_vpn_connection.this.tunnel1_phase2_encryption_algorithms
      integrity_algorithms  = aws_vpn_connection.this.tunnel1_phase2_integrity_algorithms
      dh_group_numbers      = aws_vpn_connection.this.tunnel1_phase2_dh_group_numbers
      lifetime              = aws_vpn_connection.this.tunnel1_phase2_lifetime_seconds
    }
  }
}

output "tunnel2" {
  description = <<EOF
  The configuration for the tunnel 2 of the VPN connection.
    `bgp` - The information for the BGP of the second VPN tunnel.
      `asn` - The BGP ASN number of the second VPN tunnel.
      `holdtime` - The BGP holdtime of the second VPN tunnel.
  EOF
  value = {
    inside_ipv4_cidr   = aws_vpn_connection.this.tunnel2_inside_cidr
    inside_ipv6_cidr   = aws_vpn_connection.this.tunnel2_inside_ipv6_cidr
    outside_ip_address = aws_vpn_connection.this.tunnel2_address
    inside_ip_addresses = {
      customer = aws_vpn_connection.this.tunnel2_cgw_inside_address
      target   = aws_vpn_connection.this.tunnel2_vgw_inside_address
    }
    bgp = {
      asn                  = aws_vpn_connection.this.tunnel2_bgp_asn
      holdtime             = aws_vpn_connection.this.tunnel2_bgp_holdtime
      accepted_route_count = local.tunnel_statuses[aws_vpn_connection.this.tunnel2_address].accepted_route_count
    }
    tunnel_endpoint_lifecycle_control_enabled = aws_vpn_connection.this.tunnel2_enable_tunnel_lifecycle_control
    status                                    = local.tunnel_statuses[aws_vpn_connection.this.tunnel2_address].status
    status_message                            = local.tunnel_statuses[aws_vpn_connection.this.tunnel2_address].status_message
    status_changed_at                         = local.tunnel_statuses[aws_vpn_connection.this.tunnel2_address].last_status_change
  }
}

output "tunnel2_preshared_key" {
  description = "The preshared key of the second VPN tunnel."
  value       = aws_vpn_connection.this.tunnel2_preshared_key
  sensitive   = true
}

output "tunnel2_initiation" {
  description = <<EOF
  The initiation options for the second VPN tunnel.
    `startup_action` - The action to take when the establishing the tunnel for the second VPN connection.
    `dpd` - The configuration of DPD (Dead Peer Detection) for the the second VPN tunnel.
  EOF
  value = {
    startup_action = upper(aws_vpn_connection.this.tunnel2_startup_action)
    dpd = {
      timeout        = aws_vpn_connection.this.tunnel2_dpd_timeout_seconds
      timeout_action = upper(aws_vpn_connection.this.tunnel2_dpd_timeout_action)
    }
  }
}

output "tunnel2_ike" {
  description = <<EOF
  The IKE configuration for the second VPN tunnel.
    `versions` - A set of the internet key exchange (IKE) version permitted for the second VPN tunnel.
    `rekey` - The configuration of IKE rekey for the second VPN tunnel.
    `replay_window_size` - The number of packets in an IKE replay window for the second VPN tunnel.
    `phase1` - The configuration of phase 1 IKE negotiations for the second VPN tunnel.
    `phase2` - The configuration of phase 2 IKE negotiations for the second VPN tunnel.
  EOF
  value = {
    versions = aws_vpn_connection.this.tunnel2_ike_versions
    rekey = {
      margin_time = aws_vpn_connection.this.tunnel2_rekey_margin_time_seconds
      fuzz        = aws_vpn_connection.this.tunnel2_rekey_fuzz_percentage
    }
    replay_window_size = aws_vpn_connection.this.tunnel2_replay_window_size
    phase1 = {
      encryption_algorithms = aws_vpn_connection.this.tunnel2_phase1_encryption_algorithms
      integrity_algorithms  = aws_vpn_connection.this.tunnel2_phase1_integrity_algorithms
      dh_group_numbers      = aws_vpn_connection.this.tunnel2_phase1_dh_group_numbers
      lifetime              = aws_vpn_connection.this.tunnel2_phase1_lifetime_seconds
    }
    phase2 = {
      encryption_algorithms = aws_vpn_connection.this.tunnel2_phase2_encryption_algorithms
      integrity_algorithms  = aws_vpn_connection.this.tunnel2_phase2_integrity_algorithms
      dh_group_numbers      = aws_vpn_connection.this.tunnel2_phase2_dh_group_numbers
      lifetime              = aws_vpn_connection.this.tunnel2_phase2_lifetime_seconds
    }
  }
}

# output "debug" {
#   description = "For debug purpose"
#   value = {
#     for k, v in aws_vpn_connection.this :
#     k => v
#     if !contains(["customer_gateway_id", "customer_gateway_configuration", "type", "tags", "tags_all", "arn", "id", "enable_acceleration", "static_routes_only", "vpn_gateway_id", "transit_gateway_id", "core_network_arn", "core_network_attachment_arn", "tunnel_inside_ip_version", "local_ipv4_network_cidr", "local_ipv6_network_cidr", "remote_ipv4_network_cidr", "remote_ipv6_network_cidr", "transit_gateway_attachment_id", "outside_ip_address_type", "tunnel1_address", "tunnel1_inside_cidr", "tunnel1_inside_ipv6_cidr", "tunnel1_cgw_inside_address", "tunnel1_vgw_inside_address", "tunnel1_preshared_key", "tunnel1_ike_versions", "tunnel1_phase1_encryption_algorithms", "tunnel1_phase1_integrity_algorithms", "tunnel1_phase1_dh_group_numbers", "tunnel1_phase1_lifetime_seconds", "tunnel1_phase2_encryption_algorithms", "tunnel1_phase2_integrity_algorithms", "tunnel1_phase2_dh_group_numbers", "tunnel1_phase2_lifetime_seconds", "tunnel1_dpd_timeout_seconds", "tunnel1_dpd_timeout_action", "tunnel1_enable_tunnel_lifecycle_control", "tunnel1_bgp_asn", "tunnel1_bgp_holdtime", "tunnel1_startup_action", "tunnel1_replay_window_size", "tunnel1_rekey_margin_time_seconds", "tunnel1_rekey_fuzz_percentage", "tunnel2_address", "tunnel2_inside_cidr", "tunnel2_inside_ipv6_cidr", "tunnel2_cgw_inside_address", "tunnel2_vgw_inside_address", "tunnel2_preshared_key", "tunnel2_ike_versions", "tunnel2_phase1_encryption_algorithms", "tunnel2_phase1_integrity_algorithms", "tunnel2_phase1_dh_group_numbers", "tunnel2_phase1_lifetime_seconds", "tunnel2_phase2_encryption_algorithms", "tunnel2_phase2_integrity_algorithms", "tunnel2_phase2_dh_group_numbers", "tunnel2_phase2_lifetime_seconds", "tunnel2_dpd_timeout_seconds", "tunnel2_dpd_timeout_action", "tunnel2_enable_tunnel_lifecycle_control", "tunnel2_bgp_asn", "tunnel2_bgp_holdtime", "tunnel2_startup_action", "tunnel2_replay_window_size", "tunnel2_rekey_margin_time_seconds", "tunnel2_rekey_fuzz_percentage", "vgw_telemetry"], k)
#   }
# }

output "resource_group" {
  description = "The resource group created to manage resources in this module."
  value = merge(
    {
      enabled = var.resource_group.enabled && var.module_tags_enabled
    },
    (var.resource_group.enabled && var.module_tags_enabled
      ? {
        arn  = module.resource_group[0].arn
        name = module.resource_group[0].name
      }
      : {}
    )
  )
}
