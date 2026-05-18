# AWS EC2 AMI Free Tier — Panduan Owner OS

---

## Cara Kerja Free Tier untuk AMI

Free Tier EC2 berlaku pada **jenis dan ukuran instance**, bukan pada AMI itu sendiri. Artinya, AMI apapun bisa dipakai selama:

1. Instance type yang dipilih termasuk Free Tier eligible (`t2.micro` atau `t3.micro`)
2. Tidak ada biaya lisensi OS tambahan (Windows dan RHEL on-demand dikenakan biaya lisensi per jam di atas biaya instance)

> **Catatan perubahan penting:** Akun AWS yang dibuat **sebelum 15 Juli 2025** mendapat 750 jam/bulan EC2 selama 12 bulan pertama. Akun yang dibuat **setelah 15 Juli 2025** menggunakan sistem kredit hingga $200 sebagai gantinya — tidak ada lagi jatah 12-bulan otomatis untuk EC2, RDS, dan S3.

---

## Ringkasan Owner ID AMI

| OS | Publisher | Owner ID | Default SSH User |
|----|-----------|----------|-----------------|
| Amazon Linux 2 / 2023 | AWS | `amazon` | `ec2-user` |
| Ubuntu | Canonical | `099720109477` | `ubuntu` |
| Debian | Debian Project | `136693071363` | `admin` |
| Red Hat Enterprise Linux | Red Hat | `309956199498` | `ec2-user` |
| Windows Server | AWS | `amazon` | `Administrator` (RDP) |

---

## 1. Amazon Linux

OS resmi AWS, paling direkomendasikan untuk Free Tier karena tanpa biaya lisensi apapun dan sudah dioptimalkan untuk infrastruktur AWS.

- **Owner alias:** `amazon`
- **Default user:** `ec2-user`
- **Versi tersedia:** Amazon Linux 2023 (AL2023), Amazon Linux 2

### Mencari AMI Amazon Linux 2023 terbaru

```bash
aws ec2 describe-images \
  --owners amazon \
  --filters \
    "Name=name,Values=al2023-ami-2023*" \
    "Name=architecture,Values=x86_64" \
    "Name=state,Values=available" \
  --query "sort_by(Images, &CreationDate)[-1].[ImageId,Name,CreationDate]" \
  --output table
```

### Mencari AMI Amazon Linux 2 terbaru

```bash
aws ec2 describe-images \
  --owners amazon \
  --filters \
    "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" \
    "Name=state,Values=available" \
  --query "sort_by(Images, &CreationDate)[-1].[ImageId,Name,CreationDate]" \
  --output table
```

### Mencari semua AMI Free Tier eligible milik Amazon

```bash
aws ec2 describe-images \
  --owners amazon \
  --filters "Name=free-tier-eligible,Values=true" \
  --query "Images[*].[ImageId,Name,Architecture]" \
  --output table
```

---

## 2. Ubuntu — Canonical

Distribusi Linux paling populer untuk server. Owner ID resmi Canonical adalah `099720109477`. Selalu gunakan owner ID ini untuk memastikan AMI yang digunakan adalah image resmi dari Canonical, bukan image pihak ketiga.

- **Owner ID:** `099720109477`
- **Default user:** `ubuntu`
- **Versi tersedia:** Ubuntu 24.04 LTS (Noble), 22.04 LTS (Jammy), 20.04 LTS (Focal)

> **Tips verifikasi:** Jika AMI Ubuntu ditemukan melalui AWS Marketplace, `OwnerId`-nya akan tampil sebagai milik Amazon (`679593333241`). Untuk memverifikasi keasliannya, periksa field `ImageLocation` — harus mengandung `aws-marketplace/ubuntu`.

### Mencari AMI Ubuntu 24.04 LTS terbaru

```bash
aws ec2 describe-images \
  --owners 099720109477 \
  --filters \
    "Name=name,Values=ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*" \
    "Name=state,Values=available" \
  --query "sort_by(Images, &CreationDate)[-1].[ImageId,Name,CreationDate]" \
  --output table
```

### Mencari AMI Ubuntu 22.04 LTS terbaru

```bash
aws ec2 describe-images \
  --owners 099720109477 \
  --filters \
    "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*" \
    "Name=state,Values=available" \
  --query "sort_by(Images, &CreationDate)[-1].[ImageId,Name,CreationDate]" \
  --output table
```

### Mencari AMI Ubuntu 20.04 LTS terbaru

