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