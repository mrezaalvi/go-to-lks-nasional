variable "aws_region" {
  description = "AWS region untuk deploy"
  type        = string
  default     = "ap-southeast-1" # Singapore - terdekat dari Indonesia
}

variable "app_name" {
  description = "Nama aplikasi (dipakai sebagai prefix semua resource)"
  type        = string
  default     = "myapp"
}

variable "environment" {
  description = "Environment (production, staging, dll)"
  type        = string
  default     = "production"
}

variable "ec2_instance_type" {
  description = "Tipe EC2 instance"
  type        = string
  default     = "t3.micro" # Free tier eligible
}

variable "ec2_ami_id" {
  description = "AMI ID untuk EC2 (Amazon Linux 2023)"
  type        = string
  default     = "ami-0df7a207adb9748c7" # Amazon Linux 2023 ap-southeast-1
}

variable "key_pair_name" {
  description = "Nama untuk EC2 Key Pair yang akan dibuat Terraform"
  type        = string
  default     = "myapp-keypair"
}

variable "ssh_public_key_path" {
  description = "Path ke file public key (~/.ssh/id_rsa.pub). Generate dulu: ssh-keygen -t rsa -b 4096"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "ssh_allowed_cidr" {
  description = "CIDR block yang boleh SSH ke EC2. Gunakan IP kamu saja: x.x.x.x/32 (cek: curl ifconfig.me)"
  type        = string
  default     = "0.0.0.0/0" # Ganti dengan IP kamu untuk keamanan!
}

variable "db_name" {
  description = "Nama database MySQL"
  type        = string
  sensitive   = true
}

variable "db_user" {
  description = "Username MySQL"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Password MySQL"
  type        = string
  sensitive   = true
}

variable "db_root_password" {
  description = "Root password MySQL"
  type        = string
  sensitive   = true
}
