output "id" {
  description = "The ID of the customer gateway."
  value       = aws_customer_gateway.this.id
}

output "arn" {
  description = "The ARN (Amazon Resource Name) of the customer gateway."
  value       = aws_customer_gateway.this.arn
}

output "name" {
  description = "The name of the customer gateway."
  value       = local.metadata.name
}

output "type" {
  description = "The type of customer gateway."
  value       = aws_customer_gateway.this.type
}

output "device" {
  description = "The name for the customer gateway device."
  value       = aws_customer_gateway.this.device_name
}

output "ip_address" {
  description = "The IPv4 address for the customer gateway device's outside interface."
  value       = aws_customer_gateway.this.ip_address
}

output "asn" {
  description = "The ASN (Autonomous System Number) of the customer gateway device."
  value       = var.asn
}

output "certificate" {
  description = "The ARN (Amazon Resource Name) of the certificate for the customer gateway."
  value       = aws_customer_gateway.this.certificate_arn
}

# output "debug" {
#   description = "For debug purpose"
#   value = {
#     for k, v in aws_customer_gateway.this :
#     k => v
#     if !contains(["device_name", "type", "ip_address", "tags", "tags_all", "arn", "id", "certificate_arn", "bgp_asn", "bgp_asn_extended"], k)
#   }
# }
