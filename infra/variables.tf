variable "environment" {
  description = "Name of the stack environment."
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region."
  type        = string
  default     = "eu-central-1"
}

# networking
variable "vpc_cidr" {
  description = "CIDR used for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_primary_cidr" {
  description = "Primary subnet CIDR used to route outside requests back to the app."
  type        = string
}

variable "public_secondary_cidr" {
  description = "Secondary subnet CIDR used to route outside requests back to the app."
  type        = string
}

variable "data_primary_cidr" {
  description = "Primary CIDR used for the data persistence service (Postgres, Kafka)."
  type        = string
}

variable "data_secondary_cidr" {
  description = "Secondary CIDR used for the data persistence service (Postgres, Kafka)."
  type        = string
}

variable "data_tertiary_cidr" {
  description = "Tertiary CIDR used for the data persistence service (Postgres, Kafka)."
  type        = string
}

variable "app_primary_cidr" {
  description = "Primary subnet CIDR used for the applications."
  type        = string
}

variable "app_secondary_cidr" {
  description = "Secondary subnet CIDR used for the applications."
  type        = string
}

# database
variable "aurora_engine_version" {
  description = "Aurora Postgres Serverless V2 engine version."
  type        = string
}

variable "aurora_instances" {
  description = "Aurora Postgres Serverless V2 amount of instances in the cluster."
  type        = number
}

variable "aurora_max_capacity" {
  description = "Aurora Postgres Serverless V2 max amount of ACUs."
  type        = number
}

variable "aurora_min_capacity" {
  description = "Aurora Postgres Serverless V2 min amount of ACUs."
  type        = number
}

# application
variable "app_name" {
  description = "Name of the ECS application/task."
  type        = string
}

variable "desired_count" {
  description = "Desired count for the ECS application/task."
  type        = string
}

variable "cpu" {
  description = "CPU allocation for the ECS application/task."
  type        = number
}

variable "memory" {
  description = "Memory allocation for the ECS application/task."
  type        = number
}

variable "image" {
  description = "Container image for the ECS application/task."
  type        = string
}

variable "http_port" {
  description = "HTTP port for the ECS application/task."
  type        = number
}

variable "grpc_port" {
  description = "The gRPC port for the ECS application/task."
  type        = number
}
