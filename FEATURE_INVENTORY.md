# FEATURE INVENTORY & MASTER CATALOG (*PHASE 2.5*)
**Sistem Informasi Bank Sampah Bersinar — Modul Penjemputan Sampah Berbasis Mobile**
*Inventarisasi Fitur Lengkap, Pemetaan Layar, dan Analisis Kesenjangan Teknis sebagai Fondasi IA & Desain*

---

## 1. RINGKASAN SISTEM (*System Summary*)
Aplikasi **Bank Sampah Bersinar** adalah platform manajemen digital terintegrasi yang menghubungkan warga sebagai penyetor/nasabah, driver sebagai armada penjemput, dan petugas gudang Bank Sampah sebagai pengelola dan verifikator akhir. 

Sistem ini dirancang khusus untuk mendigitalisasi **Alur Penjemputan Sampah oleh Driver (*Online Pick-up Workflow*)** melalui penerapan **Model Penimbangan 3 Tahap** (*Estimasi Warga*, *Timbang Awal Driver*, *Timbang Final Gudang*) dan **6 Status Transisi Pesanan** (`pending` → `accepted` → `on_the_way` → `picked_up` → `validating` → `completed`), guna menciptakan transparansi, keakuratan data fisik barang, dan ketepatan penyaluran reward poin kepada masyarakat.

---

## 2. KLASIFIKASI PENGGUNA (*User Roles & Actors*)
Sistem mengelompokkan seluruh fitur ke dalam 3 (tiga) aktor utama dengan batasan hak akses yang tegas:
1. **Warga (*Nasabah*)**: Pengguna aplikasi mobile Flutter (`/Mobile`) yang fokus pada pengajuan order jemputan, pemantauan status penjemputan (*tracking*), pengecekan saldo poin reward, dan pemanfaatan fitur edukasi/deteksi AI.
2. **Driver (*Armada Penjemput*)**: Pengguna aplikasi mobile Flutter (`/Halaman-Driver`) yang fokus pada penerimaan tugas penjemputan aktif, navigasi ke lokasi warga, pencatatan penimbangan awal di lapangan, dan serah terima muatan ke gudang.
3. **Petugas Bank Sampah (*Web Admin / Verifikator Gudang*)**: Pengguna portal Web Admin berbasis PHP Native (`/bank_sampah`) yang fokus pada manajemen data master, konfirmasi serah terima (`validating`), penimbangan ulang final (`berat_aktual_kg`), serta penyelesaian transaksi poin otomatis (`completed`).

---

## 3. FEATURE INVENTORY (*Inventarisasi Fitur per Aktor*)

### A. Inventarisasi Fitur Aktor Warga (`/Mobile`)

