# AWS Services — Panduan Lengkap

---

## Compute

### 1. EC2 (Elastic Compute Cloud)
Server virtual (instance) di cloud. Anda bisa memilih jenis CPU, RAM, OS, dan region sesuai kebutuhan. Cocok untuk menjalankan aplikasi web, API, atau backend apapun — konsepnya seperti VPS, tapi di infrastruktur AWS yang sangat scalable.

**Fitur utama:** On-demand, Spot Instance, Reserved Instance, berbagai tipe instance (t3, m5, c5, dll.)

---

### 2. Elastic Load Balancing (ELB)
Mendistribusikan traffic masuk secara otomatis ke beberapa server (EC2, Lambda, container) agar tidak ada satu server yang kelebihan beban.

Tiga jenis Load Balancer:
- **ALB (Application Load Balancer)** — untuk HTTP/HTTPS, routing berbasis path/host
- **NLB (Network Load Balancer)** — untuk TCP/UDP, latensi sangat rendah
- **Classic Load Balancer** — generasi lama, tidak direkomendasikan untuk proyek baru

---

### 3. Auto Scaling
Menambah atau mengurangi jumlah EC2 instance secara otomatis berdasarkan kondisi tertentu seperti penggunaan CPU, jumlah request, atau jadwal. Aplikasi tetap responsif saat lonjakan traffic dan hemat biaya saat sepi.

**Cara kerja:** Tentukan jumlah minimum, maksimum, dan desired instance — AWS akan menyesuaikan secara otomatis berdasarkan CloudWatch metrics.

---

### 4. Network and Security (EC2)
Lapisan keamanan jaringan di lingkungan EC2, mencakup:
- **Security Group** — firewall di level instance, atur inbound/outbound traffic
- **Network ACL (NACL)** — firewall di level subnet
- **Key Pair** — autentikasi SSH ke instance
- **Elastic IP** — IP publik statis yang bisa ditetapkan ke instance

---

### 5. Elastic Beanstalk
Platform-as-a-Service (PaaS) dari AWS. Cukup upload kode (Node.js, PHP, Python, Java, Ruby, Go, dll.) dan Beanstalk otomatis menyiapkan EC2, Load Balancer, Auto Scaling, dan monitoring. Cocok untuk developer yang tidak ingin mengelola infrastruktur secara manual.

**Kapan pakai:** Saat ingin deploy cepat tanpa konfigurasi infrastruktur yang rumit.

---

### 6. Lambda
Serverless computing — jalankan fungsi/kode tanpa perlu menyediakan atau mengelola server. Anda hanya membayar per eksekusi (bukan per jam server berjalan).

**Ideal untuk:**
- Event-driven tasks (resize gambar saat upload ke S3)
- Proses webhook dari layanan eksternal
- Backend API ringan via API Gateway
- Trigger terjadwal (cron job di cloud)

---

## Containers

### 1. Elastic Container Registry (ECR)
Registry Docker image privat milik AWS. Tempat menyimpan, mengelola, dan men-deploy container image. Terintegrasi langsung dengan ECS dan EKS sehingga proses pull image lebih cepat karena berada dalam jaringan AWS. Mendukung image scanning untuk deteksi vulnerability.

---

### 2. Elastic Container Service (ECS)
Layanan orkestrasi container dari AWS. Menjalankan container Docker di cluster EC2 atau secara serverless menggunakan **Fargate** (tidak perlu manage EC2 sama sekali). Lebih sederhana dibanding Kubernetes — cocok jika tim ingin menggunakan container tanpa kompleksitas K8s.

**Konsep kunci:** Task Definition (konfigurasi container), Service (jumlah task yang berjalan), Cluster (kumpulan resource).

---

### 3. Elastic Kubernetes Service (EKS)
Kubernetes terkelola di AWS. AWS mengelola control plane K8s (master node), Anda hanya fokus ke worker node dan deployment aplikasi. Ideal untuk tim yang sudah familiar dengan Kubernetes dan membutuhkan ekosistem penuh (Helm, kubectl, Custom Resource Definition, dll.).

