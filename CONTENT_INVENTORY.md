# CONTENT INVENTORY & SPECIFICATION CATALOG (*PHASE 3*)
**Sistem Informasi Bank Sampah Bersinar — Modul Penjemputan Sampah Berbasis Mobile**
*Spesifikasi Konten, Elemen UI, Aturan Bisnis, dan Kebutuhan Data per Halaman untuk Semua Peran*

---

## 1. RINGKASAN & TUJUAN DOKUMEN (*Executive Summary*)

Dokumen **Content Inventory (`CONTENT_INVENTORY.md`)** ini berfungsi sebagai **katalog spesifikasi konten mutlak** yang membedah rincian informasi, komponen antarmuka, struktur data, aksi pengguna (*User Actions*), serta aturan bisnis (*Business Rules*) pada setiap halaman aplikasi Bank Sampah Bersinar.

Tujuan utama penyusunan dokumen ini adalah **menyamakan pemahaman seluruh tim (Architect, Technical Lead, Product Manager, UI/UX Designer, System Analyst, dan Developer)** terhadap esensi setiap layar sebelum memasuki fase perancangan lanjutan (*Screen Specification, Information Architecture, Sitemap, Wireframe, Design System, UI Stitch, PRD Final, UML Final, hingga implementasi kode*). 

Dengan mendefinisikan rincian konten per halaman secara teliti dan menyeluruh, kita memastikan bahwa **Model Penimbangan 3 Tahap** (`estimasi_berat_kg`, `berat_driver_kg`, `berat_aktual_kg`) dan **6 Status Transisi Pesanan** (`pending` → `accepted` → `on_the_way` → `picked_up` → `validating` → `completed`) terwakili dengan konsisten di setiap antarmuka tanpa ada elemen yang terlewat atau tumpang tindih.

---

## 2. PENGELOMPOKAN BERDASARKAN AKTOR (*Actor Classification*)

Secara struktural, seluruh inventarisasi konten halaman dibagi berdasarkan 3 (tiga) peran aktor utama sistem:
1. **Warga (*Nasabah*)** — Aplikasi Mobile Flutter (`/Mobile`)
2. **Driver (*Armada Penjemput*)** — Aplikasi Mobile Flutter (`/Halaman-Driver`)
3. **Petugas Bank Sampah (*Web Admin / Verifikator Gudang*)** — Portal Web Admin PHP Native (`/bank_sampah`)

---

## 3 & 4 & 5 & 6 & 7 & 8 & 9 & 10 & 11. SPESIFIKASI KONTEN HALAMAN PER AKTOR

Berikut adalah inventarisasi detail yang mencakup **Nama Halaman, Tujuan, Deskripsi, Role, Status, Konten Ditampilkan, Komponen UI, Data Dibutuhkan, Action Pengguna, Navigation, Business Rules, Dependency, dan Gap Analysis** untuk seluruh layar aplikasi:

---

### A. AKTOR WARGA (`/Mobile` — Flutter)

#### 1. `HomeScreen` (Dasbor Utama Warga)
- **Tujuan Halaman**: Menyajikan ringkasan akun, saldo poin reward, banner informasi, dan gerbang akses utama ke seluruh layanan penjemputan sampah.
- **Deskripsi Singkat**: Layar pembuka sesaat setelah warga masuk ke aplikasi melalui navigasi utama tab beranda.
- **Role**: Warga
- **Status**: **Existing**
- **Konten yang Ditampilkan**:
  - *Greeting*: Sapaan personal ("Halo, [Nama Warga]! Selamat datang kembali.")
  - *Total Poin*: Angka saldo poin terkini dan estimasi konversi/nilai rupiah.
  - *Banner*: Carousel gambar promo atau pengumuman program Bank Sampah.
  - *Menu Utama*: Tombol aksi cepat (*Buat Jemputan*, *Scan AI*, *Katalog Edukasi*, *Riwayat*).
  - *Tracking Card Ringkas*: Kartu mini yang muncul apabila warga memiliki pesanan aktif (`pending`, `accepted`, `on_the_way`, `picked_up`, `validating`).
  - *Artikel Edukasi*: Daftar ringkas 3 artikel daur ulang terbaru.
- **Komponen UI**: `AppBar`, `Bottom Navigation Bar`, `Card (Poin & Tracking)`, `Carousel (Banner)`, `Grid/Icon Button (Menu)`, `ListView (Artikel)`, `Loading Shimmer`.
- **Data yang Dibutuhkan**: `nama_lengkap`, `saldo_poin`, `active_order_id`, `active_order_status`, `list_banner`, `list_artikel`.
- **Action Pengguna**: *Klik Buat Jemputan*, *Klik Scan AI*, *Klik Kartu Tracking*, *Klik Artikel*, *Refresh Hal (Pull-to-refresh)*.
- **Navigation**: `LoginScreen` ↓ `HomeScreen` ↓ (`PickupRequestScreen` / `OrderDetailScreen` / `ScanScreen`).
- **Business Rules**:
  - Kartu *Tracking Ringkas* hanya muncul jika terdapat order dengan status selain `completed` dan `cancelled`.
  - Angka `saldo_poin` adalah akumulasi mutlak dari hasil penimbangan akhir petugas di gudang Bank Sampah.
