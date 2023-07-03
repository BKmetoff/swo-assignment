variable "aws_region" {
  description = "AWS region to create resources in"
  type        = string
}

variable "name" {
  description = "A name to identify VPC-related resources by"
  type        = string
}

variable "cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "A list of the availability zones"
  type        = list(string)
}

variable "rds_instance_id" {
  description = "The ID of the RDS instance. Used by Cloudwatch"
  type        = string
}

