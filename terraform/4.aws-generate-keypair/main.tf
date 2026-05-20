# main.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

# Generate private key
resource "tls_private_key" "my_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Upload public key ke AWS
resource "aws_key_pair" "my_key" {
  key_name   = "my-generated-key"
  public_key = tls_private_key.my_key.public_key_openssh

  tags = {
    Name = "my-generated-key"
  }
}

# Simpan private key ke file lokal
resource "local_file" "private_key" {
  content         = tls_private_key.my_key.private_key_pem
  filename        = "${path.module}/my-generated-key.pem"
  file_permission = "0400"
}