output "connection_params" {
  description = "Formatted string used to create a database and a table in the RDS instance"
  value       = "-h ${aws_db_instance.rds.address} -P ${aws_db_instance.rds.port} -u ${aws_db_instance.rds.username}"
  sensitive   = true
}

output "rds_security_group_name" {
  description = "The name of the security group opening port 443. Used by the EC2 bastion for DB initialization"
  value       = aws_security_group.rds.name
}

# The three outputs below
# are used as environment variables
# for the ECS task definition.
output "rds_hostname" {
  description = "The hostname of the RDS instance"
  value       = aws_db_instance.rds.address
  sensitive   = true
}

output "rds_port" {
  description = "The port of the RDS instance"
  value       = aws_db_instance.rds.port
  sensitive   = true
}

output "rds_username" {
  description = "The username of the root user in the instance"
  value       = aws_db_instance.rds.username
  sensitive   = true
}

output "rds_instance_id" {
  description = "The username of the root user in the instance"
  value       = aws_db_instance.rds.id
  sensitive   = true
}

