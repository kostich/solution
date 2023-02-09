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

variable "vpc_cidr" {
  description = "CIDR used for the VPC."
  type        = string
  default     = "10.0.0.0/16"
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
