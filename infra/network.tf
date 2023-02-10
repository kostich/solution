# public subnet
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.solution_vpc.id
  cidr_block        = var.public_cidr
  availability_zone = "${var.region}a"

  tags = {
    Name = "${var.environment}-public-subnet"
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

resource "aws_route_table_association" "public_rt_assoc_public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_eip" "eip" {
  vpc = true

  tags = {
    Name = "${var.environment}-public-ngw-eip"
  }
}

resource "aws_nat_gateway" "public_ngw" {
  connectivity_type = "public"
  subnet_id         = aws_subnet.public.id

  allocation_id = aws_eip.eip.id

  tags = {
    Name = "${var.environment}-public-ngw"
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
    from_port   = 443 # make this configurable
    to_port     = 443
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

resource "aws_route_table" "app_rt" {
  vpc_id = aws_vpc.solution_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.public_ngw.id
  }

  tags = {
    Name = "${var.environment}-app-subnet-route-table"
  }
}

resource "aws_route_table_association" "rt_assoc_public" {
  subnet_id      = aws_subnet.app.id
  route_table_id = aws_route_table.app_rt.id
}

resource "aws_subnet" "app" {
  vpc_id            = aws_vpc.solution_vpc.id
  cidr_block        = var.app_cidr
  availability_zone = "${var.region}b"

  tags = {
    Name = "${var.environment}-app-subnet"
  }
}

# Load balancers
resource "aws_lb" "alb" {
  name               = "${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.app_sg.id]
  subnets            = [aws_subnet.app.id, aws_subnet.public.id]

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
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  depends_on = [aws_lb_target_group.alb_tg]

  default_action {
    target_group_arn = aws_lb_target_group.alb_tg.arn
    type             = "forward"
  }
}
