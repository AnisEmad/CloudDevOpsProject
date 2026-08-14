terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.100.0"
    }
  }

  backend "s3" {
    bucket = "backend-bucket-ivolve"
    key    = "terraform.tfstate"
    region = "us-east-1"
    # dynamodb_table = "terraform-state-locks"
    encrypt      = true
    use_lockfile = true
  }
}