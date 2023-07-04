<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_db_instance.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_parameter_group.db_param_gr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_parameter_group) | resource |
| [aws_db_subnet_group.db_subnet_gr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_security_group.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allocated_storage"></a> [allocated\_storage](#input\_allocated\_storage) | The DB storage capacity | `string` | n/a | yes |
| <a name="input_engine"></a> [engine](#input\_engine) | The DB engine | `string` | n/a | yes |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | The DB engine version | `string` | n/a | yes |
| <a name="input_esc_task_security_group_id"></a> [esc\_task\_security\_group\_id](#input\_esc\_task\_security\_group\_id) | The ID of the security group attached to the ECS task definition | `string` | n/a | yes |
| <a name="input_identifier"></a> [identifier](#input\_identifier) | A name to identify RDS resources by | `string` | n/a | yes |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | The type of DB instance to launch | `string` | n/a | yes |
| <a name="input_password"></a> [password](#input\_password) | The DB root password | `string` | n/a | yes |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | testing provisioning an rds instance | `list(string)` | n/a | yes |
| <a name="input_ssh_security_group_id"></a> [ssh\_security\_group\_id](#input\_ssh\_security\_group\_id) | The ID of the security group opening port 443 | `string` | n/a | yes |
| <a name="input_username"></a> [username](#input\_username) | The DB root username | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_connection_params"></a> [connection\_params](#output\_connection\_params) | Formatted string used to create a database and a table in the RDS instance |
| <a name="output_rds_hostname"></a> [rds\_hostname](#output\_rds\_hostname) | The hostname of the RDS instance |
| <a name="output_rds_instance_id"></a> [rds\_instance\_id](#output\_rds\_instance\_id) | The username of the root user in the instance |
| <a name="output_rds_port"></a> [rds\_port](#output\_rds\_port) | The port of the RDS instance |
| <a name="output_rds_security_group_name"></a> [rds\_security\_group\_name](#output\_rds\_security\_group\_name) | The name of the security group opening port 443. Used by the EC2 bastion for DB initialization |
| <a name="output_rds_username"></a> [rds\_username](#output\_rds\_username) | The username of the root user in the instance |
<!-- END_TF_DOCS -->