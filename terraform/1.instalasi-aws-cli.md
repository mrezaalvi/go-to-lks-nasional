# Panduan Setup AWS CLI: Instalasi hingga Konfigurasi

Dokumen ini menjelaskan langkah-langkah untuk menginstal AWS CLI, mendapatkan kredensial akses, dan menghubungkannya dengan komputer lokal Anda.

## 1. Instalasi AWS CLI

### Windows
1. Unduh penginstal MSI resmi: [AWSCLIV2.msi](https://awscli.amazonaws.com/AWSCLIV2.msi).
2. Jalankan file tersebut dan ikuti instruksi pada wizard hingga selesai.
3. Verifikasi dengan membuka Command Prompt/PowerShell:
   ```bash
   aws --version
   ```
### macOS
1. Gunakan Terminal untuk mengunduh dan menginstal:
    ```bash
    curl "[https://awscli.amazonaws.com/AWSCLIV2.pkg](https://awscli.amazonaws.com/AWSCLIV2.pkg)" -o "AWSCLIV2.pkg"
    ```
    ```bash
    sudo installer -pkg AWSCLIV2.pkg -target /
    ```
2. Verifikasi: 
   ```bash 
   aws --version
   ```
### Linux (x86_64)
1. Unduh dan ekstrak file instalasi:

    ```bash
    curl "[https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip](https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip)" -o "awscliv2.zip"
    ```
    ```bash
    unzip awscliv2.zip
    ```
    ```bash
    sudo ./aws/install
    ```    
2. Verifikasi: 
   ```bash
      aws --version
   ```

## 2. Membuat Access Key di Konsol AWS
Sebelum konfigurasi, Anda memerlukan kredensial dari layanan **IAM**:

1. Login ke **AWS Management Console** dan buka layanan **IAM**.

2. Klik menu **Users** di sisi kiri, lalu pilih nama User Anda.

3. Buka tab **Security credentials**.

4. Gulir ke bawah ke bagian **Access keys** dan klik **Create access key**.

5. Pilih opsi **Command Line Interface (CLI)** dan setujui konfirmasi keamanan.

6. Klik **Create access key**.

7. **PENTING**: Klik Download .csv file untuk menyimpan *Access Key ID* dan *Secret Access Key*.

Catatan: *Anda tidak akan bisa melihat Secret Access Key lagi setelah jendela ini ditutup*.

## 3. Menjalankan Konfigurasi AWS CLI
Setelah memiliki kredensial, hubungkan CLI dengan akun Anda:
1. Buka Terminal atau Command Prompt.

2. Jalankan perintah:
   ```bash
   aws configure
   ```
3. Masukkan data berikut saat diminta:
    - **AWS Access Key ID**: Masukkan ID dari file CSV.
    - **AWS Secret Access Key**: Masukkan Secret Key dari file CSV.

    - **Default region name**: Contoh: `ap-southeast-1` (Singapura).

    - **Default output format**: Ketik `json`.

## 4. Verifikasi Akhir
Jalankan perintah berikut untuk memastikan koneksi berhasil:

```bash
# Mengecek identitas user yang aktif
aws sts get-caller-identity

# Mencoba melihat daftar S3 bucket
aws s3 ls
```

**Peringatan Keamanan:**
Jangan pernah membagikan file `credentials` atau mengunggahnya ke repositori publik. Selalu gunakan prinsip *Least Privilege* pada User IAM Anda.
