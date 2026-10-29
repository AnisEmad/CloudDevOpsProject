resource "aws_s3_bucket" "ansible_ssm_transfer" {
  bucket = "ivolve-final-ansible-ssm-transfer"

  tags = {
    Name    = "ansible-ssm-transfer"
    Purpose = "Ansible SSM file transfer"
  }
}