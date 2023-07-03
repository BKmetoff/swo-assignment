# allow incoming connections on port 80
# allow outgoing connections to everywhere
resource "aws_security_group" "lb" {
  name   = "${var.name}-alb-sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# attach the load balancer to all public subnets
resource "aws_lb" "lb" {
  name            = "${var.name}-lb"
  subnets         = aws_subnet.public[*].id
  security_groups = [aws_security_group.lb.id]
}

# forward the traffic coming to the load balancer to ECS
resource "aws_lb_target_group" "lb_tg" {
  name        = "${var.name}-lb-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  target_type = "ip"
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.lb.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.lb_tg.id
    type             = "forward"
  }
}