- **Dependency**: API `GET profile_api.php`, API `GET orders_api.php (Filter Active)`, API `GET edukasi.php`.
- **Gap Analysis**: **Sudah Sesuai** *(Tinggal menambahkan pengecekan status `validating` pada trigger munculnya Tracking Card)*.

---

#### 2. `PickupRequestScreen` (Form Buat Order Jemputan — Tahap 1)
- **Tujuan Halaman**: Memfasilitasi nasabah dalam mengajukan permintaan penjemputan sampah ke rumah beserta perkiraan awal berat dan poin.
- **Deskripsi Singkat**: Formulir terstruktur tempat warga menentukan lokasi, waktu jemput, dan jenis-jenis sampah yang akan disetor.
- **Role**: Warga
- **Status**: **Existing**
- **Konten yang Ditampilkan**:
  - *Pilih Alamat Jemput*: Teks alamat lengkap rumah warga (mendukung pengubahan alamat/peta koordinat).
  - *Jadwal Jemput*: Pilihan tanggal dan sesi waktu penjemputan (Pagi/Siang).
  - *Daftar Item Sampah*: Pilihan jenis sampah (Kertas, Plastik, Logam, Kaca) beserta form input `estimasi_berat_kg`.
  - *Kalkulator Estimasi*: Teks ringkasan Total Estimasi Berat (`kg`) dan Total Estimasi Poin (`poin`).
  - *Catatan Tambahan*: Instruksi khusus untuk driver (misal: "Sampah ada di depan pagar").
  - *Peringatan Sistem*: Teks penjelas bahwa poin baru akan masuk ke akun setelah diverifikasi fisik oleh petugas di Bank Sampah.
- **Komponen UI**: `AppBar`, `Form`, `Dropdown/Picker (Tanggal)`, `Card (Item Sampah)`, `TextField (Berat & Catatan)`, `Map Preview Button`, `Submit Button`, `Dialog Konfirmasi`.
- **Data yang Dibutuhkan**: `id_warga`, `alamat_jemput`, `latitude`, `longitude`, `jadwal_jemput`, `items[id_jenis_sampah, estimasi_berat_kg]`, `estimasi_poin`.
- **Action Pengguna**: *Pilih Titik Peta*, *Tambah/Hapus Item Sampah*, *Input Estimasi Berat*, *Tulis Catatan*, *Klik Submit Order*.
- **Navigation**: `HomeScreen` ↓ `PickupRequestScreen` ↓ `OrdersScreen` / `OrderDetailScreen`.
- **Business Rules**:
  - Warga wajib memasukkan minimal 1 jenis item sampah dengan `estimasi_berat_kg > 0`.
  - Nilai `estimasi_poin` dihitung dari `SUM(estimasi_berat_kg * harga_poin_per_kg)` hanya sebagai informasi awal — **tidak menambah saldo di database**.
  - Sesaat setelah disubmit, status pesanan otomatis diatur menjadi `pending`.
- **Dependency**: API `GET jenis_sampah_api.php`, API `POST orders_api.php`, Tabel `orders` & `order_items`.
- **Gap Analysis**: **Sudah Sesuai** *(Kalkulasi estimasi Tahap 1 sudah berjalan dengan sangat baik di aplikasi)*.

---

#### 3. `OrdersScreen` (Daftar Riwayat & Pemantauan Jemputan)
- **Tujuan Halaman**: Menampilkan daftar seluruh permintaan jemputan milik warga, baik yang sedang berjalan maupun yang telah selesai/dibatalkan.
- **Deskripsi Singkat**: Halaman riwayat dengan tab filter atau daftar kartu order bersertakan label warna status.
- **Role**: Warga
- **Status**: **Need Revision** *(Perlu penambahan label & warna untuk status baru `validating`)*
- **Konten yang Ditampilkan**:
  - *Filter Tab*: Pilihan filter *(Semua, Berjalan, Selesai, Dibatalkan)*.
  - *Kartu Order*: Nomor pesanan (`#ORD-XXXX`), tanggal pengajuan, alamat singkat, dan Label Status (`pending`, `accepted`, `on_the_way`, `picked_up`, `validating`, `completed`).
  - *Ringkasan Angka*: Teks `estimasi_berat_kg` dan `estimasi_poin` (atau `berat_aktual_kg` dan `poin final` jika `completed`).
- **Komponen UI**: `AppBar`, `TabBar / Filter Chip`, `ListView`, `Card`, `Status Badge / Chip (6 Warna)`, `Empty State Illustration`, `Pull-to-Refresh`.
- **Data yang Dibutuhkan**: `list_orders[id_order, created_at, status, estimasi_berat, berat_aktual, estimasi_poin, poin_final]`.
- **Action Pengguna**: *Klik Filter Tab*, *Klik Kartu Order untuk Lihat Detail*, *Refresh Daftar*.
- **Navigation**: `MainNavigationScreen (Tab Orders)` ↓ `OrdersScreen` ↓ `OrderDetailScreen`.
- **Business Rules**:
  - Order berstatus `validating` harus diberi label warna khusus (misal: Ungu/Biru Langit) dengan teks *"Sampah Sedang Divalidasi di Gudang"*.
  - Order berstatus `completed` menampilkan angka poin resmi yang telah berhasil masuk ke akun.
