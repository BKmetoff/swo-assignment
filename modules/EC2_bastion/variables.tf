variable "name" {
  description = "An name to identify EC2-related resources by"
  type        = string
}

# format:
# "-h ${aws_db_instance.rds.address} -P ${aws_db_instance.rds.port} -u ${aws_db_instance.rds.username} -p"
variable "connection_params" {
  description = "Formatted string used by connect to the RDS instance"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "The password of the root user"
  type        = string
  sensitive   = true
}

variable "ssh_security_group_id" {
  description = "The ID of the security group opening port 443"
  type        = string
}

variable "subnet_ids" {
  description = "A list of the subnet IDs to create EC2 hosts in"
  type        = list(string)
}

