# customer-gateway

This module creates following resources.

- `aws_customer_gateway`

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12 |
| <a name="requirement_assert"></a> [assert](#requirement\_assert) | >= 0.16 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.12 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.23.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | tedilabs/misc/aws//modules/resource-group | ~> 0.12.0 |

## Resources

| Name | Type |
|------|------|
| [aws_customer_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/customer_gateway) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ip_address"></a> [ip\_address](#input\_ip\_address) | (Required) The IPv4 address for the customer gateway device's outside interface. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | (Required) A name for the customer gateway. | `string` | n/a | yes |
| <a name="input_asn"></a> [asn](#input\_asn) | (Optional) The ASN (Autonomous System Number) of the customer gateway device. Valid values are between `1` and `4294967295`. Defaults to `65000.` | `number` | `65000` | no |
| <a name="input_certificate"></a> [certificate](#input\_certificate) | (Optional) The ARN (Amazon Resource Name) of the certificate for the customer gateway. | `string` | `null` | no |
| <a name="input_device"></a> [device](#input\_device) | (Optional) A name for the customer gateway device. | `string` | `""` | no |
| <a name="input_module_tags_enabled"></a> [module\_tags\_enabled](#input\_module\_tags\_enabled) | (Optional) Whether to create AWS Resource Tags for the module informations. | `bool` | `true` | no |
| <a name="input_region"></a> [region](#input\_region) | (Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region. | `string` | `null` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | (Optional) A configurations of Resource Group for this module. `resource_group` as defined below.<br/>    (Optional) `enabled` - Whether to create Resource Group to find and group AWS resources which are created by this module. Defaults to `true`.<br/>    (Optional) `name` - The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. If not provided, a name will be generated using the module name and instance name.<br/>    (Optional) `description` - The description of Resource Group. Defaults to `Managed by Terraform.`. | <pre>object({<br/>    enabled     = optional(bool, true)<br/>    name        = optional(string, "")<br/>    description = optional(string, "Managed by Terraform.")<br/>  })</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN (Amazon Resource Name) of the customer gateway. |
| <a name="output_asn"></a> [asn](#output\_asn) | The ASN (Autonomous System Number) of the customer gateway device. |
| <a name="output_certificate"></a> [certificate](#output\_certificate) | The ARN (Amazon Resource Name) of the certificate for the customer gateway. |
| <a name="output_device"></a> [device](#output\_device) | The name for the customer gateway device. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the customer gateway. |
| <a name="output_ip_address"></a> [ip\_address](#output\_ip\_address) | The IPv4 address for the customer gateway device's outside interface. |
| <a name="output_name"></a> [name](#output\_name) | The name of the customer gateway. |
| <a name="output_region"></a> [region](#output\_region) | The AWS region this module resources resides in. |
| <a name="output_resource_group"></a> [resource\_group](#output\_resource\_group) | The resource group created to manage resources in this module. |
| <a name="output_type"></a> [type](#output\_type) | The type of customer gateway. |
<!-- END_TF_DOCS -->