- **Dependency**: API `GET orders_api.php?id_warga={id}`.
- **Gap Analysis**: **Perlu Revisi** *(Penyesuaian enum status pada parser Flutter agar mengenali string `'validating'`)*.

---

#### 4. `OrderDetailScreen` (Detail Jemputan & Tracking Timeline 6 Status)
- **Tujuan Halaman**: Menyajikan rincian lengkap pesanan, audit perbandingan 3 tahap berat muatan, serta lini masa proses penjemputan.
- **Deskripsi Singkat**: Layar rincian spesifik yang menjadi pusat transparansi informasi operasional kepada nasabah.
- **Role**: Warga
- **Status**: **Need Revision** *(Perlu penyesuaian Timeline 6 Status & kolom `berat_driver_kg`)*
- **Konten yang Ditampilkan**:
  - *Informasi Order*: Nomor ID Order, tanggal pembuatan, dan catatan pengajuan.
  - *Tracking Timeline 6 Status*: Visualisasi lini masa vertikal/horizontal dengan 6 titik check (`pending` → `accepted` → `on_the_way` → `picked_up` → `validating` → `completed`).
  - *Tombol Lihat Peta & ETA*: Muncul aktif apabila status sedang `on_the_way`.
  - *Informasi Driver*: Foto, nama armada, nomor telepon, dan tombol telepon (muncul jika `status >= accepted`).
  - *Tabel Audit Penimbangan 3 Tahap*:
    - **Tahap 1**: Estimasi Warga (`estimasi_berat_kg`) & Estimasi Poin.
    - **Tahap 2**: Timbang Lapangan Driver (`berat_driver_kg`) *(muncul jika `status >= picked_up`)*.
    - **Tahap 3**: Timbang Final Gudang (`berat_aktual_kg`) & Poin Sah *(muncul jika `status == completed`)*.
- **Komponen UI**: `AppBar`, `Card (Driver Info)`, `Timeline / Stepper (6 Stage)`, `Table / DataGrid (Audit Berat)`, `Button (Lihat Peta / Telepon Driver)`, `Status Banner`.
- **Data yang Dibutuhkan**: `id_order`, `status`, `timeline_timestamps`, `driver_name`, `driver_phone`, `items[nama_sampah, estimasi_berat_kg, berat_driver_kg, berat_aktual_kg, harga_poin]`, `poin_final`.
- **Action Pengguna**: *Klik Tombol Lihat Peta Realtime*, *Klik Hubungi Driver (Telepon/WA)*, *Klik Kembali*.
- **Navigation**: `OrdersScreen` ↓ `OrderDetailScreen` ↓ (`DriverTrackingScreen` jika `on_the_way`).
- **Business Rules**:
  - Tombol *Lihat Peta Realtime* hanya aktif sewaktu status == `on_the_way`.
  - Kolom `berat_driver_kg` (Tahap 2) adalah angka saat sampah diangkut ke mobil, tidak menambah saldo poin.
  - Kolom `berat_aktual_kg` (Tahap 3) adalah **Acuan Mutlak (*Final Authority*)**. Nilai poin yang tertara di kolom ini adalah nilai sah yang masuk ke tabel `pengguna.saldo`.
- **Dependency**: API `GET orders_api.php?id_order={id}`, Tabel `order_items` & `detail_driver`.
- **Gap Analysis**: **Perlu Revisi** *(Menambahkan step `validating` pada widget `Timeline` dan memunculkan kolom `berat_driver_kg`)*.

---

#### 5. `DriverTrackingScreen` (Peta Tracking Realtime & ETA — *New Screen*)
- **Tujuan Halaman**: Memberikan pemantauan visual pergerakan armada penjemput menuju rumah warga secara *real-time* bersertakan perkiraan waktu kedatangan (*Estimated Time of Arrival / ETA*).
- **Deskripsi Singkat**: Halaman peta interaktif yang menampilkan posisi koordinat driver dan rute perjalanan menuju titik alamat penjemputan.
- **Role**: Warga
- **Status**: **New Screen**
- **Konten yang Ditampilkan**:
  - *Peta Interaktif*: Peta Google Maps / OpenStreetMap (`flutter_map`) dengan penanda posisi rumah warga (*Destination Marker*) dan posisi mobil driver (*Driver Marker*).
  - *Panel ETA & Jarak*: Teks jarak tersisa (`km`) dan perkiraan waktu tiba (`menit`).
  - *Kartu Kontak Driver*: Nama armada, plat nomor kendaraan, dan tombol panggilan cepat.
  - *Lini Masa Ringkas*: Status aktif bahwa armada sedang dalam perjalanan menuju lokasi.
