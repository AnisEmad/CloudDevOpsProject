# infrastructure_terraform/outputs.tf
output "jenkins_instance_id" {
  description = "EC2 Instance ID for AWS SSM terminal connection"
  value       = module.server.jenkins_instance_id
}

output "vpc_id" {
  description = "VPC ID created by the network module"
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "Public Subnet IDs"
  value       = module.network.public_subnet_ids
}

output "ecr_repository_urls" {
  description = "URLs of the ECR repositories for Docker push"
  value       = module.ecr.repository_urls
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}