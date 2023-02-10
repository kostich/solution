# public subnet
resource "aws_subnet" "public_primary" {
  vpc_id            = aws_vpc.solution_vpc.id
  cidr_block        = var.public_primary_cidr
  availability_zone = "${var.region}a"

  tags = {
    Name = "${var.environment}-public-primary-subnet"
  }
}

resource "aws_subnet" "public_secondary" {
  vpc_id            = aws_vpc.solution_vpc.id
  cidr_block        = var.public_secondary_cidr
  availability_zone = "${var.region}b"

  tags = {
    Name = "${var.environment}-public-secondary-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.solution_vpc.id

  tags = {
    Name = "${var.environment}-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.solution_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.environment}-public-subnet-route-table"
  }
}

resource "aws_route_table_association" "public_primary_rt_assoc_public" {
  subnet_id      = aws_subnet.public_primary.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_secondary_rt_assoc_public" {
  subnet_id      = aws_subnet.public_secondary.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_eip" "primary-ngw-eip" {
  vpc = true

  tags = {
    Name = "${var.environment}-primary-ngw-eip"
  }
}

resource "aws_eip" "secondary-ngw-eip" {
  vpc = true

  tags = {
    Name = "${var.environment}-secondary-ngw-eip"
  }
}

resource "aws_nat_gateway" "primary_ngw" {
  connectivity_type = "public"
  subnet_id         = aws_subnet.public_primary.id

  allocation_id = aws_eip.primary-ngw-eip.id

  tags = {
    Name = "${var.environment}-primary-ngw"
  }
}

resource "aws_nat_gateway" "secondary_ngw" {
  connectivity_type = "public"
  subnet_id         = aws_subnet.public_secondary.id

  allocation_id = aws_eip.secondary-ngw-eip.id

  tags = {
    Name = "${var.environment}-secondary-ngw"
  }
}

# private subnets

# mgmt
resource "aws_subnet" "mgmt" {
  vpc_id     = aws_vpc.solution_vpc.id
  cidr_block = var.mgmt_cidr

  tags = {
    Name = "${var.environment}-mgmt-subnet"
  }
}

# data
resource "aws_subnet" "data" {
  vpc_id     = aws_vpc.solution_vpc.id
  cidr_block = var.data_cidr

  tags = {
    Name = "${var.environment}-data-subnet"
  }
}

# app
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

resource "aws_route_table" "app_primary_rt" {
  vpc_id = aws_vpc.solution_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.primary_ngw.id
  }

  tags = {
    Name = "${var.environment}-app-primary-route-table"
  }
}

resource "aws_route_table" "app_secondary_rt" {
  vpc_id = aws_vpc.solution_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.secondary_ngw.id
  }

  tags = {
    Name = "${var.environment}-app-secondary-route-table"
  }
}

resource "aws_route_table_association" "app_primary_rt_assoc_public" {
  subnet_id      = aws_subnet.app_primary.id
  route_table_id = aws_route_table.app_primary_rt.id
}

resource "aws_route_table_association" "app_secondary_rt_assoc_public" {
  subnet_id      = aws_subnet.app_secondary.id
  route_table_id = aws_route_table.app_secondary_rt.id
}

resource "aws_subnet" "app_primary" {
  vpc_id            = aws_vpc.solution_vpc.id
  cidr_block        = var.app_primary_cidr
  availability_zone = "${var.region}a"

  tags = {
    Name = "${var.environment}-app-primary-subnet"
  }
}

resource "aws_subnet" "app_secondary" {
  vpc_id            = aws_vpc.solution_vpc.id
  cidr_block        = var.app_secondary_cidr
  availability_zone = "${var.region}b"

  tags = {
    Name = "${var.environment}-app-secondary-subnet"
  }
}

# Load balancers
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