- **Komponen UI**: `AppBar`, `Map Widget`, `Custom Markers (Driver & Home)`, `BottomSheet / Floating Panel (ETA Info)`, `Button (Call/WhatsApp)`, `Loading Indicator`.
- **Data yang Dibutuhkan**: `id_order`, `latitude_warga`, `longitude_warga`, `latitude_driver`, `longitude_driver`, `driver_name`, `plat_nomor`, `eta_minutes`.
- **Action Pengguna**: *Zoom In/Out Peta*, *Klik Center to Driver*, *Klik Hubungi Driver*.
- **Navigation**: `OrderDetailScreen` ↓ `DriverTrackingScreen`.
- **Business Rules**:
  - Halaman ini hanya dapat diakses atau dibuka ketika `status == 'on_the_way'`.
  - Posisi `latitude_driver` dan `longitude_driver` diambil dari koordinat aktif yang dikirim driver ke backend secara berkala.
- **Dependency**: API `GET driver_api.php?action=get_location` atau polling data order, Paket `latlong2`.
- **Gap Analysis**: **Belum Ada** *(Fitur baru yang perlu dibangun untuk meningkatkan transparansi layanan)*.

---

#### 6. `AlertsScreen` (Daftar Notifikasi Status & Poin)
- **Tujuan Halaman**: Memberikan pemberitahuan instan mengenai setiap perubahan status jemputan dan penerimaan reward poin ke akun warga.
- **Deskripsi Singkat**: Daftar pesan kronologis dari sistem Bank Sampah.
- **Role**: Warga
- **Status**: **Need Revision** *(Penyelarasan pesan notifikasi saat transisi ke `validating` dan `completed`)*
- **Konten yang Ditampilkan**:
  - *Filter Notifikasi*: Semua / Belum Dibaca.
  - *Item Notifikasi*: Judul pesan (contoh: *"Sampah Sedang Divalidasi"*, *"Reward Poin Berhasil Ditambahkan!"*), isi ringkas pesan, waktu penerimaan, dan ikon status.
- **Komponen UI**: `AppBar`, `ListView`, `Card / ListTile`, `Notification Icon (Check/Truck/Coin)`, `Empty State (Tidak Ada Notifikasi)`.
- **Data yang Dibutuhkan**: `list_notifikasi[id_notif, judul, pesan, is_read, created_at, id_order_referensi]`.
- **Action Pengguna**: *Klik Notifikasi (buka Detail Order referensi)*, *Tandai Sudah Dibaca*.
- **Navigation**: `MainNavigationScreen (Tab Alerts)` ↓ `AlertsScreen` ↓ `OrderDetailScreen`.
- **Business Rules**:
  - Setiap kali petugas memvalidasi pesanan menjadi `completed`, sistem otomatis menerbitkan pesan notifikasi berisi rincian: *"Selesai! Anda mendapatkan +XXX Poin dari penjemputan #ORD-XXXX."*
- **Dependency**: API `GET notifikasi_api.php?id_pengguna={id}`.
- **Gap Analysis**: **Perlu Revisi** *(Pengecekan konsistensi pembuatan notifikasi otomatis dari backend saat eksekusi penyelesaian order)*.

---

### B. AKTOR DRIVER (`/Halaman-Driver` — Flutter)

#### 7. `DashboardScreen` (Dasbor Tugas Aktif — *Driver Active Tasks*)
- **Tujuan Halaman**: Menampilkan daftar tugas penjemputan yang tersedia atau sedang dijalankan armada pada hari itu.
- **Deskripsi Singkat**: Pusat komando operasional armada penjemput yang mengelompokkan pesanan berstatus `pending`, `accepted`, dan `on_the_way`.
- **Role**: Driver
- **Status**: **Existing**
- **Konten yang Ditampilkan**:
  - *Header Driver*: Nama armada, plat kendaraan, dan status ketersediaan (*Online/Ready*).
  - *Daftar Tugas Pending*: Pesanan baru dari warga di wilayah operasi yang belum diambil oleh driver manapun.
  - *Daftar Tugas Saya (*My Tasks*)*: Pesanan yang telah ditekan tombol *Terima Tugas* (`accepted`) atau sedang dalam perjalanan (`on_the_way`).
  - *Kartu Ringkasan Tugas*: Alamat jemput, jarak perkiraan, jadwal jemput, dan estimasi berat muatan.
- **Komponen UI**: `AppBar (Profile Toggle)`, `TabBar / Section Header`, `ListView`, `Task Card`, `Button (Terima / Detail)`, `Pull-to-Refresh`.
- **Data yang Dibutuhkan**: `driver_profile`, `list_tasks[id_order, alamat, latitude, longitude, jadwal, estimasi_berat, status]`.
- **Action Pengguna**: *Klik Tombol Terima Tugas*, *Klik Kartu Tugas untuk Lihat Detail*, *Refresh Daftar Tugas*.
- **Navigation**: `LoginScreen` ↓ `DashboardScreen` ↓ `PickupDetailScreen`.
- **Business Rules**:
  - Order berstatus `pending` dapat diterima oleh driver yang berwenang. Saat driver menekan *Terima Tugas*, status order otomatis berubah menjadi `accepted` dan `id_driver` terikat pada tabel `orders`.
  - Order yang sudah berstatus `accepted` oleh Driver A tidak akan muncul di layar Pending milik Driver B.
- **Dependency**: API `GET driver_api.php?action=get_active_task`, API `PUT orders_api.php`.
- **Gap Analysis**: **Sudah Sesuai** *(Pengambilan active tasks dan pengikatan driver sudah berfungsi di antarmuka eksisting)*.