```bash
aws ec2 describe-images \
  --owners 099720109477 \
  --filters \
    "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*" \
    "Name=state,Values=available" \
  --query "sort_by(Images, &CreationDate)[-1].[ImageId,Name,CreationDate]" \
  --output table
```

### Menjalankan instance Ubuntu 24.04 secara langsung (tanpa simpan AMI ID dulu)

```bash
aws ec2 run-instances \
  --image-id "$(aws ec2 describe-images \
    --owners 099720109477 \
    --filters 'Name=name,Values=ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*' \
    --query 'sort_by(Images, &CreationDate)[-1].ImageId' \
    --output text)" \
  --instance-type t2.micro \
  --key-name nama-key-pair
```

---

## 3. Debian — Debian Project

Distribusi Linux yang stabil dan ringan. AMI resmi Debian diterbitkan oleh Debian Project dengan account ID `136693071363`.

- **Owner ID:** `136693071363`
- **Default user:** `admin`
- **Versi tersedia:** Debian 12 (Bookworm), Debian 11 (Bullseye)

### Mencari AMI Debian 12 terbaru

```bash
aws ec2 describe-images \
  --owners 136693071363 \
  --filters \
    "Name=name,Values=debian-12-amd64-*" \
    "Name=state,Values=available" \
  --query "sort_by(Images, &CreationDate)[-1].[ImageId,Name,CreationDate]" \
  --output table
```

### Mencari AMI Debian 11 terbaru

```bash
aws ec2 describe-images \
  --owners 136693071363 \
  --filters \
    "Name=name,Values=debian-11-amd64-*" \
    "Name=state,Values=available" \
  --query "sort_by(Images, &CreationDate)[-1].[ImageId,Name,CreationDate]" \
  --output table
```

### Melihat semua AMI Debian yang tersedia

```bash
aws ec2 describe-images \
  --owners 136693071363 \
  --query "sort_by(Images, &CreationDate)[*].[ImageId,Name,CreationDate]" \
  --output table
```

---

## 4. Red Hat Enterprise Linux (RHEL) — Red Hat

RHEL tersedia di AWS dengan dua model biaya:

- **On-demand (PAYG):** Biaya lisensi Red Hat sudah termasuk dalam harga instance per jam. Tersedia via Free Tier untuk akun yang memenuhi syarat.
- **Cloud Access (BYOL):** Bawa lisensi Red Hat yang sudah Anda miliki, hanya bayar biaya instance AWS.

> **Perhatian:** RHEL dengan SQL Server **tidak** termasuk dalam Free Tier.

- **Owner ID:** `309956199498`
- **Owner ID (GovCloud):** `219670896067`
- **Default user:** `ec2-user`
- **Versi tersedia:** RHEL 9, RHEL 8

### Mencari AMI RHEL 9 terbaru

```bash
aws ec2 describe-images \
  --owners 309956199498 \
  --filters \
    "Name=name,Values=RHEL-9*" \
    "Name=architecture,Values=x86_64" \
    "Name=state,Values=available" \
  --query "sort_by(Images, &CreationDate)[-1].[ImageId,Name,CreationDate]" \
  --output table
```

### Mencari AMI RHEL 8 terbaru

```bash
aws ec2 describe-images \
  --owners 309956199498 \
  --filters \
    "Name=name,Values=RHEL-8*" \
    "Name=architecture,Values=x86_64" \
    "Name=state,Values=available" \
  --query "sort_by(Images, &CreationDate)[-1].[ImageId,Name,CreationDate]" \
  --output table
```

### Menampilkan tabel lengkap semua versi RHEL 9

```bash
aws ec2 describe-images \
  --owners 309956199498 \
  --query 'sort_by(Images, &Name)[*].[CreationDate,Name,ImageId]' \
  --filters "Name=name,Values=RHEL-9*" \
  --region ap-southeast-1 \
  --output table
```

---

## 5. Windows Server

Windows Server AMI diterbitkan langsung oleh AWS dengan owner alias `amazon`. Tersedia gratis (tanpa biaya lisensi tambahan di atas Free Tier) hanya untuk akun yang memenuhi syarat Free Tier lama (dibuat sebelum 15 Juli 2025) — 750 jam Windows t2.micro/bulan.

- **Owner alias:** `amazon`
- **Default user:** `Administrator` (akses via RDP, bukan SSH)
- **Versi tersedia:** Windows Server 2022, 2019, 2016

> **Catatan:** Password `Administrator` tidak di-set saat launch. Ambil password via EC2 Console → pilih instance → **Actions → Get Windows password** menggunakan key pair yang digunakan saat launch.

### Mencari AMI Windows Server 2022 terbaru

