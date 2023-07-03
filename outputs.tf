output "load_balancer_address" {
  description = "The addresses of the load balancer"
  value       = module.vpc.load_balancer_address
}

# ==== RDS ====
output "rds_hostname" {
  description = "RDS instance hostname"
  value       = module.rds.rds_hostname
  sensitive   = true
}

output "rds_port" {
  description = "RDS instance port"
  value       = module.rds.rds_port
  sensitive   = true
}

output "rds_username" {
  description = "RDS instance root username"
  value       = module.rds.rds_username
  sensitive   = true
}


output "connection_params" {
  description = "Formatted string used to crate a database and a table in the RDS instance"
  value       = module.rds.connection_params
  sensitive   = true
}

# ==== RDS ====


output "ec2_public_ip" {
  description = "The ID if the AWS account"
  value       = module.ec2_bastion.ec2_public_ip
}