---

#### 8. `PickupDetailScreen` (Detail Jemput, Alamat & Navigasi Peta)
- **Tujuan Halaman**: Memberikan informasi navigasi lengkap ke titik alamat warga dan menyediakan tombol transisi status operasional armada.
- **Deskripsi Singkat**: Layar rincian tugas yang memandu driver dari posisinya menuju rumah warga.
- **Role**: Driver
- **Status**: **Existing**
- **Konten yang Ditampilkan**:
  - *Rincian Warga*: Nama nasabah, nomor telepon, dan tombol telepon langsung.
  - *Lokasi & Peta Preview*: Alamat lengkap dan koordinat peta.
  - *Tombol Buka Navigasi*: Membuka rute di Google Maps eksternal (`url_launcher`).
  - *Rincian Item Sampah*: Perkiraan jenis dan `estimasi_berat_kg` yang dilaporkan warga.
  - *Tombol Aksi Dinamis (*Dynamic Action Button*)*:
    - Jika status `accepted`: Tombol **"Mulai Menuju Lokasi"** (`on_the_way`).
    - Jika status `on_the_way`: Tombol **"Tiba di Lokasi (Mulai Penimbangan)"**.
- **Komponen UI**: `AppBar`, `Card (Customer Info & Map)`, `ListView (Items)`, `Button (Call Customer / Buka Google Maps)`, `Primary Action Button (Bottom Fixed)`.
- **Data yang Dibutuhkan**: `id_order`, `status`, `nama_warga`, `phone_warga`, `alamat_jemput`, `latitude`, `longitude`, `items[nama_sampah, estimasi_berat_kg]`.
- **Action Pengguna**: *Klik Telepon Warga*, *Klik Buka Google Maps*, *Klik Mulai Menuju Lokasi*, *Klik Tiba di Lokasi*.
- **Navigation**: `DashboardScreen` ↓ `PickupDetailScreen` ↓ `PickupVerificationScreen` *(saat klik Tiba di Lokasi)*.
- **Business Rules**:
  - Tombol *Mulai Menuju Lokasi* mengubah status dari `accepted` menjadi `on_the_way` dan mengaktifkan pengiriman koordinat ke backend untuk fitur tracking warga.
  - Tombol *Tiba di Lokasi* akan mengarahkan driver ke layar penimbangan awal lapangan.
- **Dependency**: API `PUT orders_api.php`, Paket `latlong2` & `url_launcher`.
- **Gap Analysis**: **Sudah Sesuai** *(Transisi status ke `on_the_way` dan pembukaan navigasi rute Google Maps sudah berjalan)*.

---

#### 9. `PickupVerificationScreen` (Form Timbang Lapangan — Tahap 2)
- **Tujuan Halaman**: Memfasilitasi armada driver mencatat hasil penimbangan awal di lapangan saat mengambil sampah di rumah warga sebagai bukti fisik serah terima muatan.
- **Deskripsi Singkat**: Formulir verifikasi lapangan tempat driver mengisi `berat_driver_kg` sebelum sampah diangkut ke mobil.
- **Role**: Driver
- **Status**: **Need Revision** *(Perlu penambahan input `berat_driver_kg` pada setiap item sampah)*
- **Konten yang Ditampilkan**:
  - *Daftar Item Sampah Order*: Menampilkan setiap jenis sampah yang diajukan warga.
  - *Perbandingan Estimasi Warga*: Teks `estimasi_berat_kg` (Tahap 1) di samping input.
  - *Input Berat Driver (`berat_driver_kg`)*: Input angka desimal untuk mencatat berat hasil timbangan gantung/timbangan digital lapangan yang dibawa armada (Tahap 2).
  - *Foto Bukti Pengambilan*: Opsi mengambil/mengunggah foto tumpukan sampah yang diangkut.
  - *Catatan Lapangan*: Teks keterangan jika ada perbedaan fisik barang (misal: "Sampah basah terkena hujan").
  - *Tombol Konfirmasi Angkut (`picked_up`)*: Tombol konfirmasi serah terima lapangan.
- **Komponen UI**: `AppBar`, `Form`, `Card per Item`, `TextField (Berat Driver KG)`, `Camera/Image Picker Widget`, `TextField (Catatan)`, `Primary Submit Button ("Konfirmasi Angkut Sampah")`.
- **Data yang Dibutuhkan**: `id_order`, `items[id_order_item, nama_sampah, estimasi_berat_kg, berat_driver_kg]`, `foto_bukti`, `catatan_driver`.
- **Action Pengguna**: *Input Angka Berat Driver*, *Ambil Foto Bukti*, *Tulis Catatan*, *Klik Konfirmasi Angkut Sampah*.
- **Navigation**: `PickupDetailScreen` ↓ `PickupVerificationScreen` ↓ `WarehouseHandoverScreen` / `DashboardScreen`.
- **Business Rules**:
  - Driver wajib mengisi `berat_driver_kg` untuk setiap item sebelum menekan tombol konfirmasi angkut.
  - Saat tombol *Konfirmasi Angkut Sampah* ditekan, sistem mengirim `PUT orders_api.php` yang mengubah status order menjadi `picked_up` dan menyimpan angka `berat_driver_kg` ke tabel `order_items`.
  - Angka `berat_driver_kg` ini **belum memberikan atau menambah saldo poin warga**. Angka ini murni berfungsi sebagai data operasional dan bukti serah terima lapangan dari warga ke driver.
