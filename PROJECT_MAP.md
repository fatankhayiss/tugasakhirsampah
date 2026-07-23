# PROJECT_MAP.md
> **SINGLE SOURCE OF TRUTH (SSOT)**
> Do not assume project architecture. Always refer to this document before implementing features.

---

## 1. Project Overview
Sistem **iTrashy (Bank Sampah Bersinar)** merupakan ekosistem terdistribusi yang mengelola alur penyetoran dan pengolahan sampah.

**Architecture Flow:**
`Citizen App (Flutter)` & `Driver App (Flutter)`
↓ *(HTTP REST / JSON)*
`Backend API (PHP Native - modules/api/)`
↓ *(SQL Queries)*
`Database (MySQL)`
↑ *(AJAX / Procedural PHP)*
`Admin Dashboard (PHP Native - admin.php)`

---

## 2. Project Structure
Struktur utama sistem terbagi dalam tiga folder:

```text
C:\laragon\www\tugasakhirsampah\
├── Mobile/              (Citizen Mobile App - Flutter)
├── Halaman-Driver/      (Driver Mobile App - Flutter)
└── bank_sampah/         (Admin Dashboard & Backend API - PHP)
```

---

## 3. Citizen App (`Mobile/`)
Menggunakan arsitektur *Clean/Feature-first*.
- **Purpose**: Aplikasi bagi nasabah untuk menyetor sampah, melihat edukasi, dan menukar poin (reward).
- **Responsibility**: UI Presentation, State Management mandiri, Pemanggilan API.
- **core/**: Lapisan abstraksi fundamental.
  - `repositories/`: Berisi *data layer* yang bertugas murni memanggil HTTP request ke Backend API dan parsing JSON ke Model.
  - `services/`: *Logic* tambahan seperti Http Client kustom.
- **features/**: Logika spesifik per fitur (e.g., `auth`, `deposit`, `education`, `home`).
  - Berisi layar UI (`screens/`) yang terhubung langsung ke *repository*.
- **shared/**: Kumpulan *reusable widgets* (tombol, card, appbar) agar desain tetap konsisten.

---

## 4. Driver App (`Halaman-Driver/`)
Menggunakan arsitektur *Screen-Service* yang lebih ringan.
- **Purpose**: Aplikasi bagi petugas (kurir) untuk menjemput sampah warga.
- **Responsibility**: Menampilkan rute, memverifikasi penjemputan, memanggil API status.
- **screens/**: Seluruh layar UI (`dashboard_screen.dart`, `pickup_detail_screen.dart`, dll).
- **services/**: Lapisan komunikasi HTTP (seperti `api_service.dart`, `auth_service.dart`).
- **constants/**: Konfigurasi statis seperti API Base URL dan konstanta warna.
- **main.dart**: *Entry point* yang me-load splash screen dan auth-check.

---

## 5. Admin Dashboard (`bank_sampah/`)
Menggunakan pendekatan *Procedural PHP* dengan perutean tersentralisasi.
- **Purpose**: Portal bagi pengelola untuk memonitor warga, driver, transaksi, edukasi, dan laporan.
- **admin.php**: *Front Controller* utama tempat semua halaman UI (HTML) dirender (via `switch($_GET['page'])`).
- **includes/**: Kumpulan elemen UI yang disisipkan (`header.php`, `sidebar_admin.php`, `footer.php`).
- **modules/api/**: Jantung sistem yang menangani request JSON dari Flutter sekaligus AJAX POST dari `admin.php`.
- **config/**: Tempat file koneksi database (`database.php`).
- **assets/uploads/**: Tempat penyimpanan fisik file gambar (thumbnail, avatar) dan video (`/videos/`).

---

## 6. Admin Routing Map
Semua navigasi Admin melewati parameter `?page=` di `admin.php`.

- `?page=dashboard` ↓ Dashboard Utama
- `?page=nasabah_list` ↓ Daftar Nasabah
- `?page=nasabah_tambah` / `nasabah_edit` / `nasabah_hapus` ↓ Manajemen Nasabah
- `?page=setor_sampah` ↓ Form Input Setoran Manual
- `?page=jenis_sampah` ↓ Manajemen Kategori Sampah
- `?page=edukasi_list` ↓ Daftar Edukasi (Artikel & Video)
- `?page=artikel_tambah` / `artikel_edit` ↓ Form HTML Artikel
- `?page=video_tambah` / `video_edit` ↓ Form HTML Video
- `?page=edukasi_hapus` ↓ Aksi hapus data edukasi
- `?page=laporan` ↓ UI Laporan
- `?page=login` / `logout` ↓ Autentikasi Admin

---

## 7. Module Map (Contoh: Edukasi)
**Education**
- **UI** ↓ `admin.php` (case `edukasi_list`, `artikel_*`, `video_*`)
- **API** ↓ `modules/api/edukasi.php`
- **Database** ↓ Tabel `edukasi`
- **Uploads** ↓ `assets/uploads/` & `assets/uploads/videos/`

---

## 8. API Map (`modules/api/`)
Sebagian besar API dipanggil secara lintas platform (Mobile & Admin AJAX).

- **`auth_api.php`**: Autentikasi (Login, Register). Dipanggil oleh Citizen & Driver App.
- **`edukasi.php`**: Fetch & Manage Artikel/Video. Dipanggil oleh Citizen App (GET) & Admin AJAX (POST).
- **`driver_api.php`**: Mendapatkan tugas pickup & mengupdate status. Dipanggil oleh Driver App.
- **`orders_api.php`**: Mengelola status transaksi/setoran sampah. Dipanggil oleh Citizen App.
- **`transaksi_api.php`**: Menangani input setor. Dipanggil oleh Admin/Citizen.
- **`reward_api.php`**: Penukaran poin nasabah. Dipanggil oleh Citizen App.
- **`profile_api.php`**: Pembaruan profil user. Dipanggil oleh Citizen App.
- **`jenis_sampah_api.php`**: Menarik katalog harga sampah. Dipanggil oleh sistem penjemputan/setor.
- **`detect.php`**: AI Computer Vision classification endpoint.

---

## 9. Flutter Dependency Map
Alur saat layar dibuka di Flutter (Contoh: Lihat Edukasi):
`Screen (education_screen.dart)`
↓ Memanggil Future
`Repository (education_repository.dart)`
↓ HTTP Request JSON
`API (bank_sampah/modules/api/edukasi.php)`
↓ SQL Query
`Database (MySQL)`

---

## 10. Admin Dependency Map
Alur saat Admin menambah/mengedit data (Contoh: Form Tambah Video):
`Admin UI (admin.php?page=video_tambah)`
↓ Input & Click Simpan
`Form (AJAX Javascript via Fetch)`
↓ Mengirim FormData (Teks + File)
`API (bank_sampah/modules/api/edukasi.php)`
↓ Memproses & Menyimpan Logika
`Uploads (assets/uploads/videos/)` -> File Disimpan
↓
`Database (MySQL)` -> Path disimpan ke Tabel

---

## 11. Database Map
Tabel utama yang menggerakkan sistem:
- **`pengguna`**: Data warga, admin, petugas. Berelasi dengan semua tabel yang memiliki `user_id` / `author_id`.
- **`detail_driver`**: Menyimpan metadata tambahan khusus pengguna berlevel *driver* (e.g. plat nomor).
- **`jenis_sampah`**: Master data kategori sampah & harga.
- **`edukasi`**: Menyimpan seluruh artikel & video (dibedakan berdasarkan kolom `video_url` / `video_path`).
- **`reward_redemptions`** & **`redemption_audit_logs`**: Sistem penukaran dan riwayat poin.

---

## 12. Upload System
- **Image Upload**: Menggunakan `move_uploaded_file` menuju direktori `bank_sampah/assets/uploads/`. Disimpan sebagai path string di MySQL.
- **Video Upload**: Menuju direktori `bank_sampah/assets/uploads/videos/`. Khusus form edukasi Video, divalidasi agar *URL* dan *File MP4* saling eksklusif (tidak bertabrakan).

---

## 13. Important Files
- **`admin.php`**: Jantung UI Admin. (Hati-hati dalam modifikasi tag `case` dan `break;`).
- **`config/database.php`**: Pintu masuk database. (Jangan ubah nama variabel `$conn` / `$koneksi`).
- **`Mobile/lib/core/constants/api_config.dart`**: Menyimpan IP address server backend (`192.168.31.220`). Wajib diupdate jika pindah jaringan.

---

## 14. Modification Rules
Setiap membuat/mengubah fitur, identifikasi hal berikut:
1. **Database Tables**: Perlukah `ALTER TABLE`?
2. **API files (`modules/api/`)**: Perlukah backend mengolah parameter baru?
3. **Backend files (`admin.php`)**: Perlukah admin bisa melakukan CRUD data tersebut?
4. **Flutter files (`Mobile` / `Halaman-Driver`)**: Perlukah UI mobile dan *Repository* menangkap JSON yang baru?
> **NEVER MODIFY ONLY ONE SIDE**. Pastikan sinkronisasi end-to-end terjalin.

---

## 15. Feature Checklist
Sebelum membuat fitur baru, selalu periksa:
- [ ] UI Mobile (Citizen / Driver)
- [ ] UI Web Admin (`admin.php`)
- [ ] Integrasi API Backend (`modules/api/`)
- [ ] Skema Database
- [ ] Mekanisme Upload (Jika ada file media)
- [ ] Perutean (Routing) & Navigasi
- [ ] Business Flow (Tidak menabrak alur lama)

---

## 16. AI Working Rules
- Sebelum melakukan modifikasi, baca `PROJECT_MAP.md` ini secara menyeluruh.
- Jangan mengasumsikan nama direktori atau tabel yang tidak tertulis.
- Dilarang mereka-reka (invent) nama tabel atau rute API yang fiktif. Selalu gunakan kerangka arsitektur yang telah ada.
- Perlakukan file ini sebagai *The Supreme Single Source of Truth*.
