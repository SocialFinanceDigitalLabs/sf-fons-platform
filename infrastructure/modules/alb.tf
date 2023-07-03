resource "aws_alb" "application_load_balancer" {
  name               = "load-balancer-${var.environment}"
  load_balancer_type = "application"
  subnets = [
    aws_subnet.private-subnet-1,
    aws_subnet.private-subnet-2
  ]
  security_groups = [
    aws_security_group.allow_tls.id
  ]
}

resource "aws_lb_target_group" "target_group" {
  name        = "target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.platform.id
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_alb.application_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}