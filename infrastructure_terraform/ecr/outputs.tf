output "repository_urls" {
  description = "Map of ECR repository names to their full clone/push URLs"
  value       = { for k, v in aws_ecr_repository.this : k => v.repository_url }
}

output "repository_arns" {
  description = "Map of ECR repository names to their ARNs"
  value       = { for k, v in aws_ecr_repository.this : k => v.arn }
}