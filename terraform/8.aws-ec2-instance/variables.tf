variable "aws_region" {
  description = "AWS region untuk deploy instance"
  type        = string
  default     = "ap-southeast-1"
}

variable "instance_type" {
  description = "Tipe EC2 instance"
  type        = string
  default     = "t3.micro"
}

variable "key_pair_name" {
  description = "Nama key pair yang sudah ada di AWS"
  type        = string
  default     = "default"
}

variable "instance_name" {
  description = "Nama tag untuk instance"
  type        = string
  default     = "my-ec2-instance"
}

variable "environment" {
  description = "Environment (production, staging, dll)"
  type        = string
  default     = "production"
}