| Nama Fitur | Deskripsi | Tujuan | Prioritas | Status | Keterangan |
| :--- | :--- | :--- | :---: | :---: | :--- |
| **Registrasi Akun Warga** | Pendaftaran akun baru dengan nama, telepon, email, alamat, dan kata sandi. | Membantu warga memiliki identitas digital di Bank Sampah. | **High** | Sudah ada | Berjalan di `auth_api.php`. |
| **Login & Autentikasi** | Masuk ke sistem menggunakan `no_telepon`/`email` dan `password` untuk mendapat `api_token`. | Mengamankan sesi pengguna. | **High** | Sudah ada | Berjalan, namun perlu penambahan batas waktu (*expiration*). |
| **Dasbor Utama Warga** | Menampilkan salam, ringkasan saldo poin, banner promo, dan akses cepat menu. | Memberikan gambaran umum akun dan informasi terkini. | **Medium** | Sudah ada | Tampilan UI rapi, terhubung ke profil. |
| **Buat Pesanan Jemputan (Tahap 1)** | Formulir input alamat, titik koordinat peta, jadwal, jenis sampah, dan `estimasi_berat_kg`. | Memungkinkan warga meminta penjemputan sampah ke rumah. | **High** | Sudah ada | Menghasilkan `estimasi_poin` sebagai info awal (poin belum masuk). |
| **Tracking Timeline Jemputan** | Lini masa visual yang menampilkan 6 tahapan status order (`pending` s.d. `completed`). | Memberikan transparansi posisi dan proses validasi pesanan secara *real-time*. | **High** | Perlu revisi | Perlu penyesuaian label UI dan penambahan status `validating`. |
| **Tracking Posisi Driver & ETA** | Pemantauan koordinat driver di peta beserta Estimasi Kedatangan (ETA). | Memudahkan warga mengetahui posisi armada saat `on_the_way`. | **Medium** | Belum dibuat | Akan ditambahkan sebagai pengembangan fitur monitoring. |
| **Riwayat Penjemputan** | Daftar seluruh order penjemputan yang pernah diajukan beserta status dan detailnya. | Memudahkan arsip dan pelacakan riwayat aktivitas sampah warga. | **Medium** | Sudah ada | Tersedia di `OrdersScreen`. |
| **Detail Order & Hasil Timbang** | Menampilkan rincian item, perbandingan `estimasi_berat_kg`, `berat_driver_kg`, dan `berat_aktual_kg`. | Memberikan rincian audit penimbangan kepada warga. | **High** | Perlu revisi | Perlu penambahan tampilan kolom `berat_driver_kg` dan `berat_aktual_kg`. |
| **Deteksi Jenis Sampah AI** | Klasifikasi gambar sampah melalui kamera menggunakan model Machine Learning. | Membantu warga memilah dan mengenali kategori sampah dengan mudah. | **Low** | Sudah ada | Tersedia di fitur `scan/`. |
| **Katalog & Artikel Edukasi** | Daftar artikel panduan daur ulang dan informasi lingkungan. | Meningkatkan kesadaran lingkungan nasabah. | **Low** | Sudah ada | Tersedia di fitur `education/`. |
| **Riwayat Notifikasi & Reward** | Daftar pesan pemberitahuan status order dan penambahan poin reward masuk. | Memberi tahu warga secara langsung saat poin berhasil divalidasi. | **High** | Perlu revisi | Perlu penyelarasan pesan otomatis saat `completed`. |
| **Profil & Ubah Data** | Manajemen informasi akun, alamat default, dan tombol keluar (*logout*). | Memungkinkan warga memperbarui data diri sewaktu-waktu. | **Medium** | Sudah ada | Berjalan dengan `profile_api.php`. |

---

### B. Inventarisasi Fitur Aktor Driver (`/Halaman-Driver`)

| Nama Fitur | Deskripsi | Tujuan | Prioritas | Status | Keterangan |
| :--- | :--- | :--- | :---: | :---: | :--- |
| **Login Khusus Driver** | Autentikasi akun armada penjemput menggunakan kredensial driver. | Memisahkan sesi armada dengan warga biasa. | **High** | Sudah ada | Terhubung ke `auth_api.php`. |
| **Dasbor Tugas Aktif (*Active Tasks*)** | Menampilkan daftar order masuk berstatus `pending`, `accepted`, dan `on_the_way`. | Menjadi pusat kendali operasional harian armada. | **High** | Sudah ada | Mengambil data dari `driver_api.php?action=get_active_task`. |
| **Terima Tugas Penjemputan** | Tombol konfirmasi penerimaan order (`status = 'accepted'`). | Mengikat `id_driver` pada order sehingga tidak diambil armada lain. | **High** | Sudah ada | Berjalan melalui `PUT orders_api.php`. |
| **Update Status Menuju Lokasi** | Tombol pembaruan status perjalanan (`status = 'on_the_way'`). | Memberi tahu warga bahwa armada sedang bergerak ke lokasi. | **High** | Sudah ada | Berjalan melalui `PUT orders_api.php`. |
| **Navigasi Rute ke Alamat Warga** | Membuka koordinat alamat jemput langsung di aplikasi navigasi (Google Maps). | Membantu driver menemukan lokasi rumah warga dengan akurat. | **Medium** | Sudah ada | Menggunakan paket `url_launcher` & `latlong2`. |
| **Penimbangan Awal Lapangan (Tahap 2)** | Formulir input berat operasional awal (`berat_driver_kg`) saat mengambil sampah. | Mencatat bukti fisik serah terima lapangan dari warga ke driver. | **High** | Belum dibuat | Perlu penambahan input `berat_driver_kg` pada `PickupVerificationScreen`. |
| **Update Status Sampah Dijemput** | Tombol konfirmasi pengangkutan muatan (`status = 'picked_up'`). | Menandai bahwa sampah sudah berada di kendaraan driver menuju gudang. | **High** | Sudah ada | Saat ini hanya mengubah status tanpa menyimpan `berat_driver_kg`. |
| **Serah Terima Gudang (`validating`)** | Tombol konfirmasi bahwa muatan telah diserahkan ke petugas di Bank Sampah. | Mengubah status menjadi `validating` sebagai tanda dimulainya inspeksi gudang. | **High** | Belum dibuat | Fitur baru untuk memperjelas batas operasional armada vs petugas. |
| **Jadwal & Riwayat Tugas Driver** | Daftar penjemputan terjadwal dan riwayat tugas yang telah selesai diangkut. | Memudahkan pemantauan kinerja dan jadwal harian armada. | **Medium** | Sudah ada | Tersedia di `ScheduleScreen` & `HistoryScreen`. |
| **Profil Armada & Kendaraan** | Menampilkan nama driver, nomor telepon, dan tipe/kapasitas kendaraan. | Identitas operasional armada penjemput. | **Low** | Sudah ada | Tersedia di `ProfileScreen`. |

