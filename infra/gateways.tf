resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.solution_vpc.id

  tags = {
    Name = "${var.environment}-igw"
  }
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
