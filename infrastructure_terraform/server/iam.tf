############################
# IAM Role for AWS Systems Manager (SSM)
############################
resource "aws_iam_role_policy" "jenkins_ssm_s3" {
  name = "${var.project_name}-jenkins-ssm-s3"
  role = aws_iam_role.jenkins_ssm_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:PutObject", "s3:GetObject"]
      Resource = "arn:aws:s3:::ivolve-final-ansible-ssm-transfer/*"
    }]
  })
}
resource "aws_iam_role" "jenkins_ssm_role" {
  name = "${var.project_name}-jenkins-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

# Attach standard AWS policy for SSM Session Manager terminal access
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.jenkins_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
# resource "aws_iam_role_policy_attachment" "jenkins_ecr_power_user" {
#   role       = aws_iam_role.jenkins_ssm_role.name 
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
# }

resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "${var.project_name}-jenkins-profile"
  role = aws_iam_role.jenkins_ssm_role.name
}