---

### C. Inventarisasi Fitur Aktor Petugas Bank Sampah (Web Admin — `/bank_sampah`)

| Nama Fitur | Deskripsi | Tujuan | Prioritas | Status | Keterangan |
| :--- | :--- | :--- | :---: | :---: | :--- |
| **Login Web Admin** | Autentikasi berbasis sesi PHP untuk admin dan petugas gudang. | Mengamankan portal pengelola dari akses luar. | **High** | Sudah ada | Berjalan di `auth/login.php`. |
| **Dasbor Statistik & Pemantauan** | Menampilkan total warga terdaftar, order aktif, dan grafik pesanan selesai. | Memberikan ikhtisar eksekutif kinerja operasional Bank Sampah. | **Medium** | Sudah ada | Berjalan di `dashboard/index.php`. |
| **Manajemen Order & Penugasan Driver** | Tabel daftar jemputan dan form penugasan manual driver untuk order `pending`. | Memastikan setiap permintaan jemputan mendapatkan armada. | **High** | Sudah ada | Berjalan di `orders/index.php`. |
| **Konfirmasi Serah Terima Gudang** | Mengubah status pesanan dari `picked_up` menjadi `validating`. | Mencatat bahwa fisik barang resmi diterima di gudang Bank Sampah. | **High** | Belum dibuat | Akan ditambahkan pada modul `orders/index.php`. |
| **Penimbangan Akhir & Validasi (Tahap 3)** | Formulir input berat aktual final (`berat_aktual_kg`) setelah penimbangan ulang gudang. | Menetapkan angka mutlak (*Final Truth*) sebagai dasar reward poin. | **High** | Perlu revisi | Perlu penambahan modal/form input `berat_aktual_kg` sebelum klik Selesai. |
| **Penyelesaian Order & Poin Otomatis** | Eksekusi transaksi atomic database yang mengubah status ke `completed` dan menambah poin ke `pengguna.saldo`. | Mengalirkan reward poin secara sah dan aman ke akun warga. | **High** | Perlu revisi | Perlu pembungkusan `mysqli_begin_transaction` dan kueri kalkulasi poin. |
| **Master Data Jenis & Harga Sampah** | CRUD jenis sampah (`nama_sampah`, `harga_per_kg`, `satuan`). | Mengatur rasio tukar poin per kilogram untuk setiap kategori sampah. | **High** | Sudah ada | Berjalan di `jenis_sampah/index.php`. |
| **Master Data Warga & Driver** | CRUD akun pengguna dan detail spesifikasi kendaraan driver. | Mengelola database nasabah dan armada operasional. | **Medium** | Sudah ada | Berjalan di `warga/index.php` & `driver/index.php`. |
| **Master Data Edukasi & Artikel** | CRUD informasi edukasi daur ulang yang ditampilkan di aplikasi warga. | Memperbarui konten wawasan lingkungan secara berkala. | **Low** | Sudah ada | Berjalan di `edukasi/index.php`. |
| **Laporan Operasional & Harian** | Filter, rekapitulasi, dan pencetakan data penjemputan/transaksi per rentang tanggal. | Kebutuhan pertanggungjawaban dan administrasi Bank Sampah. | **Medium** | Sudah ada | Berjalan di `laporan/index.php`. |

---

## 4. KELOMPOK FITUR BERDASARKAN MODUL (*Module Grouping*)