```bash
aws ec2 describe-images \
  --owners amazon \
  --filters \
    "Name=name,Values=Windows_Server-2022-English-Full-Base-*" \
    "Name=state,Values=available" \
  --query "sort_by(Images, &CreationDate)[-1].[ImageId,Name,CreationDate]" \
  --output table
```

### Mencari AMI Windows Server 2019 terbaru

```bash
aws ec2 describe-images \
  --owners amazon \
  --filters \
    "Name=name,Values=Windows_Server-2019-English-Full-Base-*" \
    "Name=state,Values=available" \
  --query "sort_by(Images, &CreationDate)[-1].[ImageId,Name,CreationDate]" \
  --output table
```

### Mencari AMI Windows Server 2016 terbaru

```bash
aws ec2 describe-images \
  --owners amazon \
  --filters \
    "Name=name,Values=Windows_Server-2016-English-Full-Base-*" \
    "Name=state,Values=available" \
  --query "sort_by(Images, &CreationDate)[-1].[ImageId,Name,CreationDate]" \
  --output table
```

---

## Command Universal

### Menampilkan semua AMI yang ditandai Free Tier eligible

```bash
aws ec2 describe-images \
  --owners amazon \
  --filters "Name=free-tier-eligible,Values=true" \
  --query "Images[*].[ImageId,Name,Architecture,PlatformDetails]" \
  --output table
```

### Menampilkan semua instance type yang Free Tier eligible

```bash
aws ec2 describe-instance-types \
  --filters "Name=free-tier-eligible,Values=true" \
  --query "InstanceTypes[*].[InstanceType]" \
  --output text | sort
```

### Memverifikasi owner dari sebuah AMI ID

```bash
aws ec2 describe-images \
  --image-ids ami-XXXXXXXXXXXXXXXXX \
  --query "Images[*].[ImageId,OwnerId,Name]" \
  --output table
```

### Mengizinkan hanya image dari owner tertentu (fitur Allowed AMIs)

```bash
# Izinkan hanya Canonical Ubuntu
aws ec2 modify-allowed-images --image-owner 099720109477

# Izinkan hanya Amazon Linux
aws ec2 modify-allowed-images --image-owner amazon
```

---

## Tips Penting

- Selalu tambahkan `--region` sesuai region Anda karena **AMI ID bersifat unik per region**. Contoh: tambahkan `--region ap-southeast-1` untuk Singapore.
- Gunakan SSM Parameter Store untuk mendapatkan AMI ID terbaru secara programatik tanpa hardcode, contoh:
  ```bash
  aws ssm get-parameter \
    --name /aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64 \
    --query Parameter.Value \
    --output text
  ```
- Community AMI (dari pengguna lain) **tidak otomatis** masuk Free Tier. Gunakan AMI dari owner resmi di atas untuk kepastian biaya.
- Selalu gunakan filter `--state available` agar hanya AMI yang aktif dan bisa digunakan yang ditampilkan.

---

## Terraform Resource Scripts

Berikut contoh script Terraform untuk masing-masing OS. Setiap contoh menggunakan `data "aws_ami"` untuk mengambil AMI ID terbaru secara otomatis — tidak perlu hardcode AMI ID yang berbeda-beda per region.

### Struktur file yang direkomendasikan

```
project/
├── main.tf          # Resource utama (EC2, SG, dll.)
├── variables.tf     # Definisi variabel
├── outputs.tf       # Output setelah apply
├── provider.tf      # Konfigurasi AWS provider
└── terraform.tfvars # Nilai variabel (jangan di-commit ke Git)
```

---

### provider.tf (dipakai semua contoh)

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "aws" {
  region = var.aws_region
}
```

---

### variables.tf (dipakai semua contoh)

```hcl
variable "aws_region" {
  description = "AWS region yang digunakan"
  type        = string
  default     = "ap-southeast-1"
}

variable "instance_type" {
  description = "Tipe EC2 instance (gunakan t2.micro atau t3.micro untuk Free Tier)"
  type        = string
  default     = "t2.micro"
}

variable "key_pair_name" {
  description = "Nama key pair yang sudah dibuat di AWS"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR block yang diizinkan SSH ke instance"
  type        = string
  default     = "0.0.0.0/0"
}
```

---

### 1. Amazon Linux 2023

```hcl
# main.tf — Amazon Linux 2023

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_security_group" "al2023_sg" {
  name        = "al2023-sg"
  description = "Security group untuk Amazon Linux 2023"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "al2023-sg"
  }
}

