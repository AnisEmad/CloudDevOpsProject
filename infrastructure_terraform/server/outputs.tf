output "jenkins_alb_dns_name" {
  description = "Public URL to access the Jenkins Web UI"
  value       = aws_lb.jenkins.dns_name
}

output "jenkins_instance_id" {
  description = "EC2 Instance ID for AWS SSM terminal connection"
  value       = aws_instance.jenkins.id
}