### 🔐 MODUL AUTH (Autentikasi & Identitas)
- **AUTH-01**: Login Warga, Driver & Web Admin (Penerbitan *Bearer Token* & Sesi PHP).
- **AUTH-02**: Registrasi Akun Warga Baru (`POST auth_api.php?action=register`).
- **AUTH-03**: Lupa Kata Sandi (*Forgot Password & Verification Code*).
- **AUTH-04**: Pengecekan & Pembaruan Profil Pengguna (`GET/PUT profile_api.php`).

### 🏠 MODUL HOME (Dasbor & Ringkasan)
- **HOME-01**: Dasbor utama aplikasi Warga (Ringkasan saldo poin, kartu sapaan, *quick actions*).
- **HOME-02**: Banner & Informasi Promo Bank Sampah.
- **HOME-03**: Dasbor Statistik Web Admin (Angka metrik operasional & grafik jemputan).

### 🚛 MODUL PICKUP (Penjemputan, Timbang 3 Tahap & Tracking)
- **PICKUP-01**: Request Pickup oleh Warga (Tahap 1: Input alamat, jadwal, item, `estimasi_berat_kg`, info `estimasi_poin`).
- **PICKUP-02**: Driver Active Task Listing (Pengambilan daftar order `pending`, `accepted`, `on_the_way`).
- **PICKUP-03**: Driver Acceptance & On-The-Way Transition (`PUT orders_api.php` pengikatan `id_driver`).
- **PICKUP-04**: Driver Field Weighing (Tahap 2: Input `berat_driver_kg` saat transisi ke `picked_up`).
- **PICKUP-05**: Warehouse Handover Transition (Transisi status ke `validating` oleh Driver atau Petugas).
- **PICKUP-06**: Warehouse Final Weighing & Completion (Tahap 3: Input `berat_aktual_kg` oleh Petugas & transisi ke `completed`).
- **PICKUP-07**: Tracking Timeline 6 Status (Visualisasi lini masa `pending` → `completed` pada aplikasi Warga).
- **PICKUP-08**: Real-time Driver Location & ETA Tracking (Pemantauan koordinat driver saat `on_the_way`).

### 🤖 MODUL AI (Deteksi Cerdas & Edukasi)
- **AI-01**: Scan Kamera Machine Learning (Deteksi jenis sampah dari gambar di `/Mobile`).
- **AI-02**: Katalog Edukasi Daur Ulang (Artikel lingkungan di aplikasi Warga dan Web Admin).

### 🏆 MODUL REWARD (Poin, Saldo & Notifikasi)
- **REWARD-01**: Kalkulasi Poin Otomatis (Perhitungan `berat_aktual_kg * harga_per_kg` saat pesanan selesai).
- **REWARD-02**: Atomic Database Injection (Penyuntikan poin sah ke `pengguna.saldo` tanpa *race condition*).
- **REWARD-03**: Notifikasi Reward Masuk (Pengiriman pesan otomatis ke aplikasi Warga saat validasi `completed`).
- **REWARD-04**: Riwayat Poin & Penukaran (Daftar histori pertambahan poin warga).

### ⚙️ MODUL SETTING & MASTER DATA
- **SET-01**: Manajemen Katalog Jenis Sampah & Harga/Rasio Poin (Web Admin).
- **SET-02**: Manajemen Armada & Kendaraan Driver (Web Admin & Profil Driver).
- **SET-03**: Pengaturan Akun & Logout (Warga, Driver, dan Web Admin).

---

## 5. INVENTARISASI HALAMAN (*Screen & Page Inventory*)

### A. Aplikasi Warga (`/Mobile` — Flutter)

