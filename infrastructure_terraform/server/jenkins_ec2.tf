############################
# Jenkins EC2 Instance (Private Subnet)
############################
# resource "aws_key_pair" "jenkins" {
#   key_name   = "${var.project_name}-jenkins-key"
#   public_key = file("~/.ssh/jenkins-key.pem.pub")
# }
resource "aws_instance" "jenkins" {
  ami                     = var.ami_id
  instance_type           = var.instance_type
  subnet_id               = var.private_subnet_ids[0]
  vpc_security_group_ids  = [aws_security_group.jenkins_sg.id]
  iam_instance_profile    = aws_iam_instance_profile.jenkins_profile.name

  tags = {
    Name = "${var.project_name}-jenkins-server"
  }
}