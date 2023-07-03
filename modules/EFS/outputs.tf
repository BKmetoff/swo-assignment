output "system_id" {
  description = "The EFS ID"
  value       = aws_efs_file_system.fs.id
}
