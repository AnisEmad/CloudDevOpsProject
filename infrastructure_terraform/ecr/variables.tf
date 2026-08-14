variable "repository_names" {
  description = "List of ECR repository names to create"
  type        = list(string)
  default     = ["ivolve-auth", "ivolve-roadmap", "ivolve-frontend"]
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository (MUTABLE or IMMUTABLE)"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Indicates whether images are scanned after being pushed to the repository"
  type        = bool
  default     = true
}

variable "max_image_count" {
  description = "Maximum number of images to retain in each repository before purging older ones"
  type        = number
  default     = 10
}

variable "project_name" {
  description = "Project name tag"
  type        = string
  default     = "ivolve"
}