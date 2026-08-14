variable "vpc_id" {
  description = "VPC ID passed from network module"
  type        = string
}
variable "public_subnet_ids" {
  description = "List of public subnet IDs for the ALB"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of Private Subnet IDs passed from network module"
  type        = list(string)
}
variable "aws_region" {
  description = "AWS Region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefix used for naming all resources"
  type        = string
  default     = "ivolve-final"
}

variable "ami_id" {
  description = "AMI ID for the Jenkins EC2 instance (Amazon Linux 2023 kernel-6.18 AMI)"
  type        = string
  default     = "ami-0bdc7d025135d7b49" # Update with valid AMI ID for your region
}

variable "instance_type" {
  description = "EC2 instance size"
  type        = string
  default     = "m7i-flex.large"
}