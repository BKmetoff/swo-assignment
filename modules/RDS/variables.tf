variable "public_subnets" {
  description = "testing provisioning an rds instance"
  type        = list(string)
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "identifier" {
  description = "A name to identify RDS resources by"
  type        = string
}

variable "instance_class" {
  description = "The type of DB instance to launch"
  type        = string
}
variable "allocated_storage" {
  description = "The DB storage capacity"
  type        = string
}
variable "engine" {
  description = "The DB engine"
  type        = string
}
variable "engine_version" {
  description = "The DB engine version"
  type        = string
}
variable "username" {
  description = "The DB root username"
  type        = string
}
variable "password" {
  description = "The DB root password"
  type        = string
}

variable "esc_task_security_group_id" {
  description = "The ID of the security group attached to the ECS task definition"
  type        = string
}

variable "ssh_security_group_id" {
  description = "The ID of the security group opening port 443"
  type        = string
}
