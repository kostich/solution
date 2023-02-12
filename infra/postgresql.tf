resource "aws_security_group" "aurora_sg" {
  name   = "${var.environment}-aurora-sg"
  vpc_id = aws_vpc.solution_vpc.id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
}

resource "aws_db_subnet_group" "data_subnet_group" {
  name = "data-subnet-group"
  subnet_ids = [
    aws_subnet.data_primary.id,
    aws_subnet.data_secondary.id,
    aws_subnet.data_tertiary.id,
  ]

  tags = {
    Name = "data-subnet-group"
  }
}

resource "aws_rds_cluster" "aurora" {
  cluster_identifier      = "${var.environment}-aurora"
  engine                  = "aurora-postgresql"
  engine_mode             = "provisioned"
  engine_version          = var.aurora_engine_version
  availability_zones      = ["${var.region}a", "${var.region}b", "${var.region}c"]
  db_subnet_group_name    = aws_db_subnet_group.data_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.aurora_sg.id]
  database_name           = "postgres"                         # TODO: make this configurable from terraform.tfvars
  master_username         = "postgres"                         # TODO: make this configurable from terraform.tfvars
  master_password         = "aehuV4raimiph0iewat3wo2cie9ooGho" # TODO: Refactor to retrieve from the Secrets Manager
  backup_retention_period = 5                                  # TODO: make this configurable from terraform.tfvars
  preferred_backup_window = "07:00-09:00"                      # TODO: make this configurable from terraform.tfvars

  serverlessv2_scaling_configuration {
    max_capacity = var.aurora_max_capacity # TODO: make this configurable from terraform.tfvars
    min_capacity = var.aurora_min_capacity # TODO: make this configurable from terraform.tfvars
  }
}

resource "aws_rds_cluster_instance" "aurora" {
  count              = var.aurora_instances
  cluster_identifier = aws_rds_cluster.aurora.id
  identifier         = "${var.environment}-aurora-${count.index}"
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.aurora.engine
  engine_version     = aws_rds_cluster.aurora.engine_version
}
