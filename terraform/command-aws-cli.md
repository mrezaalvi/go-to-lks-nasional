# Perintah-perintah `aws-cli` yang sering digunakan.

Berikut adalah perintah-perintah atau command pada `aws-cli` yang sering digunakan:

## 1. General

  a. `aws configure`

  Mengatur kredensial AWS (Access Key, Secret Key, region, dan output format). Wajib dilakukan sebelum menggunakan layanan lainnya.

  ```bash
  aws configure
  ```

  b. `aws configure list` 
    
  Menampilkan daftar konfigurasi aktif yang sedang digunakan, termasuk sumber kredensial (env var, file, dsb.).

  ```bash
  aws configure list
  ```

  c. `aws configure list-profiles`

  Menampilkan semua profil AWS CLI yang tersedia di mesin lokal.

  ```bash
  aws configure list-profiles
  ```

  d. `aws sts get-caller-identity`

  Mengecek identitas akun AWS yang sedang digunakan — menampilkan Account ID, User ID, dan ARN.

  ```bash
  aws sts get-caller-identity
  ```

  e. `aws --version`

  Menampilkan versi AWS CLI yang terinstal.

  ```bash
  aws --version
  ```
  
## 2. EC2
    
  a. `aws ec2 describe-instances`

  Menampilkan daftar semua EC2 instance beserta detail seperti state, type, IP, dan tag.
  
  ```bash 
  aws ec2 describe-instances
  ```

  b. `aws ec2 start-instances --instance-ids i-XXXXX`

  Menjalankan (start) EC2 instance yang sedang dalam keadaan stopped.

  ```bash
  aws ec2 start-instances --instance-ids i-XXXXX
  ```

  c. `aws ec2 stop-instances --instance-ids i-XXXXX`

  Menghentikan (stop) EC2 instance yang sedang berjalan tanpa menghapusnya.

  ```bash
  aws ec2 stop-instances --instance-ids i-XXXXX
  ```

  d. `aws ec2 reboot-instances --instance-ids i-XXXXX`

  Mereboot EC2 instance — berguna saat instance hang atau perlu refresh.

  ```bash
  aws ec2 reboot-instances --instance-ids i-XXXXX
  ```
  
  e. `aws ec2 terminate-instances --instance-ids i-XXXXX`

  Menghapus (terminate) EC2 instance secara permanen. Data non-EBS akan hilang.

  ```bash
  aws ec2 terminate-instances --instance-ids i-XXXXX
  ```

  f. `aws ec2 describe-security-groups`

  Menampilkan semua security group beserta aturan inbound/outbound di akun.

  ```bash
  aws ec2 describe-security-groups
  ```

  g. `aws ec2 describe-key-pairs`

  Menampilkan semua key pair yang tersedia untuk login ke EC2 instance via SSH.

  ```bash
  aws ec2 describe-key-pairs
  ```

## 3. S3

  a. `aws s3 ls`
  
  Menampilkan semua S3 bucket yang ada di akun AWS Anda.

  ```bash
  aws s3 ls
  ```

  b. `aws s3 ls s3://nama-bucket/`

  Menampilkan daftar file dan folder di dalam S3 bucket atau prefix tertentu.

  ```bash
  aws s3 ls s3://nama-bucket/
  ```

  c. `aws s3 cp file.txt s3://nama-bucket/`

  Mengupload file lokal ke S3 bucket. Bisa sebaliknya untuk download.

  ```bash
  aws s3 cp file.txt s3://nama-bucket/
  ```

  d. `aws s3 sync ./folder s3://nama-bucket/folder/`

  Mensinkronkan seluruh folder lokal ke S3 — hanya file yang berubah yang diupload.

  ```bash
  aws s3 sync ./folder s3://nama-bucket/folder/
  ```

  e. `Menghapus file tertentu dari S3 bucket.`

  Menghapus file tertentu dari S3 bucket.

  ```bash
  aws s3 rm s3://nama-bucket/file.txt
  ```
  
  f. `aws s3 mb s3://nama-bucket-baru`

  Membuat (make bucket) S3 bucket baru.

  ```bash
  aws s3 mb s3://nama-bucket-baru
  ```

  g. `aws s3 rb s3://nama-bucket --force`

  Menghapus S3 bucket beserta seluruh isinya secara paksa.

  ```bash
  aws s3 rb s3://nama-bucket --force
  ```

## 4. IAM

  a. `aws iam list-users`

  Menghapus S3 bucket beserta seluruh isinya secara paksa.

  ```bash
  aws iam list-users
  ```

  b. `aws iam list-roles`

  Menampilkan semua IAM role yang tersedia di akun.

  ```bash
  aws iam list-roles
  ```

  c. `aws iam get-user --user-name namauser`

  Menampilkan detail informasi IAM user tertentu.

  ```bash
  aws iam get-user --user-name namauser
  ```

  d. `aws iam create-user --user-name namauser`

  Membuat IAM user baru dengan nama yang ditentukan.

  ```bash
  aws iam create-user --user-name namauser
  ```


  e. `aws iam attach-user-policy --user-name namauser --policy-arn arn:aws:iam::...`

  Melampirkan policy (izin) ke IAM user tertentu.

  ```bash
  aws iam attach-user-policy --user-name namauser --policy-arn arn:aws:iam::...
  ```


  
  f. `aws iam list-attached-user-policies --user-name namauser`

  Menampilkan daftar policy yang sudah dilampirkan ke IAM user.

  ```bash
  aws iam list-attached-user-policies --user-name namauser
  ```

