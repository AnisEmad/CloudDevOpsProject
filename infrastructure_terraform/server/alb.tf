############################
# Application Load Balancer (Public Subnet)
############################
resource "aws_lb" "jenkins" {
  name               = "${var.project_name}-alb"
  internal           = false # Public-facing ALB
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids 

  tags = {
    Name = "${var.project_name}-alb"
  }
}

############################
# Target Group pointing to Jenkins Port 8080
############################
resource "aws_lb_target_group" "jenkins" {
  name        = "${var.project_name}-jenkins-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/login"
    port                = "8080"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 5
  }

  tags = {
    Name = "${var.project_name}-jenkins-tg"
  }
}

############################
# ALB HTTP Listener on Port 80
############################
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.jenkins.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins.arn
  }
}

############################
# Attach Private Jenkins EC2 to Target Group
############################
resource "aws_lb_target_group_attachment" "jenkins_attach" {
  target_group_arn = aws_lb_target_group.jenkins.arn
  target_id        = aws_instance.jenkins.id
  port             = 8080
}