| Nama Halaman (*Screen Class*) | Modul | Fungsi & Konten | Status Kesiapan |
| :--- | :--- | :--- | :---: |
| `SplashScreen` | Auth/Intro | Layar pemuatan awal logo aplikasi. | **Existing** |
| `SplashIntroScreen` | Auth/Intro | Pengenalan fitur aplikasi untuk pengguna baru. | **Existing** |
| `LoginScreen` | Auth | Form masuk nomor telepon/email dan kata sandi. | **Existing** |
| `RegisterScreen` | Auth | Form pendaftaran akun warga baru. | **Existing** |
| `ForgotPasswordScreen` | Auth | Form permintaan atur ulang kata sandi. | **Existing** |
| `VerificationCodeScreen` | Auth | Form verifikasi kode pengamanan. | **Existing** |
| `MainNavigationScreen` | Home/Core | Navigasi bawah (*Bottom Navigation Bar*) 4 tab utama. | **Existing** |
| `HomeScreen` | Home | Dasbor ringkasan saldo poin, sapaan, dan menu cepat. | **Existing** |
| `OrdersScreen` | Pickup | Daftar riwayat pesanan jemputan aktif dan selesai. | **Need Revision** *(Sesuaikan label 6 status)* |
| `OrderDetailScreen` | Pickup | Rincian pesanan, alamat, dan lini masa tracking status. | **Need Revision** *(Tambah `berat_driver_kg` & `validating`)* |
| `PickupRequestScreen` | Pickup | Form pembuatan order penjemputan baru (Tahap 1). | **Existing** |
| `DriverTrackingScreen` | Pickup | Peta pemantauan koordinat driver & ETA (*Real-time*). | **New Screen** |
| `ScanScreen` | AI | Kamera deteksi otomatis jenis sampah. | **Existing** |
| `AlertsScreen` | Reward/Notif | Daftar notifikasi status pesanan dan reward poin masuk. | **Need Revision** *(Penyelarasan pesan `completed`)* |
| `ProfileScreen` | Setting | Profil akun warga, ubah data diri, dan tombol keluar. | **Existing** |

---

### B. Aplikasi Driver (`/Halaman-Driver` — Flutter)

| Nama Halaman (*Screen Class*) | Modul | Fungsi & Konten | Status Kesiapan |
| :--- | :--- | :--- | :---: |
| `SplashScreen` | Auth | Layar pemuatan awal khusus armada driver. | **Existing** |
| `LoginScreen` | Auth | Form masuk kredensial armada penjemput. | **Existing** |
| `DashboardScreen` | Pickup | Daftar tugas aktif (`pending`, `accepted`, `on_the_way`). | **Existing** |
| `PickupDetailScreen` | Pickup | Rincian alamat warga, koordinat peta, dan tombol terima/jalan. | **Existing** |
| `PickupVerificationScreen` | Pickup | Form penimbangan awal lapangan (`berat_driver_kg`) & angkut (`picked_up`). | **Need Revision** *(Tambah input `berat_driver_kg`)* |
| `WarehouseHandoverScreen` | Pickup | Konfirmasi serah terima fisik sampah di gudang (`validating`). | **New Screen** |
| `ScheduleScreen` | Pickup | Daftar pesanan jemputan terjadwal mendatang. | **Existing** |
| `HistoryScreen` | Pickup | Riwayat pesanan jemputan yang telah selesai dilaksanakan. | **Existing** |
| `AlertsScreen` & `Detail`| Notif | Daftar pemberitahuan tugas penjemputan baru dari sistem. | **Existing** |
| `ProfileScreen` | Setting | Profil driver, plat nomor kendaraan, dan tombol keluar. | **Existing** |

---

### C. Portal Web Admin (`/bank_sampah` — PHP Native)

| Nama Halaman (`index.php?page=...`) | Modul | Fungsi & Konten | Status Kesiapan |
| :--- | :--- | :--- | :---: |
| `auth/login` | Auth | Halaman masuk bagi admin dan petugas gudang. | **Existing** |
| `dashboard` | Home | Ikhtisar statistik warga, total order, dan grafik operasional. | **Existing** |
| `orders/data` | Pickup | Tabel utama manajemen pesanan, filter status, dan penugasan driver. | **Need Revision** *(Tambah filter `validating`)* |
| `orders/verify_modal` | Pickup | Modal/Form input `berat_aktual_kg` final saat menyelesaikan pesanan. | **New Screen / Component** |
| `jenis_sampah/data` | Setting | CRUD master data nama sampah, harga poin per kg, dan satuan. | **Existing** |
| `warga/data` | Setting | Tabel daftar akun warga dan pengelolaan saldo poin. | **Existing** |
| `driver/data` | Setting | Tabel daftar armada driver dan spesifikasi kendaraannya. | **Existing** |
| `edukasi/data` | AI/Edukasi | CRUD artikel edukasi lingkungan yang muncul di aplikasi warga. | **Existing** |
| `laporan/data` | Setting | Halaman rekapitulasi data pesanan, filter tanggal, dan cetak PDF/Excel. | **Existing** |

