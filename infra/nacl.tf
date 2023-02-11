# Network ACLs
resource "aws_network_acl" "public" {
  vpc_id = aws_vpc.solution_vpc.id
  subnet_ids = [
    aws_subnet.public_primary.id,
    aws_subnet.public_secondary.id,
  ]

  egress {
    protocol   = "all"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "all"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "public"
  }
}

resource "aws_network_acl" "app" {
  vpc_id = aws_vpc.solution_vpc.id
  subnet_ids = [
    aws_subnet.app_primary.id,
    aws_subnet.app_secondary.id,
  ]

  egress {
    protocol   = "all"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "all"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "app"
  }
}

resource "aws_network_acl" "data" {
  vpc_id     = aws_vpc.solution_vpc.id
  subnet_ids = [aws_subnet.data_primary.id, aws_subnet.data_secondary.id, aws_subnet.data_tertiary.id]

  # PostgreSQL and Kafka connections to the app subnet
  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = var.app_primary_cidr
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    protocol   = "tcp"
    rule_no    = 201
    action     = "allow"
    cidr_block = var.app_secondary_cidr
    from_port  = 1024
    to_port    = 65535
  }

  # VPN connections to mgmt
  # egress {
  #   protocol   = "udp"
  #   rule_no    = 202
  #   action     = "allow"
  #   cidr_block = var.mgmt_cidr # TODO: specify the Wireguard EC2 instance IP here
  #   from_port  = 1024
  #   to_port    = 65535
  # }

  # PostgreSQL and Kafka connections from the app subnet
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.app_primary_cidr
    from_port  = 5432
    to_port    = 5432
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 101
    action     = "allow"
    cidr_block = var.app_secondary_cidr
    from_port  = 5432
    to_port    = 5432
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 102
    action     = "allow"
    cidr_block = var.app_primary_cidr
    from_port  = 9092
    to_port    = 9092
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 103
    action     = "allow"
    cidr_block = var.app_secondary_cidr
    from_port  = 9092
    to_port    = 9092
  }

  # VPN connections from mgmt (only Postgres!)
  # ingress {
  #   protocol   = "tcp"
  #   rule_no    = 104
  #   action     = "allow"
  #   cidr_block = var.mgmt_cidr # TODO: specify the Wireguard EC2 instance IP here
  #   from_port  = 5432
  #   to_port    = 5432
  # }

  tags = {
    Name = "data"
  }
}