**ECS vs EKS:** Pilih ECS untuk kesederhanaan, pilih EKS jika tim sudah pakai Kubernetes atau butuh portabilitas.

---

## Storage

### 1. S3 (Simple Storage Service)
Object storage yang sangat scalable untuk menyimpan file apapun: gambar, video, backup, static website, log, dataset. Kapasitas tidak terbatas, harga per GB, dan mendukung:
- **Versioning** — simpan riwayat perubahan file
- **Lifecycle Policy** — otomatis pindahkan/hapus file berdasarkan umur
- **Static Website Hosting** — host website HTML/CSS/JS tanpa server
- **Access Control** — bucket policy, ACL, dan pre-signed URL

---

### 2. EFS (Elastic File System)
File system jaringan (NFS) yang bisa di-mount ke banyak EC2 instance sekaligus secara bersamaan. Berguna untuk aplikasi yang perlu shared storage antar instance, seperti CMS (WordPress multi-server), shared uploads, atau home directory pengguna.

**Perbedaan dengan S3:** EFS adalah file system (bisa mount seperti hard disk), S3 adalah object storage (akses via API/URL).

---

### 3. S3 Glacier
Penyimpanan arsip berbiaya sangat rendah untuk data yang jarang diakses. Ada tiga tier berdasarkan kecepatan retrieval:

| Tier | Waktu Retrieval | Biaya |
|------|----------------|-------|
| Instant Retrieval | Milidetik | Lebih mahal |
| Flexible Retrieval | Menit hingga jam | Menengah |
| Deep Archive | Hingga 12 jam | Paling murah |

**Cocok untuk:** Backup jangka panjang, arsip data compliance, log historis.

---

### 4. AWS Backup
Layanan terpusat untuk mengotomatiskan backup lintas layanan AWS: EC2, RDS, DynamoDB, EFS, S3, FSx, dan lainnya. Atur jadwal, retensi, dan vault backup dari satu konsol. Mendukung backup cross-region dan cross-account untuk disaster recovery.

---

### 5. Amazon FSx
File system terkelola berperforma tinggi, tersedia dalam dua varian utama:
- **FSx for Windows File Server** — SMB/NTFS untuk aplikasi Windows, Active Directory integration
- **FSx for Lustre** — throughput sangat tinggi untuk HPC, ML training, dan big data processing

---

## Application Integration

### 1. SNS (Simple Notification Service)
Layanan pub/sub messaging untuk mengirim notifikasi ke banyak subscriber sekaligus: email, SMS, HTTP endpoint, SQS, Lambda, dan lainnya. Satu pesan bisa dikirim ke ribuan penerima dalam hitungan detik (fan-out pattern).

**Contoh penggunaan:** Notifikasi deployment selesai, alert monitoring, pengiriman OTP via SMS.

---

### 2. SQS (Simple Queue Service)
Antrian pesan (message queue) terkelola untuk decoupling komponen aplikasi. Producer menaruh pesan ke queue, consumer memprosesnya secara asinkron. Mencegah data hilang jika consumer sedang down.

Dua jenis queue:
- **Standard Queue** — throughput sangat tinggi, urutan tidak dijamin
- **FIFO Queue** — urutan pesan dijamin (First-In-First-Out), throughput lebih terbatas

---

### 3. Amazon EventBridge
Event bus serverless untuk menghubungkan aplikasi dengan event dari AWS services, SaaS pihak ketiga (Salesforce, Zendesk, dll.), atau aplikasi Anda sendiri. Atur aturan routing event ke target seperti Lambda, SQS, Step Functions, dan lainnya.

**Perbedaan dengan SNS:** EventBridge lebih cocok untuk routing event kompleks berbasis konten, SNS lebih cocok untuk broadcast sederhana.

---

