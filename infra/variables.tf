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

variable "public_cidr" {
  description = "CIDR used to route outside requests back to the app."
  type        = string
}

variable "mgmt_cidr" {
  description = "CIDR used for the VPN management nodes."
  type        = string
}

variable "data_cidr" {
  description = "CIDR used for the data persistence service (Postgres, Kafka)."
  type        = string
}

variable "app_cidr" {
  description = "CIDR used for the applications."
  type        = string
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

