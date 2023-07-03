output "repo_arns" {
  description = "ARN of the ECRs"
  value       = aws_ecr_repository.repo.arn
}

output "repo_urls" {
  description = "Repository URL"
  value       = aws_ecr_repository.repo.repository_url
}
