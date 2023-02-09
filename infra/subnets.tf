resource "aws_subnet" "mgmt" {
  vpc_id     = aws_vpc.solution_vpc.id
  cidr_block = var.mgmt_cidr

  tags = {
    Name = "mgmt-subnet"
  }
}

resource "aws_subnet" "data" {
  vpc_id     = aws_vpc.solution_vpc.id
  cidr_block = var.data_cidr

  tags = {
    Name = "data-subnet"
  }
}

resource "aws_subnet" "app" {
  vpc_id     = aws_vpc.solution_vpc.id
  cidr_block = var.app_cidr

  tags = {
    Name = "app-subnet"
  }
}
