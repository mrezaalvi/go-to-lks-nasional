# ec2-simple.tf
# Terraform kode untuk membuat AWS EC2 Instance — Free Tier Compatible
# Spesifikasi:
#   OS            : Amazon Linux 2023
#   Instance type : t3.micro
#   Security group: Default
#   Key pair      : Default
#   VPC           : Default (ap-southeast-1a)

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
# ---------------------------------------------------
data "aws_vpc" "default" {
  default = true
}

# ---------------------------------------------------
# Data Source — Ambil Default Subnet di AZ ap-southeast-1a
# ---------------------------------------------------
data "aws_subnet" "default" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = "ap-southeast-1a"
  default_for_az    = true
}

# ---------------------------------------------------
# Data Source — Ambil Default Security Group
# ---------------------------------------------------
data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.default.id
  name   = "default"
}

# ---------------------------------------------------
# Data Source — Ambil Key Pair "default"
# Pastikan key pair bernama "default" sudah ada di AWS
# ---------------------------------------------------
data "aws_key_pair" "default" {
  key_name = "default"
}

# ---------------------------------------------------
# Data Source — Ambil AMI Amazon Linux 2023 terbaru
# Otomatis mengambil versi terbaru tanpa perlu hardcode AMI ID
# ---------------------------------------------------
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]  # hanya AMI resmi dari Amazon

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]  # pola nama Amazon Linux 2023
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# ---------------------------------------------------
# EC2 Instance — Amazon Linux 2023, t3.micro
# ---------------------------------------------------
resource "aws_instance" "main" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = "t3.micro"
  subnet_id              = data.aws_subnet.default.id
  key_name               = data.aws_key_pair.default.key_name
  vpc_security_group_ids = [data.aws_security_group.default.id]

  # Aktifkan monitoring dasar (gratis)
  # monitoring = true  # detailed monitoring berbayar $0.014/metric/bulan

  # Root volume — 30 GB gp3
  # Minimum size mengikuti snapshot AMI Amazon Linux 2023 (>= 30 GB)
  # Free tier mencakup hingga 30 GB EBS storage — jadi ini tepat di batas gratis
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 30    # GB — minimum AMI AL2023 & tepat di batas free tier
    delete_on_termination = true  # hapus volume saat instance diterminasi
    encrypted             = true  # enkripsi volume tanpa biaya tambahan
  }

  # Metadata IMDSv2 — lebih aman dari IMDSv1
  metadata_options {
    http_tokens                 = "required"   # wajib gunakan IMDSv2
    http_put_response_hop_limit = 1
    http_endpoint               = "enabled"
  }

  tags = {
    Name        = "myapp-ec2"
    OS          = "Amazon Linux 2023"
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

# ---------------------------------------------------
# Output — Tampilkan informasi instance setelah apply
# ---------------------------------------------------
output "instance_id" {
  value       = aws_instance.main.id
  description = "ID EC2 instance"
}

output "instance_public_ip" {
  value       = aws_instance.main.public_ip
  description = "IP publik EC2 instance"
}

output "instance_private_ip" {
  value       = aws_instance.main.private_ip
  description = "IP privat EC2 instance"
}

output "instance_ami" {
  value       = data.aws_ami.amazon_linux_2023.id
  description = "AMI ID Amazon Linux 2023 yang digunakan"
}

output "instance_ami_name" {
  value       = data.aws_ami.amazon_linux_2023.name
  description = "Nama AMI Amazon Linux 2023 yang digunakan"
}

output "ssh_command" {
  value       = "ssh -i ~/.ssh/id_rsa ec2-user@${aws_instance.main.public_ip}"
  description = "Perintah SSH untuk masuk ke instance"
}