resource "aws_instance" "amazon_linux_2023" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.al2023_sg.id]

  # Pasang web server sederhana saat instance pertama kali booting
  user_data = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Hello dari Amazon Linux 2023 — $(hostname -f)</h1>" > /var/www/html/index.html
  EOF

  tags = {
    Name = "amazon-linux-2023-instance"
    OS   = "AmazonLinux2023"
    Env  = "free-tier"
  }
}
```

```hcl
# outputs.tf — Amazon Linux 2023

output "instance_id" {
  description = "ID EC2 instance"
  value       = aws_instance.amazon_linux_2023.id
}

output "public_ip" {
  description = "IP publik instance"
  value       = aws_instance.amazon_linux_2023.public_ip
}

output "ami_id_used" {
  description = "AMI ID yang digunakan"
  value       = data.aws_ami.amazon_linux_2023.id
}

output "ami_name" {
  description = "Nama AMI yang digunakan"
  value       = data.aws_ami.amazon_linux_2023.name
}

output "ssh_command" {
  description = "Perintah SSH untuk masuk ke instance"
  value       = "ssh -i ${var.key_pair_name}.pem ec2-user@${aws_instance.amazon_linux_2023.public_ip}"
}
```

---

### 2. Ubuntu 24.04 LTS

```hcl
# main.tf — Ubuntu 24.04 LTS (Noble Numbat)

data "aws_ami" "ubuntu_2404" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
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

resource "aws_security_group" "ubuntu_sg" {
  name        = "ubuntu-2404-sg"
  description = "Security group untuk Ubuntu 24.04"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ubuntu-2404-sg"
  }
}

resource "aws_instance" "ubuntu_2404" {
  ami                    = data.aws_ami.ubuntu_2404.id
  instance_type          = var.instance_type
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.ubuntu_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    systemctl start nginx
    systemctl enable nginx
    echo "<h1>Hello dari Ubuntu 24.04 LTS — $(hostname -f)</h1>" > /var/www/html/index.html
  EOF

  tags = {
    Name = "ubuntu-2404-instance"
    OS   = "Ubuntu2404LTS"
    Env  = "free-tier"
  }
}
```

```hcl
# outputs.tf — Ubuntu 24.04 LTS

output "instance_id" {
  value = aws_instance.ubuntu_2404.id
}

output "public_ip" {
  value = aws_instance.ubuntu_2404.public_ip
}

output "ami_id_used" {
  value = data.aws_ami.ubuntu_2404.id
}

output "ami_name" {
  value = data.aws_ami.ubuntu_2404.name
}

output "ssh_command" {
  value = "ssh -i ${var.key_pair_name}.pem ubuntu@${aws_instance.ubuntu_2404.public_ip}"
}
```

---

### 3. Ubuntu 22.04 LTS

```hcl
# main.tf — Ubuntu 22.04 LTS (Jammy Jellyfish)

data "aws_ami" "ubuntu_2204" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
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

resource "aws_instance" "ubuntu_2204" {
  ami                    = data.aws_ami.ubuntu_2204.id
  instance_type          = var.instance_type
  key_name               = var.key_pair_name

  tags = {
    Name = "ubuntu-2204-instance"
    OS   = "Ubuntu2204LTS"
    Env  = "free-tier"
  }
}
```

---

### 4. Debian 12 (Bookworm)

```hcl
# main.tf — Debian 12 (Bookworm)

