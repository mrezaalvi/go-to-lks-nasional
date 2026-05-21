# s3-simple.tf
# Terraform kode untuk membuat AWS S3 Bucket — Free Tier Compatible
# Tanpa variabel — semua nilai langsung di dalam 1 file
# Fitur: versioning, lifecycle policy, enkripsi, public access block

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
# Data Source — Ambil Account ID secara otomatis
# Digunakan untuk membuat nama bucket yang unik secara global
# ---------------------------------------------------
data "aws_caller_identity" "current" {}

# ---------------------------------------------------
# S3 Bucket Utama
# Nama bucket harus unik secara global di seluruh AWS
# Format: {app-name}-{account-id} untuk memastikan keunikan
# ---------------------------------------------------
resource "aws_s3_bucket" "main" {
  bucket = "myapp-bucket-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name        = "myapp-bucket"
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

# ---------------------------------------------------
# Versioning — Simpan riwayat setiap versi objek
# Berguna untuk recovery jika file terhapus/tertimpa
# Catatan: versioning menambah storage usage — pantau agar tetap di free tier
# ---------------------------------------------------
resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = "Enabled"
  }
}

# ---------------------------------------------------
# Server-Side Encryption — Enkripsi semua objek secara otomatis
# SSE-S3 menggunakan AES-256, gratis tanpa biaya tambahan
# ---------------------------------------------------
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256" # SSE-S3, gratis
    }
    bucket_key_enabled = true # kurangi biaya request enkripsi
  }
}

# ---------------------------------------------------
# Block Public Access — Blokir semua akses publik
# PENTING: jangan diubah kecuali bucket memang untuk hosting website publik
# ---------------------------------------------------
resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true # blokir public ACL baru
  block_public_policy     = true # blokir bucket policy yang mengizinkan akses publik
  ignore_public_acls      = true # abaikan public ACL yang sudah ada
  restrict_public_buckets = true # batasi bucket dari akses publik
}

# ---------------------------------------------------
# Lifecycle Policy — Kelola objek lama secara otomatis
# Membantu menjaga storage tetap di batas free tier (5 GB)
# ---------------------------------------------------
resource "aws_s3_bucket_lifecycle_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  # Tunggu versioning aktif sebelum lifecycle dikonfigurasi
  depends_on = [aws_s3_bucket_versioning.main]

  # ---------------------------------------------------
  # Rule 1 — Transisi objek lama ke storage class lebih murah
  # ---------------------------------------------------
  rule {
    id     = "transition-old-objects"
    status = "Enabled"

    # Terapkan ke semua objek di bucket
    filter {
      prefix = ""
    }

    # Setelah 30 hari → pindah ke S3 Standard-IA (Infrequent Access)
    # Lebih murah untuk objek yang jarang diakses
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    # Setelah 90 hari → pindah ke S3 Glacier Instant Retrieval
    # Sangat murah untuk arsip, retrieval dalam milidetik
    transition {
      days          = 90
      storage_class = "GLACIER_IR"
    }

    # Setelah 365 hari → hapus objek otomatis
    expiration {
      days = 365
    }
  }

  # ---------------------------------------------------
  # Rule 2 — Bersihkan versi lama objek (akibat versioning)
  # Mencegah storage membengkak karena terlalu banyak versi
  # ---------------------------------------------------
  rule {
    id     = "cleanup-old-versions"
    status = "Enabled"

    filter {
      prefix = ""
    }

    # Hapus versi non-current setelah 30 hari
    noncurrent_version_expiration {
      noncurrent_days = 30
    }

    # Hapus penanda delete setelah tidak ada versi yang tersisa
    expiration {
      expired_object_delete_marker = true
    }
  }
}

# ---------------------------------------------------
# Bucket Policy — Izinkan akses hanya dari akun AWS sendiri
# Mencegah akses dari akun AWS lain
# ---------------------------------------------------
resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.main.id

  # Tunggu public access block aktif sebelum policy diterapkan
  depends_on = [aws_s3_bucket_public_access_block.main]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyExternalAccess"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.main.arn,
          "${aws_s3_bucket.main.arn}/*"
        ]
        Condition = {
          StringNotEquals = {
            "aws:PrincipalAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

# ---------------------------------------------------
# Output — Tampilkan informasi bucket setelah terraform apply
# ---------------------------------------------------
output "bucket_name" {
  value       = aws_s3_bucket.main.bucket
  description = "Nama S3 bucket"
}

output "bucket_arn" {
  value       = aws_s3_bucket.main.arn
  description = "ARN bucket — gunakan untuk IAM policy"
}

output "bucket_region" {
  value       = aws_s3_bucket.main.region
  description = "Region bucket"
}

output "bucket_domain_name" {
  value       = aws_s3_bucket.main.bucket_domain_name
  description = "Domain name bucket untuk akses via HTTPS"
}
