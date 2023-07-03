variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "name" {
  description = "A name to identify EFS-related resources by"
  type        = string
}

variable "security_group_ids" {
  description = "The IDs of the VPC security groups" # list?
  type        = list(string)
}

variable "subnet_ids" {
  description = "A list of the subnet IDs to add the mount target in" # list?
  type        = list(string)
}

variable "ecs_cluster_id" {
  description = "The ID of the ECS cluster"
  type        = string
}

variable "efs_port" {
  description = "The post on which to connect to EFS"
  type        = number
  default     = 2049
}