### 4. Step Functions
Orkestrasi alur kerja (workflow) dengan tampilan visual state machine. Koordinasikan beberapa Lambda, layanan AWS, atau kode menjadi satu proses berurutan atau paralel lengkap dengan penanganan error, retry, dan timeout otomatis.

**Contoh penggunaan:** Proses onboarding pengguna multi-step, pipeline ETL, workflow persetujuan dokumen.

---

## Analytics

### 1. Athena
Query SQL langsung ke data mentah di S3 tanpa perlu load ke database terlebih dahulu. Berbasis Apache Presto, serverless, dan bayar per query (per TB data yang di-scan). Cocok untuk analisis log, data lake query, atau laporan dari data S3.

**Tips:** Gunakan format Parquet/ORC dan partisi data untuk mengurangi biaya scan.

---

### 2. Kinesis
Platform streaming data real-time dari AWS, terdiri dari beberapa komponen:
- **Kinesis Data Streams** — ingest dan buffer data streaming
- **Kinesis Data Firehose** — deliver data ke S3, Redshift, OpenSearch tanpa kode
- **Kinesis Data Analytics** — proses dan query stream secara real-time dengan SQL

**Ideal untuk:** Log aplikasi, data IoT, clickstream analytics, monitoring real-time.

---

### 3. AWS Glue
Layanan ETL (Extract, Transform, Load) serverless. Crawl berbagai sumber data untuk membuat katalog metadata otomatis, lalu transformasi data menggunakan Apache Spark tanpa perlu manage server. Integrasikan data dari S3, RDS, Redshift ke data lake.

**Komponen utama:** Glue Crawler, Glue Data Catalog, Glue ETL Jobs.

---

### 4. Amazon OpenSearch Service
Layanan pencarian dan analitik berbasis OpenSearch (fork open-source dari Elasticsearch). Digunakan untuk:
- Full-text search pada aplikasi
- Analisis log (pengganti ELK stack self-hosted)
- Monitoring metrik dan visualisasi via OpenSearch Dashboards (Kibana)

---

### 5. Amazon Redshift
Data warehouse cloud untuk analitik skala petabyte. Jalankan query SQL kompleks pada data sangat besar dengan cepat menggunakan columnar storage dan massively parallel processing (MPP). Terintegrasi dengan BI tools seperti Tableau, Looker, dan QuickSight.

**Redshift Spectrum** memungkinkan query langsung ke data di S3 tanpa harus load ke Redshift.

---

## AWS Cost Management

### 1. AWS Budgets
Monitor dan kontrol pengeluaran AWS. Buat anggaran berdasarkan biaya, penggunaan, atau Reserved Instance coverage. Dapatkan alert via email atau SNS saat pengeluaran mendekati atau melampaui batas yang ditentukan. Fitur wajib untuk menghindari tagihan yang mengejutkan.

**Tipe budget:** Cost Budget, Usage Budget, Reservation Budget, Savings Plans Budget.

---

## Database

### 1. RDS (Relational Database Service)
Database relasional terkelola yang mendukung: MySQL, PostgreSQL, MariaDB, Oracle, SQL Server, dan Aurora. AWS menangani patching, backup otomatis, failover, dan scaling — Anda fokus ke query dan schema, bukan administrasi server database.

**Multi-AZ:** Replikasi otomatis ke availability zone lain untuk high availability dan failover otomatis.

---

### 2. DynamoDB
Database NoSQL serverless berperforma sangat tinggi (single-digit millisecond latency). Sangat scalable untuk key-value dan document data. Tidak perlu provision server atau manage capacity (mode on-demand tersedia).

**Cocok untuk:** Session store, leaderboard game, shopping cart, data IoT, katalog produk.
**DAX (DynamoDB Accelerator):** In-memory cache untuk DynamoDB, latensi microsecond.

---

### 3. DocumentDB
Database document yang kompatibel dengan MongoDB API. Cocok untuk aplikasi yang sudah menggunakan MongoDB dan ingin bermigrasi ke cloud terkelola. Menyimpan data dalam format JSON, mendukung rich query dan aggregation pipeline.