data "aws_ami" "debian_12" {
  most_recent = true
  owners      = ["136693071363"] # Debian Project

  filter {
    name   = "name"
    values = ["debian-12-amd64-*"]
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

resource "aws_security_group" "debian_sg" {
  name        = "debian-12-sg"
  description = "Security group untuk Debian 12"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "debian-12-sg"
  }
}

resource "aws_instance" "debian_12" {
  ami                    = data.aws_ami.debian_12.id
  instance_type          = var.instance_type
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.debian_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get upgrade -y
  EOF

  tags = {
    Name = "debian-12-instance"
    OS   = "Debian12Bookworm"
    Env  = "free-tier"
  }
}
```

```hcl
# outputs.tf — Debian 12

output "instance_id" {
  value = aws_instance.debian_12.id
}

output "public_ip" {
  value = aws_instance.debian_12.public_ip
}

output "ssh_command" {
  # Default user Debian di AWS adalah 'admin', bukan 'debian' atau 'root'
  value = "ssh -i ${var.key_pair_name}.pem admin@${aws_instance.debian_12.public_ip}"
}
```

---

### 5. Red Hat Enterprise Linux 9

```hcl
# main.tf — RHEL 9

data "aws_ami" "rhel_9" {
  most_recent = true
  owners      = ["309956199498"] # Red Hat

  filter {
    name   = "name"
    values = ["RHEL-9*GA*"]
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

resource "aws_security_group" "rhel_sg" {
  name        = "rhel-9-sg"
  description = "Security group untuk RHEL 9"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rhel-9-sg"
  }
}

resource "aws_instance" "rhel_9" {
  ami                    = data.aws_ami.rhel_9.id
  instance_type          = var.instance_type
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.rhel_sg.id]

  tags = {
    Name = "rhel-9-instance"
    OS   = "RHEL9"
    Env  = "free-tier"
  }
}
```

```hcl
# outputs.tf — RHEL 9

output "instance_id" {
  value = aws_instance.rhel_9.id
}

output "public_ip" {
  value = aws_instance.rhel_9.public_ip
}

output "ami_id_used" {
  value = data.aws_ami.rhel_9.id
}

output "ssh_command" {
  value = "ssh -i ${var.key_pair_name}.pem ec2-user@${aws_instance.rhel_9.public_ip}"
}
```

---

### 6. Windows Server 2022

```hcl
# main.tf — Windows Server 2022

data "aws_ami" "windows_2022" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base-*"]
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

resource "aws_security_group" "windows_sg" {
  name        = "windows-2022-sg"
  description = "Security group untuk Windows Server 2022"

  ingress {
    description = "RDP"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "WinRM HTTP"
    from_port   = 5985
    to_port     = 5985
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "windows-2022-sg"
  }
}

resource "aws_instance" "windows_2022" {
  ami                    = data.aws_ami.windows_2022.id
  instance_type          = var.instance_type
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.windows_sg.id]

  # Windows butuh lebih banyak waktu untuk booting pertama kali
  # Gunakan get_password_data = true untuk mengambil password Administrator via Terraform
  get_password_data = true

  tags = {
    Name = "windows-2022-instance"
    OS   = "WindowsServer2022"
    Env  = "free-tier"
  }
}
```

```hcl
# outputs.tf — Windows Server 2022

output "instance_id" {
  value = aws_instance.windows_2022.id
}

output "public_ip" {
  value = aws_instance.windows_2022.public_ip
}

output "ami_id_used" {
  value = data.aws_ami.windows_2022.id
}

output "administrator_password" {
  description = "Password Administrator Windows (didekripsi menggunakan key pair)"
  value       = rsadecrypt(aws_instance.windows_2022.password_data, file("${var.key_pair_name}.pem"))
  sensitive   = true
}

output "rdp_connection" {
  description = "Koneksi RDP ke Windows Server"
  value       = "Buka Remote Desktop Connection → masukkan IP: ${aws_instance.windows_2022.public_ip} → Username: Administrator"
}
```

---

### Menggunakan SSM Parameter Store (cara terbaik untuk Amazon Linux)

Cara paling andal untuk mendapatkan AMI Amazon Linux terbaru tanpa bergantung pada nama pattern yang bisa berubah:

```hcl
# main.tf — Amazon Linux via SSM Parameter Store

data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

data "aws_ssm_parameter" "al2_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_instance" "al2023_via_ssm" {
  # Ambil value dari SSM Parameter Store, bukan hardcode AMI ID
  ami           = data.aws_ssm_parameter.al2023_ami.value
  instance_type = var.instance_type
  key_name      = var.key_pair_name

  tags = {
    Name = "al2023-ssm-instance"
    OS   = "AmazonLinux2023"
  }
}
```

---

### terraform.tfvars (contoh isi file)

```hcl
aws_region       = "ap-southeast-1"
instance_type    = "t2.micro"
key_pair_name    = "my-key-pair"
allowed_ssh_cidr = "123.456.789.0/32"  # Ganti dengan IP publik Anda
```

---

### Perintah dasar menjalankan Terraform

```bash
# Inisialisasi — download provider plugin
terraform init

# Preview perubahan yang akan dilakukan
terraform plan

# Terapkan perubahan (buat/update resource)
terraform apply

# Terapkan tanpa konfirmasi manual
terraform apply -auto-approve

# Hapus semua resource yang dibuat
terraform destroy

# Lihat output setelah apply
terraform output

# Lihat nilai output yang sensitif
terraform output administrator_password
```

---

*Untuk informasi terbaru mengenai AMI dan Free Tier, kunjungi [dokumentasi resmi AWS EC2](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AMIs.html) dan [halaman AWS Free Tier](https://aws.amazon.com/free/).*