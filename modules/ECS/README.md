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
| [aws_appautoscaling_policy.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_target.ecs_service_autoscaling_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_ecs_cluster.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_service.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_efs_access_point.ap](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_access_point) | resource |
| [aws_iam_policy.ecs_service_scaling](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy_attachment.ecs_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment) | resource |
| [aws_iam_role.ecs_rds_access_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ecs_service_scaling](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_security_group.task_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_iam_policy_document.ecs_service_scaling](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_role.ecs_task_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_role) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | The ID of the AWS account | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region to create resources in | `string` | n/a | yes |
| <a name="input_container_specs"></a> [container\_specs](#input\_container\_specs) | The specs of the container run by the ECS service | <pre>object({<br>    port = number<br>    image = object({<br>      name = string<br>      tag  = string<br>    })<br>    resources = object({<br>      cpu    = number<br>      memory = number<br>    })<br>  })</pre> | n/a | yes |
| <a name="input_efs_system_id"></a> [efs\_system\_id](#input\_efs\_system\_id) | The EFS ID | `string` | n/a | yes |
| <a name="input_load_balancer_security_group_id"></a> [load\_balancer\_security\_group\_id](#input\_load\_balancer\_security\_group\_id) | The ID of the load balancer security group | `string` | n/a | yes |
| <a name="input_load_balancer_target_group_arn"></a> [load\_balancer\_target\_group\_arn](#input\_load\_balancer\_target\_group\_arn) | The ARN of the load balancers target group | `string` | n/a | yes |
| <a name="input_load_balancer_target_group_id"></a> [load\_balancer\_target\_group\_id](#input\_load\_balancer\_target\_group\_id) | The ID of the load balancers target group | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | A name to identify ECS-related resources with | `string` | n/a | yes |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | The IDs of the private subnets in the VPC | `list(string)` | n/a | yes |
| <a name="input_rds_env_vars"></a> [rds\_env\_vars](#input\_rds\_env\_vars) | The environment variables to be injected into the containers running the web app. Necessary for connecting to the RDS instance | <pre>object({<br>    db_hostname = string<br>    db_name     = string<br>    port        = string<br>    user        = string<br>    password    = string<br>  })</pre> | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecr_cluster_id"></a> [ecr\_cluster\_id](#output\_ecr\_cluster\_id) | The ID of the ECS cluster |
| <a name="output_esc_task_security_group_id"></a> [esc\_task\_security\_group\_id](#output\_esc\_task\_security\_group\_id) | The ID of the ECS task security group |
<!-- END_TF_DOCS -->