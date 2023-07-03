output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.vpc.id
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets in the VPC"
  value       = [for subnet in aws_subnet.private : subnet.id]
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets in the VPC"
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "ssh_security_group_id" {
  value = aws_security_group.ec2_ssh_rds.id
}

# ==== ELB ====
output "load_balancer_address" {
  description = "The addresses of the load balancer"
  value       = aws_lb.lb.dns_name
}

output "load_balancer_security_group_id" {
  description = "The ID of the load balancer security group"
  value       = aws_security_group.lb.id
}

output "load_balancer_target_group_id" {
  description = "A list of the IDs of the load balancers target groups"
  value       = aws_lb_target_group.lb_tg.id
}

output "load_balancer_target_group_arn" {
  description = "A list of the IDs of the load balancers target groups"
  value       = aws_lb_target_group.lb_tg.arn
}