---

## 6. FEATURE GAP ANALYSIS (*Analisis Kesenjangan Teknis*)

Perbandingan mendalam antara **PRD & Alur Bisnis Baru** versus **Source Code & Skema Database Eksisting** menghasilkan pemetaan 5 (lima) kesenjangan kritis berikut:

```text
[PRD & Alur Bisnis Baru: 3 Tahap Timbang & 6 Status]
                       VS
[Kondisi Kode Eksisting: 2 Tahap Timbang & 6 Enum Lama]
                       ↓
     ╔═════════════════════════════════════════════════╗
     ║ GAP 1: Status 'validating' belum ada di SQL/API ║
     ║ GAP 2: Kolom 'berat_driver_kg' belum ada di DB  ║
     ║ GAP 3: UI Modal Timbang Final di Web Admin abse ║
     ║ GAP 4: Kueri Transaksi Atomic Poin belum ada    ║
     ║ GAP 5: Tracking Lokasi Realtime belum ada       ║
     ╚═════════════════════════════════════════════════╝
```

1. **Gap Kesenjangan Status `validating`**:
   - *Kondisi Eksisting*: Database (`alter_db_for_mobile.sql:37`) hanya memiliki `ENUM('pending','accepted','on_the_way','picked_up','completed','cancelled')`.
   - *Tindakan Penyelesaian*: Perlu migrasi penambahan nilai `'validating'` pada enum `orders.status`, penyesuaian validasi array di `orders_api.php:315`, dan penambahan label warna UI di Web Admin.
2. **Gap Kesenjangan Kolom Penimbangan Tahap 2 (`berat_driver_kg`)**:
   - *Kondisi Eksisting*: Tabel `order_items` saat ini hanya memiliki `estimasi_berat_kg` dan `berat_aktual_kg`.
   - *Tindakan Penyelesaian*: Perlu migrasi penambahan kolom `berat_driver_kg DECIMAL(5,2) DEFAULT NULL` pada tabel `order_items` untuk mencatat angka timbang lapangan driver secara terpisah.
3. **Gap Kesenjangan UI Input Penimbangan Tahap 3 di Web Admin**:
   - *Kondisi Eksisting*: Tombol **"Selesai"** (`verify_order`) pada `modules/orders/index.php:239` langsung menjalankan eksekusi `status = 'completed'` tanpa memberi kesempatan petugas mengisi berat aktual final.
   - *Tindakan Penyelesaian*: Merancang komponen modal pop-up pada Web Admin yang meminta petugas memasukkan `berat_aktual_kg` final untuk setiap item sebelum pesanan ditutup.
4. **Gap Kesenjangan Otomasi & Keamanan Kalkulasi Poin (ACID Transaction)**:
   - *Kondisi Eksisting*: Eksekusi penyelesaian order belum otomatis menghitung perkalian `berat_aktual_kg * harga_per_kg` dan belum menyuntikkan poin ke `pengguna.saldo` dalam satu pembungkus transaksi *begin_transaction*.
   - *Tindakan Penyelesaian*: Menyusun blok kueri transaksi atomic database pada `modules/orders/index.php` dan `orders_api.php` agar penambahan poin dijamin konsisten dan aman dari kesalahan jaringan.
5. **Gap Kesenjangan Pemantauan Posisi Armada (*Tracking Map*)**:
   - *Kondisi Eksisting*: Aplikasi Warga saat ini belum memiliki layar atau peta yang memperlihatkan pergerakan koordinat driver secara *real-time* saat status `on_the_way`.
   - *Tindakan Penyelesaian*: Menambahkan halaman `DriverTrackingScreen` pada aplikasi Warga yang memanfaatkan koordinat dari API dan paket `latlong2`.

---

## 7. FITUR BARU YANG AKAN DITAMBAHKAN (*Roadmap Enhancements Analysis*)

Berikut adalah analisis dampak teknis (*Technical Impact Analysis*) untuk 9 (sembilan) fitur baru dan penyempurnaan yang diposisikan dalam roadmap proyek kita:

