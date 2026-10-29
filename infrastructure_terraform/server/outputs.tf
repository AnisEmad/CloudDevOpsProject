

output "jenkins_instance_id" {
  description = "EC2 Instance ID for AWS SSM terminal connection"
  value       = aws_instance.jenkins.id
}