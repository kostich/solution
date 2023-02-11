# Load balancers
resource "aws_security_group" "app_sg" {
  name   = "${var.environment}-app-sg"
  vpc_id = aws_vpc.solution_vpc.id

  ingress {
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.grpc_port
    to_port     = var.grpc_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "alb" {
  name                       = "${var.environment}-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.app_sg.id]
  subnets                    = [aws_subnet.public_primary.id, aws_subnet.public_secondary.id]
  preserve_host_header       = true
  enable_deletion_protection = false

  # TODO: make a bucket to store access logs
  # access_logs {
  #   bucket  = aws_s3_bucket.lb_logs.bucket
  #   prefix  = "test-lb"
  #   enabled = true
  # }

  tags = {
    Environment = "${var.environment}"
  }
}

resource "aws_lb_target_group" "alb_tg" {
  name        = "${var.environment}-alb"
  target_type = "ip"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.solution_vpc.id

  health_check {
    healthy_threshold   = 5
    unhealthy_threshold = 2
    path                = "/healthz"
  }
}

resource "aws_lb_listener" "alb_listener_http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = var.http_port
  protocol          = "HTTP"

  depends_on = [aws_lb_target_group.alb_tg]

  default_action {
    target_group_arn = aws_lb_target_group.alb_tg.arn
    type             = "forward"
  }
}

resource "aws_lb_listener" "alb_listener_grpc" {
  load_balancer_arn = aws_lb.alb.arn
  port              = var.grpc_port
  protocol          = "HTTP"

  depends_on = [aws_lb_target_group.alb_tg]

  default_action {
    target_group_arn = aws_lb_target_group.alb_tg.arn
    type             = "forward"
  }
}