- **Dependency**: API `PUT orders_api.php (payload: items with berat_driver_kg, status: picked_up)`, Tabel `order_items`.
- **Gap Analysis**: **Perlu Revisi** *(Saat ini aplikasi driver eksisting hanya melakukan transisi status ke `picked_up` tanpa meminta angka timbang awal. Kita wajib menambahkan input `berat_driver_kg` pada halaman ini)*.

---

#### 10. `WarehouseHandoverScreen` (Serah Terima Gudang `validating` — *New Screen*)
- **Tujuan Halaman**: Memungkinkan armada driver atau petugas gudang mencatat momen serah terima muatan fisik dari mobil driver ke area inspeksi Bank Sampah.
- **Deskripsi Singkat**: Layar konfirmasi ketibaan armada di gudang yang memicu transisi status ke `validating`.
- **Role**: Driver (atau Petugas Gudang)
- **Status**: **New Screen**
- **Konten yang Ditampilkan**:
  - *Ringkasan Muatan Order*: Nomor ID Order, nama warga asal, dan total `berat_driver_kg` yang dibawa armada.
  - *Lokasi Gudang Tujuan*: Nama Bank Sampah dan nama petugas verifikator yang bertugas.
  - *Pernyataan Serah Terima*: Teks konfirmasi bahwa seluruh kantong sampah telah diturunkan dan diserahkan ke area penimbangan akhir gudang.
  - *Tombol Serahkan Muatan (`validating`)*: Tombol pembaruan status resmi.
- **Komponen UI**: `AppBar`, `Summary Card`, `Confirmation Checkbox / Toggle`, `Primary Button ("Serahkan Muatan ke Gudang")`.
- **Data yang Dibutuhkan**: `id_order`, `driver_name`, `total_berat_driver`, `status`.
- **Action Pengguna**: *Centang Konfirmasi Serah Terima*, *Klik Serahkan Muatan ke Gudang*.
- **Navigation**: `PickupVerificationScreen` ↓ `WarehouseHandoverScreen` ↓ `DashboardScreen`.
- **Business Rules**:
  - Tombol ini mengubah status dari `picked_up` menjadi `validating`.
  - Sesaat setelah status berubah menjadi `validating`, tugas driver dinyatakan selesai dan pesanan berpindah sepenuhnya ke antrean penimbangan akhir petugas di portal Web Admin.
- **Dependency**: API `PUT orders_api.php (status: validating)`.
- **Gap Analysis**: **Belum Ada** *(Fitur baru yang sangat krusial untuk memperjelas batas tanggung jawab antara Driver lapangan dengan Petugas Gudang)*.

---

### C. AKTOR PETUGAS BANK SAMPAH (`/bank_sampah` — PHP Native Web Admin)

#### 11. `orders/data` (Tabel Manajemen Jemputan & Assign Driver)
- **Tujuan Halaman**: Menjadi pusat kendali pengelola gudang dalam memantau seluruh permintaan jemputan, menugaskan armada, dan menyeleksi pesanan yang siap divalidasi.
- **Deskripsi Singkat**: Halaman tabel berfilter yang memperlihatkan status seluruh transaksi jemputan secara *real-time*.
- **Role**: Petugas Bank Sampah (Web Admin)
- **Status**: **Need Revision** *(Perlu penyesuaian filter dan pemetaan warna untuk status `validating`)*
- **Konten yang Ditampilkan**:
  - *Filter & Pencarian*: Filter Status (`Semua`, `pending`, `accepted`, `on_the_way`, `picked_up`, `validating`, `completed`) dan kolom cari ID/Nama Warga.
  - *Tabel Data Order*: Kolom ID Order, Tanggal, Nama Warga, Alamat, Driver Ditugaskan, Status, dan Tombol Aksi.
  - *Aksi Penugasan Manual*: Dropdown pilih driver untuk pesanan berstatus `pending`.
  - *Tombol Aksi Verifikasi*: Tombol **"Validasi Timbang Akhir"** untuk pesanan berstatus `validating` (atau `picked_up`).
- **Komponen UI**: `Sidebar Menu`, `Navbar`, `Filter Cards / Dropdown`, `DataTables / Table`, `Status Badge / Label`, `Action Buttons ("Assign", "Validasi Timbang")`.
- **Data yang Dibutuhkan**: `query_orders_with_warga_and_driver`, `list_drivers_active`.
- **Action Pengguna**: *Filter Tabel*, *Pilih Driver & Klik Assign*, *Klik Tombol Validasi Timbang Akhir*.
- **Navigation**: `index.php?page=dashboard` ↓ `index.php?page=orders/data` ↓ (`orders/verify_modal`).
- **Business Rules**:
  - Order berstatus `pending` dapat ditugaskan secara manual oleh petugas kepada armada tertentu.
  - Order berstatus `validating` memunculkan tombol hijau tajam **"Validasi Timbang Akhir (`completed`)"**.