## 5. RDS

  a. `aws rds describe-db-instances`

  Menampilkan semua RDS database instance beserta status, engine, dan endpoint-nya.

  ```bash
  aws rds describe-db-instances
  ```

  b. `aws rds start-db-instance --db-instance-identifier nama-db`

  Menghidupkan RDS instance yang dalam kondisi stopped.

  ```bash
  aws rds start-db-instance --db-instance-identifier nama-db
  ```

  c. `aws rds stop-db-instance --db-instance-identifier nama-db`

  Menghentikan RDS instance untuk menghemat biaya saat tidak digunakan.

  ```bash
  aws rds stop-db-instance --db-instance-identifier nama-db
  ```

  d. `aws rds create-db-snapshot --db-instance-identifier nama-db --db-snapshot-identifier snapshot-id`

  Membuat snapshot (backup) manual dari RDS instance.

  ```bash
  aws rds create-db-snapshot --db-instance-identifier nama-db --db-snapshot-identifier snapshot-id
  ```

## 6. Lamda

  a. `aws lambda list-functions`

  Menampilkan semua Lambda function yang ada beserta runtime dan konfigurasinya.

  ```bash
  aws lambda list-functions
  ```

  b. `aws lambda invoke --function-name namaFungsi output.json`

  Memanggil (invoke) Lambda function secara manual dan menyimpan output ke file.

  ```bash
  aws lambda invoke --function-name namaFungsi output.json
  ```

  
  c. `aws lambda get-function --function-name namaFungsi`

  Menampilkan detail konfigurasi Lambda function termasuk environment variable dan layer.

  ```bash
  aws lambda get-function --function-name namaFungsi
  ```

  
  d. `aws lambda update-function-code --function-name namaFungsi --zip-file fileb://kode.zip`

  Memperbarui kode Lambda function dari file ZIP lokal.

  ```bash
  aws lambda update-function-code --function-name namaFungsi --zip-file fileb://kode.zip
  ```

## 7. EKS

  a. `aws eks list-clusters`

  Menampilkan semua EKS (Kubernetes) cluster yang ada di akun.

  ```bash
  aws eks list-clusters
  ```

  b. `aws eks describe-cluster --name nama-cluster`

  Menampilkan detail cluster EKS termasuk versi Kubernetes, status, dan endpoint.

  ```bash
  aws eks describe-cluster --name nama-cluster
  ```

  c. `aws eks update-kubeconfig --name nama-cluster --region ap-southeast-1`

  Menambahkan konfigurasi kubectl agar bisa terhubung ke EKS cluster dari lokal.

  ```bash
  aws eks update-kubeconfig --name nama-cluster --region ap-southeast-1
  ```

## 8. CloudFormation

  a. `aws cloudformation list-stacks`

  Menampilkan semua CloudFormation stack beserta statusnya (CREATE_COMPLETE, dll.).

  ```bash
  aws cloudformation list-stacks
  ```

  b. `aws cloudformation describe-stacks --stack-name nama-stack`

  Menampilkan detail stack CloudFormation termasuk output dan parameter.

  ```bash
  aws cloudformation describe-stacks --stack-name nama-stack
  ```

  c. `aws cloudformation deploy --template-file template.yaml --stack-name nama-stack`

  Men-deploy atau memperbarui CloudFormation stack dari template YAML/JSON.

  ```bash
  aws cloudformation deploy --template-file template.yaml --stack-name nama-stack
  ```

  d. `aws cloudformation delete-stack --stack-name nama-stack`

  aws cloudformation delete-stack --stack-name nama-stack

  ```bash
  aws cloudformation delete-stack --stack-name nama-stack
  ```

Di atas adalah cheatsheet interaktif AWS CLI dengan 38+ perintah yang dikelompokkan ke dalam 7 kategori layanan. Anda bisa:

Filter berdasarkan layanan (EC2, S3, IAM, RDS, Lambda, EKS, CloudFormation)
Cari perintah atau kata kunci tertentu
Salin perintah langsung dengan klik ikon copy

---

Beberapa tips tambahan yang berguna saat memakai AWS CLI:
Format output — Tambahkan --output json|table|text di akhir command untuk mengubah format tampilan. Contoh aws ec2 describe-instances --output table lebih mudah dibaca.
Filter query — Gunakan --query untuk menyaring output spesifik. Contoh: aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name]'
Multi-profil — Jika punya banyak akun AWS, tambahkan --profile nama-profil di setiap command untuk memilih akun yang digunakan.
Region — Tambahkan --region ap-southeast-1 untuk menentukan region tanpa mengubah konfigurasi global (berguna untuk Terraform & Docker workflow seperti yang sedang Anda kerjakan).