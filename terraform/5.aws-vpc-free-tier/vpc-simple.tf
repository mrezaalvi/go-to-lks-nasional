# vpc-simple.tf
# Terraform kode untuk membuat AWS VPC — Free Tier Compatible
# Tanpa variabel — semua nilai langsung di dalam 1 file
# Resource: VPC, Subnet Publik, IGW, Route Table
# TIDAK menggunakan NAT Gateway (berbayar)

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
  region = "ap-southeast-1" # Singapore
}

# ---------------------------------------------------
# VPC Utama
# CIDR 10.0.0.0/16 = 65.536 IP address
# ---------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true # EC2 mendapat hostname otomatis
  enable_dns_support   = true # aktifkan DNS resolver bawaan AWS

  tags = {
    Name        = "myapp-vpc"
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

# ---------------------------------------------------
# Internet Gateway — Pintu keluar masuk ke internet
# Gratis — tidak ada biaya per jam
# ---------------------------------------------------
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name      = "myapp-igw"
    ManagedBy = "terraform"
  }
}

# ---------------------------------------------------
# Subnet Publik — Untuk resource yang butuh akses internet
# (EC2, Bastion host, Load Balancer)
# CIDR 10.0.1.0/24 = 251 IP yang bisa digunakan
# ---------------------------------------------------
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-southeast-1a"
  map_public_ip_on_launch = true # EC2 otomatis mendapat IP publik

  tags = {
    Name      = "myapp-subnet-public"
    Type      = "public"
    ManagedBy = "terraform"
  }
}

# ---------------------------------------------------
# Subnet Privat — Untuk resource yang tidak boleh diakses langsung
# (Database, App server internal)
# CIDR 10.0.2.0/24 = 251 IP yang bisa digunakan
# Catatan: Tanpa NAT Gateway, subnet ini tidak bisa akses internet
# ---------------------------------------------------
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-southeast-1a"

  tags = {
    Name      = "myapp-subnet-private"
    Type      = "private"
    ManagedBy = "terraform"
  }
}

# ---------------------------------------------------
# Route Table Publik
# Semua trafik keluar (0.0.0.0/0) diarahkan ke Internet Gateway
# ---------------------------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"                  # semua trafik
    gateway_id = aws_internet_gateway.main.id # → Internet Gateway
  }

  tags = {
    Name      = "myapp-rt-public"
    ManagedBy = "terraform"
  }
}

# Hubungkan route table publik ke subnet publik
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ---------------------------------------------------
# Route Table Privat
# Hanya komunikasi internal VPC — tidak ada akses internet
# (Hemat biaya: tidak perlu NAT Gateway)
# ---------------------------------------------------
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  # Tidak ada route 0.0.0.0/0
  # Resource di subnet privat hanya komunikasi antar subnet dalam VPC

  tags = {
    Name      = "myapp-rt-private"
    ManagedBy = "terraform"
  }
}

# Hubungkan route table privat ke subnet privat
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# ---------------------------------------------------
# Output — Tampilkan ID setelah terraform apply
# ---------------------------------------------------
output "vpc_id" {
  value       = aws_vpc.main.id
  description = "ID VPC — gunakan saat membuat Security Group dan EC2"
}

output "vpc_cidr" {
  value       = aws_vpc.main.cidr_block
  description = "CIDR block VPC"
}

output "public_subnet_id" {
  value       = aws_subnet.public.id
  description = "ID Subnet Publik — gunakan untuk EC2, Load Balancer"
}

output "private_subnet_id" {
  value       = aws_subnet.private.id
  description = "ID Subnet Privat — gunakan untuk Database"
}

output "internet_gateway_id" {
  value       = aws_internet_gateway.main.id
  description = "ID Internet Gateway"
}

output "public_route_table_id" {
  value       = aws_route_table.public.id
  description = "ID Route Table Publik"
}

output "private_route_table_id" {
  value       = aws_route_table.private.id
  description = "ID Route Table Privat"
}