| Nama Fitur Baru / Enhancement | Butuh Halaman Baru? | Butuh Revisi Halaman Lama? | Butuh Perubahan API? | Butuh Perubahan Database? | Butuh Perubahan Flutter? | Keterangan & Rencana Eksekusi |
| :--- | :---: | :---: | :---: | :---: | :---: | :--- |
| **1. Status `validating`** | Tidak | Ya (`OrdersScreen`, Web Admin) | Ya (`orders_api.php`) | Ya (Enum `orders.status`) | Ya (Mapping label 6 status) | Menyisipkan status `validating` sebagai penanda resmi serah terima barang di gudang sebelum validasi akhir. |
| **2. Penimbangan 3 Tahap** | Tidak | Ya (`OrderDetailScreen`, Web Admin) | Ya (Parameter input `items[]`) | Ya (Kolom `berat_driver_kg`) | Ya (`PickupVerificationScreen`) | Memisahkan penyimpanan `estimasi_berat_kg` (Warga), `berat_driver_kg` (Driver), dan `berat_aktual_kg` (Petugas). |
| **3. Input `berat_driver_kg`** | Tidak | Ya (`PickupVerificationScreen`) | Ya (`PUT orders_api.php`) | Ya (Kolom `berat_driver_kg`) | Ya (Form `TextFormField` berat) | Driver wajib mengisi berat operasional saat menekan tombol angkut muatan (`picked_up`). |
| **4. Tracking Timeline 6 Status** | Tidak | Ya (`OrderDetailScreen`) | Tidak (Cukup baca `status`) | Tidak | Ya (Komponen *Stepper UI*) | Menyempurnakan widget lini masa pesanan di aplikasi Warga agar memperlihatkan 6 titik status berurutan. |
| **5. Tracking Driver Realtime (Google Maps)** | **Ya (`DriverTrackingScreen`)** | Ya (`OrderDetailScreen` tombol "Lihat Peta") | Ya (`driver_api.php` koordinat) | Tidak (Menggunakan koordinat aktif) | **Ya (Halaman baru & `latlong2`)** | Memungkinkan warga melihat posisi armada penjemput di peta saat status pesanan berada pada `on_the_way`. |
| **6. Driver Location Coordinate Sharing**| Tidak | Tidak | Ya (`PUT driver_api.php`) | Ya (Kolom `lat`/`long` di `detail_driver`)| Ya (Background location push) | Mengirimkan koordinat terkini driver ke backend secara berkala saat menjalankan tugas jemputan. |
| **7. Estimasi Kedatangan (ETA)** | Tidak | Ya (`DriverTrackingScreen`) | Ya (Kalkulasi jarak/waktu) | Tidak | Ya (Tampilan teks ETA) | Menghitung perkiraan waktu kedatangan driver berdasarkan jarak koordinat armada ke alamat rumah warga. |
| **8. Notifikasi Status Pickup Otomatis** | Tidak | Ya (`AlertsScreen`) | Ya (`notifikasi_api.php`) | Tidak (Menggunakan tabel `notifikasi`) | Ya (Penyegaran daftar pesan) | Menyuntikkan pesan notifikasi resmi setiap kali status pesanan berubah, khususnya saat `completed`. |
| **9. Riwayat Tracking & Penimbangan** | Tidak | Ya (`OrderDetailScreen`) | Ya (`GET orders_api.php` detail) | Tidak | Ya (Kartu rincian audit berat) | Menampilkan rekam jejak lengkap angka estimasi vs timbang lapangan vs timbang final gudang kepada warga. |

---

## 8. SCREEN DEPENDENCY & ALUR HUBUNGAN HALAMAN (*Navigation Chains*)

Untuk memastikan tidak ada halaman yang terputus atau menyalahi alur logika operasional, berikut adalah pemetaan hubungan antar halaman untuk ketiga klien:

### A. Alur Navigasi Utama Aplikasi Warga (`/Mobile`)
```text
[MainNavigationScreen / HomeScreen]
               │
               ├─→ (Klik Tombol "Buat Jemputan") → [PickupRequestScreen] (Input Tahap 1: Estimasi)
               │                                            │
               │                                            ↓ (Submit API -> status: 'pending')
               └─→ (Tab Orders) → [OrdersScreen] → [OrderDetailScreen] (Lihat Timeline 6 Status)
                                                            │
                 ┌──────────────────────────────────────────┴──────────────────────────────────────────┐
                 ↓ (Jika status == 'on_the_way')                                                       ↓ (Jika status == 'completed')
      [DriverTrackingScreen] (Peta Realtime & ETA)                                           [AlertsScreen / ProfileScreen] (Cek Poin Masuk)
```