**Catatan:** DocumentDB kompatibel dengan MongoDB 3.6, 4.0, dan 5.0 API.

---

### 4. ElastiCache
In-memory caching terkelola untuk **Redis** atau **Memcached**. Digunakan sebagai cache lapisan antara aplikasi dan database untuk mempercepat read yang sering dilakukan dan mengurangi beban database.

**Kasus penggunaan:**
- Cache hasil query database
- Session storage untuk aplikasi web
- Pub/Sub messaging (Redis)
- Rate limiting dan leaderboard (Redis Sorted Sets)

---

### 5. Redshift (Database)
Lihat penjelasan di bagian [Analytics — Amazon Redshift](#5-amazon-redshift). Redshift berperan sebagai data warehouse — diakses via SQL standar, cocok untuk workload OLAP (analitik), bukan OLTP (transaksi). Pisahkan workload analitik berat dari database transaksional (RDS/Aurora).

---

## Networking & Content Delivery

### 1. VPC (Virtual Private Cloud)
Jaringan virtual privat terisolasi di AWS — fondasi dari semua resource AWS Anda. Di sini Anda mengatur:
- **Subnet** — public (akses internet) dan private (terisolasi)
- **Internet Gateway** — koneksi VPC ke internet publik
- **NAT Gateway** — izinkan subnet private akses internet tanpa terekspos langsung
- **Route Table** — atur kemana traffic diarahkan
- **VPC Peering** — hubungkan dua VPC berbeda

---

### 2. CloudFront
CDN (Content Delivery Network) global dari AWS dengan 400+ edge location di seluruh dunia. Distribusikan konten statis (dari S3) dan dinamis (dari EC2/ALB) ke pengguna dengan latensi sangat rendah karena dilayani dari server terdekat.

**Terintegrasi dengan:** WAF (firewall aplikasi web), Shield (DDoS protection), ACM (HTTPS gratis).

---

### 3. API Gateway
Buat, publish, dan kelola REST API, HTTP API, dan WebSocket API di skala apapun. Sering digunakan sebagai "front door" untuk Lambda (serverless API) atau backend EC2/container.

**Fitur utama:**
- Throttling dan rate limiting
- Autentikasi via Cognito, IAM, atau Lambda Authorizer
- Response caching
- Stage management (dev, staging, production)

---

### 4. Route 53
Layanan DNS (Domain Name System) terkelola dan highly available dari AWS. Daftarkan domain baru, atau transfer domain yang sudah ada, lalu arahkan ke resource AWS atau luar.

**Routing policy yang tersedia:**
- **Simple** — satu target
- **Weighted** — distribusi traffic berdasarkan bobot (A/B testing)
- **Latency-based** — arahkan ke region dengan latensi terkecil
- **Failover** — otomatis switch ke backup jika primary down
- **Geolocation** — arahkan berdasarkan lokasi pengguna

---

### 5. Content Delivery Network (CDN)
Di AWS, CDN diimplementasikan melalui **CloudFront**. Aset statis (gambar, CSS, JS, video) di-cache di edge server terdekat pengguna di seluruh dunia sehingga load time lebih cepat dan beban ke origin server berkurang secara signifikan.

**Alur kerja CDN:** Pengguna request → Edge location terdekat (jika cache hit, langsung kirim) → Jika cache miss, fetch dari origin (S3/EC2) → Cache di edge → Kirim ke pengguna.

---

## Security, Identity & Compliance

### 1. IAM (Identity and Access Management)
Kontrol akses terpusat AWS. Buat user, group, dan role dengan policy yang mendefinisikan siapa boleh melakukan apa terhadap resource mana. Prinsip utama: **least privilege** — berikan izin sesedikit mungkin yang diperlukan.

**Komponen utama:**
- **User** — identitas untuk orang atau aplikasi
- **Group** — kumpulan user dengan policy yang sama
- **Role** — identitas sementara yang di-assume oleh service atau user
- **Policy** — dokumen JSON yang mendefinisikan izin

---

### 2. Secrets Manager
Simpan dan rotasi otomatis secret seperti password database, API key, dan credential pihak ketiga. Aplikasi mengambil secret via API saat runtime — tidak perlu hardcode di kode sumber atau environment file yang bisa bocor.

**Rotasi otomatis didukung untuk:** RDS, Redshift, DocumentDB, dan secret kustom via Lambda.

---

### 3. Certificate Manager (ACM)
Provisioning, manajemen, dan deployment sertifikat SSL/TLS secara **gratis** untuk layanan AWS (CloudFront, ALB, API Gateway). Sertifikat diperbarui otomatis sebelum kadaluarsa — tidak perlu renewal manual seperti Let's Encrypt self-hosted.

**Catatan:** Sertifikat ACM hanya bisa digunakan di layanan AWS, tidak bisa di-download untuk server sendiri.

---

### 4. KMS (Key Management Service)
Buat dan kelola kunci enkripsi (Customer Master Key) untuk mengamankan data di AWS. Terintegrasi dengan hampir semua layanan AWS: S3, RDS, EBS, Lambda, Secrets Manager, dan lainnya.

**Fitur utama:**
- Enkripsi envelope (data key dienkripsi oleh master key)
- Rotasi kunci otomatis tahunan
- Audit lengkap via CloudTrail
- Compliance: FIPS 140-2, PCI DSS, HIPAA

---

## Management & Governance

### 1. CloudWatch
Layanan monitoring dan observability terpusat di AWS. CloudWatch mengumpulkan metrik, log, dan event dari hampir semua layanan AWS maupun aplikasi Anda sendiri, lalu memungkinkan visualisasi, alerting, dan tindakan otomatis berdasarkan kondisi tertentu.

**Komponen utama:**
- **Metrics** — data numerik dari layanan AWS (CPU usage, request count, error rate, dll.)
- **Logs** — kumpulkan dan simpan log dari EC2, Lambda, ECS, dan aplikasi kustom
- **Alarms** — trigger notifikasi (SNS) atau aksi otomatis (Auto Scaling) saat metrik melewati threshold
- **Dashboards** — visualisasi metrik dalam satu tampilan terpusat
- **Events / EventBridge** — deteksi perubahan state resource dan trigger aksi otomatis

**Contoh penggunaan:** Alert saat CPU EC2 di atas 80%, monitor error rate Lambda, visualisasi request per detik di ALB.

---

### 2. AWS Auto Scaling
Layanan yang mengelola scaling otomatis secara terpusat untuk berbagai resource AWS — bukan hanya EC2, tapi juga ECS tasks, DynamoDB tables, Aurora replicas, dan Spot Fleet. Merupakan lapisan orkestrasi di atas mekanisme scaling masing-masing layanan.

**Perbedaan dengan EC2 Auto Scaling:** EC2 Auto Scaling hanya untuk instance EC2, sedangkan AWS Auto Scaling adalah antarmuka terpadu untuk scaling berbagai jenis resource sekaligus dalam satu kebijakan.

**Scaling plan:** Atur target tracking (misalnya jaga CPU di 60%), pilih prioritas antara availability vs biaya, dan terapkan ke seluruh stack aplikasi.

---

### 3. CloudFormation
Layanan Infrastructure-as-Code (IaC) dari AWS. Definisikan seluruh infrastruktur (EC2, RDS, VPC, IAM, dll.) dalam satu file template berformat YAML atau JSON, lalu CloudFormation akan membuat, memperbarui, atau menghapus resource tersebut secara otomatis dan konsisten.

**Konsep kunci:**
- **Template** — file YAML/JSON yang mendefinisikan resource yang diinginkan
- **Stack** — sekumpulan resource yang dibuat dari satu template
- **Change Set** — preview perubahan sebelum diterapkan ke stack yang sudah ada
- **Drift Detection** — deteksi jika resource berubah di luar CloudFormation

**Kapan pakai vs Terraform:** CloudFormation adalah solusi native AWS (tanpa instalasi tambahan), sementara Terraform mendukung multi-cloud. Keduanya sama-sama IaC yang valid.

---

### 4. OpsWorks
Layanan manajemen konfigurasi berbasis Chef dan Puppet. Membantu otomatisasi konfigurasi server, deployment aplikasi, dan manajemen infrastruktur menggunakan "recipe" (Chef) atau "manifest" (Puppet). Tersedia dalam tiga mode:

- **OpsWorks for Chef Automate** — Chef server terkelola penuh
- **OpsWorks for Puppet Enterprise** — Puppet master terkelola penuh
- **OpsWorks Stacks** — model berbasis layer untuk mendefinisikan stack aplikasi

**Catatan:** OpsWorks lebih cocok untuk tim yang sudah investasi di ekosistem Chef/Puppet. Tim baru umumnya lebih memilih Systems Manager atau Ansible untuk manajemen konfigurasi.

---

### 5. Service Catalog
Memungkinkan organisasi membuat dan mengelola katalog layanan IT yang disetujui untuk digunakan oleh tim internal. Admin IT mendefinisikan "produk" (kumpulan resource CloudFormation) yang boleh di-deploy, lalu end user bisa self-service men-deploy produk tersebut tanpa akses langsung ke AWS Console.

**Manfaat utama:**
- Standarisasi deployment — semua tim pakai template yang sama dan sudah disetujui
- Governance — kontrol siapa yang boleh deploy apa
- Self-service — developer tidak perlu menunggu tim infra untuk provisioning environment baru

**Contoh penggunaan:** Katalog berisi template "RDS PostgreSQL standar perusahaan", "EC2 dengan monitoring CloudWatch wajib", atau "VPC dengan konfigurasi security yang telah diaudit".

---

## Developer Tools

### 1. CodeCommit
Layanan version control (Git) terkelola dan privat dari AWS, mirip GitHub atau GitLab tapi sepenuhnya di dalam ekosistem AWS. Repository disimpan di infrastruktur AWS, terintegrasi dengan IAM untuk autentikasi dan otorisasi, serta tidak ada batasan ukuran repository.

**Integrasi:** Bekerja mulus dengan CodePipeline, CodeBuild, dan CodeDeploy untuk membentuk pipeline CI/CD penuh di AWS.

**Catatan:** Per 2024, AWS mengumumkan CodeCommit tidak menerima pelanggan baru. Tim yang mulai sekarang disarankan menggunakan GitHub, GitLab, atau Bitbucket yang juga terintegrasi dengan layanan AWS lainnya.

---

### 2. CodeDeploy
Layanan deployment otomatis yang mengatur rilis kode ke EC2, Lambda, ECS, maupun server on-premise. Mengurangi risiko downtime saat deployment dengan strategi rilis yang dapat dikonfigurasi.

**Strategi deployment:**
- **In-place** — update instance yang sudah ada satu per satu atau sekaligus
- **Blue/Green** — buat environment baru, alihkan traffic, lalu hapus environment lama
- **Canary** — rilis ke sebagian kecil traffic dulu (misal 10%), lalu bertahap ke 100%
- **Linear** — tambahkan traffic secara bertahap dengan interval waktu tertentu

**Fitur penting:** Rollback otomatis jika deployment gagal (berdasarkan CloudWatch Alarms atau health check).

---

## Front-end Web & Mobile

### 1. AWS Amplify
Platform pengembangan full-stack untuk aplikasi web dan mobile. Menyediakan toolset lengkap mulai dari hosting frontend, backend serverless (API, auth, database, storage), hingga pipeline CI/CD — semuanya bisa dikonfigurasi lewat CLI, Console, atau library JavaScript/mobile.

**Komponen utama:**
- **Amplify Hosting** — deploy dan host aplikasi web (React, Next.js, Vue, Angular, dll.) dengan CDN global, HTTPS otomatis, dan preview per branch
- **Amplify Studio** — visual builder untuk membuat UI dan backend tanpa banyak kode
- **Amplify Libraries** — SDK untuk menghubungkan frontend ke layanan AWS (Auth via Cognito, API via AppSync/API Gateway, Storage via S3)

**Kapan pakai:** Ideal untuk startup, proyek MVP, atau tim frontend yang ingin backend AWS tanpa konfigurasi infra yang panjang.

---

### 2. AWS AppSync
Layanan GraphQL terkelola yang memudahkan pembuatan API real-time dan offline-capable. AppSync menghubungkan frontend ke berbagai sumber data sekaligus (DynamoDB, Lambda, RDS, HTTP API eksternal) lewat satu endpoint GraphQL.

**Fitur unggulan:**
- **Real-time subscriptions** — data di client diperbarui otomatis saat ada perubahan di backend (cocok untuk chat, live dashboard, collaborative editing)
- **Offline support** — client bisa beroperasi offline dan sinkronisasi saat koneksi pulih
- **Resolvers** — petakan GraphQL query/mutation ke sumber data apapun tanpa kode server

**Cocok untuk:** Aplikasi mobile/web yang butuh data real-time, atau saat frontend perlu mengambil data dari banyak sumber dalam satu request.

---

### 3. Amazon Location Service
Layanan peta, geolokasi, dan pelacakan berbasis lokasi yang terintegrasi dalam ekosistem AWS. Memungkinkan developer menambahkan fitur berbasis lokasi ke aplikasi tanpa bergantung sepenuhnya pada penyedia peta pihak ketiga.

**Kapabilitas:**
- **Maps** — tampilkan peta interaktif menggunakan provider Esri atau HERE
- **Places** — geocoding (alamat → koordinat), reverse geocoding, dan pencarian tempat
- **Routes** — kalkulasi rute dan estimasi waktu perjalanan
- **Geofencing** — definisikan area geografis dan terima notifikasi saat perangkat masuk/keluar
- **Tracker** — lacak posisi perangkat atau aset secara real-time

**Contoh penggunaan:** Aplikasi logistik dan pengiriman, pelacakan armada kendaraan, notifikasi promo berdasarkan lokasi pengguna.

---

## Machine Learning

### 1. Amazon SageMaker
Platform machine learning end-to-end dari AWS yang mencakup seluruh siklus hidup ML: persiapan data, pelatihan model, evaluasi, deployment, hingga monitoring model di produksi — semuanya dalam satu platform terintegrasi.

**Komponen utama:**

| Komponen | Fungsi |
|----------|--------|
| **SageMaker Studio** | IDE berbasis web untuk seluruh workflow ML |
| **Data Wrangler** | Persiapan dan transformasi data tanpa banyak kode |
| **Feature Store** | Simpan dan bagikan fitur ML antar tim dan model |
| **Training Jobs** | Latih model di cluster GPU/CPU terkelola, bayar per penggunaan |
| **Autopilot** | AutoML — temukan model terbaik secara otomatis |
| **Model Registry** | Versioning dan approval workflow untuk model ML |
| **Endpoints** | Deploy model sebagai REST API yang scalable |
| **Pipelines** | Otomatiskan pipeline MLOps (retrain, evaluate, deploy) |
| **Clarify** | Deteksi bias dalam data dan model, explainability |

**Kapan pakai SageMaker vs layanan AI lain:**
- Gunakan **SageMaker** jika Anda ingin melatih model kustom sendiri
- Gunakan **Rekognition, Comprehend, Translate, Polly** (AI services) jika ingin pakai model siap pakai tanpa training

**Contoh penggunaan:** Prediksi churn pelanggan, deteksi fraud transaksi, rekomendasi produk, klasifikasi gambar medis.

---

*Dokumen ini mencakup 52 layanan AWS dalam 13 kategori. Untuk informasi terbaru, kunjungi [dokumentasi resmi AWS](https://docs.aws.amazon.com).*