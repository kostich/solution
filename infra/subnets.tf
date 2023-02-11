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

# private subnets
# data
resource "aws_subnet" "data_primary" {
  vpc_id            = aws_vpc.solution_vpc.id
  cidr_block        = var.data_primary_cidr
  availability_zone = "${var.region}a"

  tags = {
    Name = "${var.environment}-data-primary-subnet"
  }
}

resource "aws_subnet" "data_secondary" {
  vpc_id            = aws_vpc.solution_vpc.id
  cidr_block        = var.data_secondary_cidr
  availability_zone = "${var.region}b"

  tags = {
    Name = "${var.environment}-data-secondary-subnet"
  }
}

resource "aws_subnet" "data_tertiary" {
  vpc_id            = aws_vpc.solution_vpc.id
  cidr_block        = var.data_tertiary_cidr
  availability_zone = "${var.region}c"

  tags = {
    Name = "${var.environment}-data-tertiary-subnet"
  }
}

# app
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