### B. Alur Navigasi Utama Aplikasi Driver (`/Halaman-Driver`)
```text
[DashboardScreen] (Daftar Tugas 'pending', 'accepted', 'on_the_way')
        │
        ↓ (Klik Kartu Pesanan)
[PickupDetailScreen] (Lihat Alamat & Peta Warga)
        │
        ├─→ (Klik "Terima Tugas") → [API PUT status = 'accepted']
        │
        ├─→ (Klik "Menuju Lokasi") → [API PUT status = 'on_the_way']
        │
        └─→ (Klik "Tiba / Timbang") → [PickupVerificationScreen] (Input Tahap 2: berat_driver_kg)
                                               │
                                               ↓ (Klik "Angkut Sampah" -> status = 'picked_up')
                                    [WarehouseHandoverScreen] (Tiba di Gudang -> klik 'validating')
```

### C. Alur Navigasi Utama Web Admin (`/bank_sampah`)
```text
[index.php?page=orders/data] (Tabel Daftar Jemputan & Filter 6 Status)
        │
        ├─→ (Jika status == 'pending') → [Form Assign Driver] → (Submit POST -> status = 'accepted')
        │
        └─→ (Jika status == 'validating') → [Klik Tombol "Validasi / Selesai"]
                                                      │
                                                      ↓ (Membuka Modal/Form)
                                            [orders/verify_modal] (Input Tahap 3: berat_aktual_kg Final)
                                                      │
                                                      ↓ (Submit POST -> Atomic ACID Transaction)
                                            [Order Selesai -> status = 'completed' & Poin Masuk]
```

---

## 9. PERSIAPAN PHASE SELANJUTNYA (*Rekomendasi untuk Phase 3: Information Architecture*)

Dengan terbitnya dokumen `FEATURE_INVENTORY.md` ini, kita telah memiliki pondasi inventarisasi fitur yang 100% matang, konsisten, dan siap diterjemahkan ke dalam struktur arsitektur informasi (*Information Architecture*).

### 🟢 Apa yang Sudah Siap
1. **Daftar Fitur Lengkap**: Seluruh fitur Warga, Driver, dan Web Admin telah terdata beserta prioritasnya.
2. **Pemetaan Layar Klien**: Seluruh halaman eksisting, halaman revisi, dan halaman baru (`DriverTrackingScreen`, `WarehouseHandoverScreen`, `verify_modal`) telah teridentifikasi.
3. **Penyelarasan Alur Bisnis**: Aturan 6 status order dan model penimbangan 3 tahap telah terikat kuat dengan spesifikasi fitur.

### 🟡 Apa yang Harus Disiapkan di Phase 3 (Information Architecture)
1. Menemukan pengelompokan menu (*Menu Grouping & Content Hierarchy*) yang paling efisien agar navigasi di aplikasi Mobile Warga dan Driver tidak membutuhkan lebih dari 3 kali klik untuk mencapai fitur utama.
2. Menyusun struktur taksonomi data yang menghubungkan entitas pesanan dengan profil warga dan katalog edukasi secara logis.

### 🔴 Risiko yang Harus Dihindari pada Phase 3
- **Over-crowding Navigation**: Menaruh terlalu banyak menu di *Bottom Navigation Bar* atau beranda warga sehingga tampilan terasa rumit.
- **Inkonsistensi Istilah (*Naming Mismatch*)**: Menggunakan istilah berbahasa Inggris di satu layar dan bahasa Indonesia di layar lain (harus dibakukan secara konsisten ke bahasa Indonesia akademis yang lugas).

### 💡 Rekomendasi Langkah Eksekusi Phase 3
Kita disarankan untuk membuat dokumen **`INFORMATION_ARCHITECTURE.md`** yang berisi bagan pohon hierarki visual (*Mermaid Hierarchy Tree*) untuk masing-masing dari 3 aktor, mengacu tepat pada katalog fitur di atas tanpa menambahkan fitur liar di luar ruang lingkup penjemputan sampah.

---
*Dokumen FEATURE_INVENTORY.md ini mengacu penuh pada MASTER_PROJECT_PLAN.md sebagai Single Source of Truth (SSOT).*