- **Dependency**: Kueri `SELECT * FROM orders JOIN pengguna...`, Kueri `UPDATE orders SET id_driver...`.
- **Gap Analysis**: **Perlu Revisi** *(Menambahkan tab/filter status `validating` pada antarmuka tabel PHP Native)*.

---

#### 12. `orders/verify_modal` (Form Timbang Final Gudang — Tahap 3 & Atomic ACID Completion)
- **Tujuan Halaman / Komponen**: Memastikan petugas melakukan penimbangan fisik ulang yang akurat di gudang Bank Sampah sebelum sistem mengkalkulasi dan menyalurkan reward poin secara sah ke akun warga.
- **Deskripsi Singkat**: Modal pop-up atau halaman form verifikasi akhir yang menjadi **gerbang penentuan hak poin warga (*Final Truth*)**.
- **Role**: Petugas Bank Sampah (Web Admin)
- **Status**: **New Screen / Component** *(Saat ini tombol Selesai eksisting langsung memutasi status tanpa form timbang final)*
- **Konten yang Ditampilkan**:
  - *Header Verifikasi*: Nomor Order (`#ORD-XXXX`) dan informasi Warga penyetor.
  - *Tabel Perbandingan 3 Tahap*:
    - Kolom Item Sampah & Harga Poin per KG (`harga_poin_per_kg`).
    - Kolom Estimasi Warga (`estimasi_berat_kg` — Tahap 1).
    - Kolom Timbang Driver (`berat_driver_kg` — Tahap 2).
    - **Input Berat Aktual Gudang (`berat_aktual_kg` — Tahap 3)**: Form input desimal tempat petugas memasukkan angka timbangan akhir resmi.
  - *Kalkulator Poin Otomatis (Real-time Preview)*: Menampilkan perkalian otomatis `berat_aktual_kg * harga_poin_per_kg` untuk setiap item, serta Total Poin Sah yang akan dikirimkan ke warga.
  - *Catatan Inspeksi Gudang*: Form keterangan kualitas (misal: "Kotoran/air pada plastik dipotong 0.5 kg").
  - *Tombol Konfirmasi Final (`completed`)*: Tombol eksekusi penyelesaian pesanan.
- **Komponen UI**: `Modal / Card Form`, `Comparison Table (3 Stage)`, `Number Input Fields (Berat Aktual KG)`, `Dynamic JavaScript Total Calculator`, `Textarea (Catatan)`, `Button ("Selesaikan & Salurkan Poin")`.
- **Data yang Dibutuhkan**: `id_order`, `items[id_order_item, nama_sampah, estimasi_berat_kg, berat_driver_kg, berat_aktual_kg, harga_poin]`, `total_poin_calculated`.
- **Action Pengguna**: *Input Angka Berat Aktual Gudang per Item*, *Cek Preview Poin*, *Tulis Catatan Inspeksi*, *Klik Selesaikan & Salurkan Poin*.
- **Navigation**: `orders/data` ↓ `orders/verify_modal` ↓ *(Submit Transaksi)* → `orders/data (Status: completed)`.
- **Business Rules (MUTLAK & KRITIS)**:
  1. Petugas wajib mengisi `berat_aktual_kg` untuk semua item muatan.
  2. **Acuan Mutlak (*Final Authority*)**: Perhitungan total poin sah **wajib menggunakan kolom `berat_aktual_kg` (Tahap 3)**, bukan `estimasi_berat_kg` ataupun `berat_driver_kg`.
     $$\text{Poin Item} = \text{berat\_aktual\_kg} \times \text{harga\_poin\_per\_kg}$$
     $$\text{Total Poin Sah} = \sum (\text{Poin Item})$$
  3. **Integritas Transaksi ACID (*Atomic Transaction*)**: Saat tombol *Selesaikan & Salurkan Poin* ditekan, backend PHP Native (`modules/orders/index.php` atau `orders_api.php`) wajib menjalankan blok transaksi atomic:
     ```sql
     START TRANSACTION;
     -- 1. Update berat_aktual_kg pada setiap baris order_items
     UPDATE order_items SET berat_aktual_kg = ? WHERE id_order_item = ?;
     -- 2. Update status order menjadi completed dan simpan total poin final
     UPDATE orders SET status = 'completed', poin_final = ? WHERE id_order = ?;
     -- 3. Tambahkan poin final secara langsung ke saldo akun warga
     UPDATE pengguna SET saldo = saldo + ? WHERE id_pengguna = ?;
     -- 4. Catat notifikasi otomatis untuk warga
     INSERT INTO notifikasi (id_pengguna, judul, pesan, created_at) VALUES (?, 'Reward Poin Masuk!', '...', NOW());
     COMMIT;
     ```
     Jika terjadi satu saja kegagalan dalam proses di atas, seluruh kueri wajib di-*ROLLBACK* agar tidak terjadi inkonsistensi saldo.
- **Dependency**: Transaksi `mysqli_begin_transaction` / `mysqli_commit` pada PHP Native, Tabel `order_items`, `orders`, `pengguna`, `notifikasi`.
- **Gap Analysis**: **Belum Ada / Perlu Revisi Kritis** *(Ini adalah penyempurnaan paling krusial dari audit kita untuk mengunci keakuratan ilmiah Tugas Akhir pada modul backend).*

