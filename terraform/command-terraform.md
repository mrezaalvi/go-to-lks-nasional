# Perintah dasar terraform engine

alur kerja (workflow) yang sering dilakukan pada `terraform` adalah:

init $\rightarrow$ fmt $\rightarrow$ validate $\rightarrow$ plan $\rightarrow$ apply

## 1. `terraform fmt` (Format)

Perintah ini fungsinya seperti **merapikan tulisan**. Jika kode kamu berantakan (spasi tidak rata atau baris tidak rapi), `fmt` akan otomatis memperbaikinya sesuai standar Terraform agar lebih mudah dibaca oleh manusia.
- **Analogi**: Merapikan dokumen laporan agar margin dan font-nya seragam.
```bash
terraform fmt
```
## 2. `terraform init` (Initialize)
Ini adalah perintah **pertama** yang harus dijalankan. Terraform akan menyiapkan lingkungan kerja, mengunduh "plugin" (disebut *providers*) yang dibutuhkan untuk terhubung ke cloud (seperti AWS, Azure, atau Google Cloud).
- **Analogi**: Menyiapkan meja kerja dan membeli alat-alat pertukangan sebelum mulai membangun.

```bash
terraform init
```

## 3. `terraform validate` (Validasi)
Perintah ini digunakan untuk **mengecek kesalahan tulis**. Ia akan memeriksa apakah sintaks atau struktur kode kamu sudah benar secara teknis sebelum benar-benar dijalankan.

**Analogi**: Mengecek apakah ada kata yang salah eja atau instruksi yang tidak logis dalam buku panduan sebelum diberikan ke tukang bangunan.

```bash
terraform validate
```

## 4. `terraform plan` (Perencanaan)
Ini adalah tahap **pratinjau**. Terraform akan membandingkan kode kamu dengan kondisi infrastruktur yang sudah ada, lalu menunjukkan apa saja yang akan ditambah, diubah, atau dihapus. Perintah ini **belum** mengubah apapun di cloud.

**Analogi**: Arsitek menunjukkan maket atau cetak biru bangunan kepada kamu untuk mendapatkan persetujuan sebelum semen pertama dituang.

```bash
terraform plan
```

## 5. `terraform apply` (Eksekusi)
Ini adalah perintah **paling utama**. Terraform akan benar-benar membangun atau mengubah infrastruktur di cloud sesuai dengan apa yang ada di kode kamu.

**Analogi**: Tukang mulai membangun rumah sesuai dengan cetak biru yang sudah disetujui.

```bash
terraform apply
```

## 6. `terraform destroy` (Penghancuran)
Perintah ini digunakan untuk **menghapus semua infrastruktur** yang telah dibuat oleh kode Terraform tersebut. Hati-hati, karena semua yang sudah dibangun akan hilang total.

**Analogi**: Membongkar kembali seluruh bangunan dan membersihkan lahan hingga kosong seperti semula.
```bash
terraform destroy
```

