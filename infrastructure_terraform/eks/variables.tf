variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "ivolve-eks-cluster"
}

variable "vpc_id" {
  description = "VPC ID where EKS will be deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for EKS worker nodes"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for control plane endpoints / public ALBs"
  type        = list(string)
}

variable "node_instance_types" {
  description = "EC2 instance types for the EKS node group"
  type        = list(string)
  default     = ["t3.small"]
}

variable "desired_capacity" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of worker nodes for auto-scaling"
  type        = number
  default     = 4
}

variable "project_name" {
  description = "Prefix for tagging resources"
  type        = string
  default     = "ivolve"
}