locals {
  metadata = {
    package = "terraform-aws-vpn"
    version = trimspace(file("${path.module}/../../VERSION"))
    module  = basename(path.module)
    name    = var.name
  }
  module_tags = var.module_tags_enabled ? {
    "module.terraform.io/package"   = local.metadata.package
    "module.terraform.io/version"   = local.metadata.version
    "module.terraform.io/name"      = local.metadata.module
    "module.terraform.io/full-name" = "${local.metadata.package}/${local.metadata.module}"
    "module.terraform.io/instance"  = local.metadata.name
  } : {}
}

data "aws_default_tags" "this" {}

data "aws_customer_gateway" "this" {
  id = var.customer_gateway.id
}

locals {
  default_tags = data.aws_default_tags.this.tags
  common_tags = merge(
    local.default_tags,
    local.module_tags,
    var.tags,
  )
  tunnel_statuses = {
    for tunnel in aws_vpn_connection.this.vgw_telemetry :
    tunnel.outside_ip_address => tunnel
  }
}


###################################################
# VPN Connection
###################################################

resource "aws_vpn_connection" "this" {
  static_routes_only  = var.routing_type == "STATIC"
  enable_acceleration = var.target_gateway.type == "TRANSIT_GATEWAY" ? var.acceleration_enabled : null


  ## Customer Gateway
  type                    = data.aws_customer_gateway.this.type
  customer_gateway_id     = var.customer_gateway.id
  outside_ip_address_type = var.target_gateway.type == "TRANSIT_GATEWAY" ? var.customer_gateway.outside_ip_address_type : null
  # transport_transit_gateway_attachment_id - (Required when outside_ip_address_type is set to PrivateIpv4). The attachment ID of the Transit Gateway attachment to Direct Connect Gateway. The ID is obtained through a data source only.


  ## Target Gateway
  transit_gateway_id = var.target_gateway.type == "TRANSIT_GATEWAY" ? var.target_gateway.id : null
  vpn_gateway_id     = var.target_gateway.type == "VPN_GATEWAY" ? var.target_gateway.id : null


  ## Tunnel Options
  tunnel_inside_ip_version = var.target_gateway.type == "TRANSIT_GATEWAY" ? lower(var.tunnel_inside_ip_version) : null
  local_ipv4_network_cidr  = var.tunnel_inside_ip_version == "IPv4" ? var.local_ipv4_cidr : null
  local_ipv6_network_cidr  = var.tunnel_inside_ip_version == "IPv6" ? var.local_ipv6_cidr : null
  remote_ipv4_network_cidr = var.tunnel_inside_ip_version == "IPv4" ? var.remote_ipv4_cidr : null
  remote_ipv6_network_cidr = var.tunnel_inside_ip_version == "IPv6" ? var.remote_ipv6_cidr : null


  ## Tunnel 1 Options
  tunnel1_inside_cidr      = var.tunnel1_inside_ipv4_cidr
  tunnel1_inside_ipv6_cidr = var.tunnel1_inside_ipv6_cidr

  tunnel1_enable_tunnel_lifecycle_control = var.tunnel1_tunnel_endpoint_lifecycle_control_enabled

  tunnel1_preshared_key = var.tunnel1_preshared_key


  ## Tunnel 1 Initiation Options
  tunnel1_startup_action      = lower(var.tunnel1_startup_action)
  tunnel1_dpd_timeout_seconds = var.tunnel1_dpd.timeout
  tunnel1_dpd_timeout_action  = lower(var.tunnel1_dpd.timeout_action)
  # tunnel1_log_options - (Optional) Options for logging VPN tunnel activity. See Log Options below for more details.



  ## Tunnel 1 IKE Negotiation
  tunnel1_ike_versions              = var.tunnel1_ike_versions
  tunnel1_rekey_margin_time_seconds = var.tunnel1_ike_rekey.margin_time
  tunnel1_rekey_fuzz_percentage     = var.tunnel1_ike_rekey.fuzz
  tunnel1_replay_window_size        = var.tunnel1_ike_replay_window_size

  tunnel1_phase1_encryption_algorithms = var.tunnel1_ike_phase1.encryption_algorithms
  tunnel1_phase1_integrity_algorithms  = var.tunnel1_ike_phase1.integrity_algorithms
  tunnel1_phase1_dh_group_numbers      = var.tunnel1_ike_phase1.dh_group_numbers
  tunnel1_phase1_lifetime_seconds      = var.tunnel1_ike_phase1.lifetime

  tunnel1_phase2_encryption_algorithms = var.tunnel1_ike_phase2.encryption_algorithms
  tunnel1_phase2_integrity_algorithms  = var.tunnel1_ike_phase2.integrity_algorithms
  tunnel1_phase2_dh_group_numbers      = var.tunnel1_ike_phase2.dh_group_numbers
  tunnel1_phase2_lifetime_seconds      = var.tunnel1_ike_phase2.lifetime


  ## Tunnel 2 Options
  tunnel2_inside_cidr      = var.tunnel2_inside_ipv4_cidr
  tunnel2_inside_ipv6_cidr = var.tunnel2_inside_ipv6_cidr

  tunnel2_enable_tunnel_lifecycle_control = var.tunnel2_tunnel_endpoint_lifecycle_control_enabled

  tunnel2_preshared_key = var.tunnel2_preshared_key


  ## Tunnel 2 Initiation Options
  tunnel2_startup_action      = lower(var.tunnel2_startup_action)
  tunnel2_dpd_timeout_seconds = var.tunnel2_dpd.timeout
  tunnel2_dpd_timeout_action  = lower(var.tunnel2_dpd.timeout_action)


  ## Tunnel 2 IKE Negotiation
  tunnel2_ike_versions              = var.tunnel2_ike_versions
  tunnel2_rekey_margin_time_seconds = var.tunnel2_ike_rekey.margin_time
  tunnel2_rekey_fuzz_percentage     = var.tunnel2_ike_rekey.fuzz
  tunnel2_replay_window_size        = var.tunnel2_ike_replay_window_size

  tunnel2_phase1_encryption_algorithms = var.tunnel2_ike_phase1.encryption_algorithms
  tunnel2_phase1_integrity_algorithms  = var.tunnel2_ike_phase1.integrity_algorithms
  tunnel2_phase1_dh_group_numbers      = var.tunnel2_ike_phase1.dh_group_numbers
  tunnel2_phase1_lifetime_seconds      = var.tunnel2_ike_phase1.lifetime

  tunnel2_phase2_encryption_algorithms = var.tunnel2_ike_phase2.encryption_algorithms
  tunnel2_phase2_integrity_algorithms  = var.tunnel2_ike_phase2.integrity_algorithms
  tunnel2_phase2_dh_group_numbers      = var.tunnel2_ike_phase2.dh_group_numbers
  tunnel2_phase2_lifetime_seconds      = var.tunnel2_ike_phase2.lifetime


  # tunnel2_log_options - (Optional) Options for logging VPN tunnel activity. See Log Options below for more details.


  tags = merge(
    {
      "Name" = local.metadata.name
    },
    local.module_tags,
    var.tags,
  )
}

resource "aws_ec2_tag" "this" {
  for_each = merge(
    {
      "Name" = local.metadata.name
    },
    local.common_tags,
  )

  resource_id = aws_vpn_connection.this.transit_gateway_attachment_id
  key         = each.key
  value       = each.value
}


###################################################
# Static Routes for VPN Connection
###################################################

resource "aws_vpn_connection_route" "this" {
  for_each = toset(var.static_routing_destination_cidrs)

  vpn_connection_id      = aws_vpn_connection.this.id
  destination_cidr_block = each.value
}
