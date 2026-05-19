terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Opsional: simpan state di S3 agar bisa diakses tim
  # backend "s3" {
  #   bucket = "my-terraform-state"
  #   key    = "myapp/terraform.tfstate"
  #   region = "ap-southeast-1"
  # }
}

provider "aws" {
  region = var.aws_region
}

# ============================================================
# Data sources
# ============================================================
data "aws_caller_identity" "current" {}

# ============================================================
# ECR Repository
# ============================================================
resource "aws_ecr_repository" "app" {
  name                 = "${var.app_name}-${var.environment}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = local.common_tags
}

# Lifecycle policy: hapus image lama, simpan 10 terbaru
resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Simpan hanya 10 image terbaru"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
      action = { type = "expire" }
    }]
  })
}

# ============================================================
# IAM Role untuk EC2 (agar bisa pull dari ECR)
# ============================================================
resource "aws_iam_role" "ec2_role" {
  name = "${var.app_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "ecr_readonly" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.app_name}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# ============================================================
# VPC Default (pakai default VPC untuk simplicity)
# ============================================================
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# ============================================================
# Key Pair (dibuat dari public key lokal kamu)
# Generate dulu jika belum ada: ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa
# ============================================================
resource "aws_key_pair" "app" {
  key_name   = var.key_pair_name
  public_key = file(pathexpand(var.ssh_public_key_path))

  tags = merge(local.common_tags, { Name = var.key_pair_name })
}

# ============================================================
# Security Group
# Port 3000 TIDAK dibuka ke publik — traffic masuk lewat Nginx (port 80/443)
# ============================================================
resource "aws_security_group" "app" {
  name        = "${var.app_name}-sg"
  description = "Security group untuk ${var.app_name}"
  vpc_id      = data.aws_vpc.default.id

  # HTTP — Nginx menerima traffic publik di port ini
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP dari internet"
  }

  # HTTPS — untuk SSL/TLS (aktifkan setelah pasang sertifikat)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS dari internet"
  }

  # SSH — dibatasi ke IP kamu saja (isi ssh_allowed_cidr di tfvars)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
    description = "SSH hanya dari IP yang diizinkan"
  }

  # Semua outbound dibolehkan (untuk pull ECR, update OS, dll)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Semua outbound"
  }

  tags = merge(local.common_tags, { Name = "${var.app_name}-sg" })
}

# ============================================================
# EC2 Instance
# ============================================================

# User data script: install Docker, pull image dari ECR, jalankan
locals {
  common_tags = {
    App         = var.app_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }

  ecr_url = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"

  user_data = base64encode(templatefile("${path.module}/user_data.sh.tpl", {
    aws_region       = var.aws_region
    ecr_url          = local.ecr_url
    app_name         = var.app_name
    environment      = var.environment
    ecr_image        = aws_ecr_repository.app.repository_url
    db_name          = var.db_name
    db_user          = var.db_user
    db_password      = var.db_password
    db_root_password = var.db_root_password
  }))
}

resource "aws_instance" "app" {
  ami                    = var.ec2_ami_id
  instance_type          = var.ec2_instance_type
  key_name               = aws_key_pair.app.key_name
  vpc_security_group_ids = [aws_security_group.app.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  subnet_id              = tolist(data.aws_subnets.default.ids)[0]

  user_data = local.user_data

  root_block_device {
    volume_size = 20 # GB
    volume_type = "gp3"
    encrypted   = true
  }

  tags = merge(local.common_tags, { Name = "${var.app_name}-${var.environment}" })
}

# Elastic IP agar IP tidak berubah saat instance restart
resource "aws_eip" "app" {
  instance = aws_instance.app.id
  domain   = "vpc"

  tags = merge(local.common_tags, { Name = "${var.app_name}-eip" })
}

# ============================================================
# Outputs
# ============================================================
output "ec2_public_ip" {
  description = "Public IP EC2"
  value       = aws_eip.app.public_ip
}

output "ecr_repository_url" {
  description = "URL ECR repository"
  value       = aws_ecr_repository.app.repository_url
}

output "key_pair_name" {
  description = "Nama Key Pair yang dibuat"
  value       = aws_key_pair.app.key_name
}

output "ssh_command" {
  description = "Perintah SSH ke EC2"
  value       = "ssh -i ${replace(var.ssh_public_key_path, ".pub", "")} ec2-user@${aws_eip.app.public_ip}"
}
