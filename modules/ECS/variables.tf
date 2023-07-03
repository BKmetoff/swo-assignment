variable "name" {
  description = "A name to identify ECS-related resources with"
  type        = string
}

variable "aws_region" {
  description = "AWS region to create resources in"
  type        = string
}

variable "account_id" {
  description = "The ID of the AWS account"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "The IDs of the private subnets in the VPC"
  type        = list(string)
}

variable "efs_system_id" {
  description = "The EFS ID"
  type        = string
}

# === Docker Image/Container
variable "container_specs" {
  description = "The specs of the container run by the ECS service"
  type = object({
    port = number
    image = object({
      name = string
      tag  = string
    })
    resources = object({
      cpu    = number
      memory = number
    })
  })
}

variable "rds_env_vars" {
  description = "The environment variables to be injected into the containers running the web app. Necessary for connecting to the RDS instance"
  type = object({
    db_hostname = string
    db_name     = string
    port        = string
    user        = string
    password    = string
  })
}
# === Docker Image/Container



# ==== Load Balancer ====
variable "load_balancer_target_group_id" {
  description = "The ID of the load balancers target group"
  type        = string
}

variable "load_balancer_target_group_arn" {
  description = "The ARN of the load balancers target group"
  type        = string
}

variable "load_balancer_security_group_id" {
  description = "The ID of the load balancer security group"
  type        = string
}
# ==== Load Balancer ====
