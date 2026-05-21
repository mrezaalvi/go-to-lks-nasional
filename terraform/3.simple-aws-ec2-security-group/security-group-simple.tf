# security-group-simple.tf
# Terraform kode sederhana untuk membuat AWS Security Group
# Tanpa variabel — semua nilai langsung di dalam 1 file
# Menggunakan Default VPC otomatis (tidak perlu VPC ID manual)

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# ---------------------------------------------------
# Provider — Region AWS
# ---------------------------------------------------
provider "aws" {
  region = "ap-southeast-1"  # Singapore
}

# ---------------------------------------------------
# Data Source — Ambil Default VPC secara otomatis
# Tidak perlu tahu atau hardcode VPC ID
# ---------------------------------------------------
data "aws_vpc" "default" {
  default = true
}

# ---------------------------------------------------
# Security Group — dibuat di dalam Default VPC
# ---------------------------------------------------
resource "aws_security_group" "main" {
  name        = "myapp-production-sg"
  description = "Security group untuk EC2 myapp"
  vpc_id      = data.aws_vpc.default.id  # ← referensi ke Default VPC

  tags = {
    Name        = "myapp-production-sg"
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

# ---------------------------------------------------
# INBOUND — Port 80 (HTTP publik)
# ---------------------------------------------------
resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.main.id
  description       = "HTTP dari internet"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

# ---------------------------------------------------
# INBOUND — Port 443 (HTTPS publik)
# ---------------------------------------------------
resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.main.id
  description       = "HTTPS dari internet"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

# ---------------------------------------------------
# INBOUND — Port 22 (SSH dari IP tertentu saja)
# ---------------------------------------------------
resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.main.id
  description       = "SSH dari IP developer"
  cidr_ipv4         = "103.10.20.30/32"  # Ganti dengan IP publik kamu
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

# ---------------------------------------------------
# OUTBOUND — Semua trafik keluar diizinkan
# ---------------------------------------------------
resource "aws_vpc_security_group_egress_rule" "all_outbound" {
  security_group_id = aws_security_group.main.id
  description       = "Izinkan semua trafik keluar"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"  # -1 = semua protokol
}

# ---------------------------------------------------
# Output — Tampilkan ID setelah terraform apply
# ---------------------------------------------------
output "security_group_id" {
  value       = aws_security_group.main.id
  description = "ID Security Group — gunakan ini saat membuat EC2"
}

output "default_vpc_id" {
  value       = data.aws_vpc.default.id
  description = "ID Default VPC yang digunakan secara otomatis"
}

output "default_vpc_cidr" {
  value       = data.aws_vpc.default.cidr_block
  description = "CIDR block Default VPC"
}