---

## 11. MATRIKS GAP ANALYSIS KESELURUHAN (*Comprehensive Gap Matrix*)

| Nama Halaman / Modul | Kondisi Eksisting (`Source Code` & `DB`) | Spesifikasi Konten Target (`CONTENT_INVENTORY`) | Status Penyelarasan |
| :--- | :--- | :--- | :---: |
| `HomeScreen` (Warga) | Dasbor ringkasan poin dan banner sudah siap. | Penambahan trigger munculnya kartu tracking saat status `validating`. | **Sudah Sesuai** |
| `PickupRequestScreen` (Warga) | Form jemputan & kalkulasi `estimasi_berat_kg` sudah siap. | Penegasan bahwa estimasi poin tidak mutasi saldo database. | **Sudah Sesuai** |
| `OrdersScreen` (Warga) | Daftar order mendukung 5 status lama. | Penambahan filter tab dan badge warna untuk status `validating`. | **Perlu Revisi** |
| `OrderDetailScreen` (Warga) | Rincian order & timeline 5 status. | Penambahan step `validating` pada timeline & perbandingan 3 kolom berat. | **Perlu Revisi** |
| `DriverTrackingScreen` (Warga) | Belum tersedia di aplikasi. | Peta pemantauan posisi koordinat driver & ETA saat `on_the_way`. | **Belum Ada (New)** |
| `AlertsScreen` (Warga) | Daftar notifikasi dasar sudah tersedia. | Otomatisasi pesan rincian poin masuk saat order `completed`. | **Perlu Revisi** |
| `DashboardScreen` (Driver) | Daftar active task dan tombol terima/jalan sudah siap. | Penyelarasan tampilan informasi item pesanan. | **Sudah Sesuai** |
| `PickupVerificationScreen` (Driver) | Hanya tombol konfirmasi angkut (`picked_up`). | **Wajib ditambah input `berat_driver_kg` (Tahap 2)** untuk setiap item. | **Perlu Revisi Kritis** |
| `WarehouseHandoverScreen` (Driver)| Belum tersedia di aplikasi driver. | Konfirmasi serah terima muatan di gudang untuk mengubah status ke `validating`.| **Belum Ada (New)** |
| `orders/data` (Web Admin) | Tabel pesanan melayani assign driver & Selesai. | Penambahan filter tabel untuk status `validating`. | **Perlu Revisi** |
| `orders/verify_modal` (Web Admin) | Tombol Selesai langsung mutasi status tanpa input timbang. | **Wajib dibuat modal input `berat_aktual_kg` (Tahap 3) & Transaksi Atomic ACID.** | **Belum Ada / Kritis** |

---

## 12. REKOMENDASI PERSIAPAN MENUJU PHASE 4 (`SCREEN_SPECIFICATION.md`)

Dengan terbitnya **`CONTENT_INVENTORY.md`** ini, kita telah mendefinisikan secara tuntas seluruh elemen, komponen UI, aturan bisnis, serta spesifikasi data untuk setiap halaman yang ada dan yang akan dibuat.

### 🎯 Apa yang Telah Kita Capai di Phase 3
- Seluruh tim memiliki peta konten yang homogen untuk 12 halaman/komponen kunci.
- Logika penimbangan 3 tahap dan 6 status order telah terikat dengan kueri database (khususnya transaksi Atomic ACID pada `verify_modal`).
- Tidak ada lagi kesimpangsiuran mengenai kapan poin diberikan atau tahap timbangan mana yang menjadi acuan final.

### 📋 Rekomendasi sebelum Memasuki PHASE 4 (`SCREEN_SPECIFICATION.md` / `Information Architecture`)
1. **Gunakan Dokumen Ini sebagai Check-list UI**: Pada Phase 4 nanti, saat merinci spesifikasi spesifik atau menggambar *Wireframe*, pastikan setiap komponen UI yang tercantum di dokumen ini (seperti `Comparison Table (3 Stage)`, `Timeline (6 Stage)`, dan `Number Input Fields`) tergambar jelas pada sketsa antarmuka.
2. **Kunci Penomoran ID Halaman**: Agar penelusuran dokumen Laporan Tugas Akhir rapi, kita sarankan untuk menggunakan kode pengenal halaman (misal: `WRG-01` untuk HomeScreen Warga, `DRV-03` untuk PickupVerificationScreen Driver, dan `ADM-02` untuk Modal Timbang Gudang) pada dokumen-dokumen selanjutnya.
3. **Persiapan Skrip Migrasi DDL**: Mengingat spesifikasi konten ini memerlukan kolom `berat_driver_kg` pada `order_items` serta enum `'validating'` pada `orders`, kita siap merumuskan skrip migrasi SQL resmi pada tahap perancangan database (Phase 12) yang selaras 100% dengan `CONTENT_INVENTORY.md` ini.

---
*Dokumen CONTENT_INVENTORY.md ini mengacu penuh pada MASTER_PROJECT_PLAN.md dan FEATURE_INVENTORY.md sebagai Single Source of Truth (SSOT).*
