# budget-simple.tf
# Terraform kode untuk membuat AWS Budget — Free Tier Monitor
# Tanpa variabel — semua nilai langsung di dalam 1 file
# Mengirim notifikasi email saat penggunaan mendekati atau melampaui limit

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
# Catatan: AWS Budget bersifat global, tapi provider
# tetap butuh region untuk autentikasi
# ---------------------------------------------------
provider "aws" {
  region = "ap-southeast-1" # Singapore
}

# ---------------------------------------------------
# AWS Budget — Pantau biaya agar tidak melebihi Free Tier
# Budget limit: $0 (trigger notifikasi saat ada biaya apapun)
# ---------------------------------------------------
resource "aws_budgets_budget" "free_tier" {
  name         = "free-tier-monitor"
  budget_type  = "COST" # pantau berdasarkan biaya (bukan usage)
  limit_amount = "10"   # limit $10 sebagai batas aman
  limit_unit   = "USD"
  time_unit    = "MONTHLY" # reset setiap awal bulan

  # ---------------------------------------------------
  # Notifikasi 1 — 50% dari budget ($5)
  # Prakiraan biaya sudah setengah batas
  # ---------------------------------------------------
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 50
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"            # berdasarkan prakiraan
    subscriber_email_addresses = ["emailkamu@gmail.com"] # ganti dengan email kamu
  }

  # ---------------------------------------------------
  # Notifikasi 2 — 80% dari budget ($8)
  # Biaya aktual sudah mendekati batas
  # ---------------------------------------------------
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"                # berdasarkan biaya nyata
    subscriber_email_addresses = ["emailkamu@gmail.com"] # ganti dengan email kamu
  }

  # ---------------------------------------------------
  # Notifikasi 3 — 100% dari budget ($10)
  # Budget terlampaui — segera cek dan matikan resource
  # ---------------------------------------------------
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"                # berdasarkan biaya nyata
    subscriber_email_addresses = ["emailkamu@gmail.com"] # ganti dengan email kamu
  }

  tags = {
    Name      = "free-tier-monitor"
    ManagedBy = "terraform"
  }
}

# ---------------------------------------------------
# AWS Budget Kedua — Pantau khusus EC2
# Free tier EC2: 750 jam/bulan (t2.micro atau t3.micro)
#
# PERBAIKAN: budget_type = "USAGE" hanya mendukung dimensi:
# UsageTypeGroup, UsageType, Operation, AZ, Region,
# InstanceType, LinkedAccount, PurchaseType
# Dimensi "Service" hanya valid untuk budget_type = "COST"
# ---------------------------------------------------
resource "aws_budgets_budget" "ec2_usage" {
  name         = "ec2-free-tier-monitor"
  budget_type  = "USAGE" # pantau berdasarkan penggunaan (jam)
  limit_amount = "750"   # batas 750 jam (free tier EC2)
  limit_unit   = "Hrs"   # satuan: jam
  time_unit    = "MONTHLY"

  # Filter menggunakan UsageTypeGroup — dimensi yang valid untuk USAGE budget
  # "EC2: Running Hours" mencakup semua jam EC2 instance yang berjalan
  cost_filter {
    name   = "UsageTypeGroup"
    values = ["EC2: Running Hours"]
  }

  # Notifikasi saat penggunaan EC2 mencapai 80% (600 jam)
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = ["emailkamu@gmail.com"] # ganti dengan email kamu
  }

  # Notifikasi saat penggunaan EC2 mencapai 100% (750 jam)
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = ["emailkamu@gmail.com"] # ganti dengan email kamu
  }

  tags = {
    Name      = "ec2-free-tier-monitor"
    ManagedBy = "terraform"
  }
}

# ---------------------------------------------------
# Output — Informasi budget setelah terraform apply
# ---------------------------------------------------
output "budget_cost_id" {
  value       = aws_budgets_budget.free_tier.id
  description = "ID Budget pemantau biaya keseluruhan"
}

output "budget_ec2_id" {
  value       = aws_budgets_budget.ec2_usage.id
  description = "ID Budget pemantau penggunaan EC2"
}

output "budget_cost_limit" {
  value       = "${aws_budgets_budget.free_tier.limit_amount} ${aws_budgets_budget.free_tier.limit_unit}"
  description = "Batas budget biaya per bulan"
}

output "budget_ec2_limit" {
  value       = "${aws_budgets_budget.ec2_usage.limit_amount} ${aws_budgets_budget.ec2_usage.limit_unit} per bulan"
  description = "Batas penggunaan EC2 per bulan"
}
