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


###################################################
# Customer Gateway
###################################################

resource "aws_customer_gateway" "this" {
  device_name      = var.device
  ip_address       = var.ip_address
  bgp_asn          = var.asn >= 2147483648 ? null : var.asn
  bgp_asn_extended = var.asn >= 2147483648 ? var.asn : null

  type            = "ipsec.1"
  certificate_arn = var.certificate

  tags = merge(
    {
      "Name" = local.metadata.name
    },
    local.module_tags,
    var.tags,
  )
}
