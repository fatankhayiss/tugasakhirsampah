# SCREEN CATALOG & INTERFACE SPECIFICATION (*PHASE 3.75*)
**Sistem Informasi Bank Sampah Bersinar — Modul Penjemputan Sampah Berbasis Mobile**
*Katalog Spesifikasi Lengkap 18 Parameter per Layar sebagai Jembatan IA menuju Wireframe, Desain, dan Implementasi*

---

## 1. EXECUTIVE SUMMARY (*Ringkasan Eksekutif*)

Dokumen **Screen Catalog (`SCREEN_CATALOG.md`)** ini merupakan **katalog spesifikasi teknis dan antarmuka presisi tinggi** yang dipersiapkan dalam kapasitas rekayasa arsitektur perangkat lunak (*Enterprise Software Architecture*) sebagai jembatan fungsional antara *Information Architecture (IA)* dan tahap pembuatan *Sitemap*, *Wireframe*, *UI Design (Stitch/Figma)*, serta pemrograman kode Flutter dan PHP Native.

Tujuan utama penyusunan katalog ini adalah menghilangkan ambiguitas komunikasi dalam pengembangan sistem. Setiap layar (*Screen Class* di Flutter maupun *Controller Page* di Web Admin) diberi identitas standar (*Screen ID*), diklasifikasikan status eksistingnya (*Existing / Need Revision / New Screen*), dan dibedah secara tuntas melalui **18 Parameter Spesifikasi Wajib**. 

Dengan rumusan ini, *generator prompt UI AI* maupun *Software Engineer* tidak akan salah menafsirkan aturan bisnis **Model Penimbangan 3 Tahap** (`estimasi_berat_kg`, `berat_driver_kg`, `berat_aktual_kg`) maupun urutan **6 Status Transisi Pesanan** (`pending` → `accepted` → `on_the_way` → `picked_up` → `validating` → `completed`), serta penanganan *Empty State*, *Loading State*, *Error State*, hingga ketergantungan API pada setiap layar antarmuka.

---

## 2. SCREEN MATRIX (*Matriks Ikhtisar Layar Sistem*)

Berikut adalah matriks lengkap seluruh layar sistem yang dikelompokkan berdasarkan peran aktor:

| Screen ID | Screen Name | Role / Aktor | Tujuan Utama | Existing Status | Priority |
| :---: | :--- | :--- | :--- | :---: | :---: |
| **WRG-001** | `Onboarding & Splash Screen` | Warga | Pemuatan awal & pengenalan fitur Bank Sampah. | **Existing** | Low |
| **WRG-002** | `Authentication Screens` | Warga | Login, Registrasi Warga, dan Atur Ulang Sandi. | **Existing** | High |
| **WRG-003** | `Home Screen` | Warga | Dasbor ringkasan saldo poin, banner, dan menu cepat. | **Existing** | High |
| **WRG-004** | `Pickup Request Screen` | Warga | Form pengajuan jemputan (Tahap 1: `estimasi_berat_kg`). | **Existing** | **Critical** |
| **WRG-005** | `Orders Screen` | Warga | Daftar riwayat jemputan & filter tab 6 status. | **Need Revision** | High |
| **WRG-006** | `Order Detail Screen` | Warga | Rincian jemputan, audit 3 tahap berat & lini masa 6 status. | **Need Revision** | **Critical** |
| **WRG-007** | `Driver Tracking Screen` | Warga | Peta pemantauan koordinat armada & ETA (*Real-time*). | **New Screen** | Medium |
| **WRG-008** | `AI Scan & Education Screen` | Warga | Deteksi kamera jenis sampah & katalog artikel lingkungan. | **Existing** | Low |
| **WRG-009** | `Alerts & Reward Screen` | Warga | Daftar notifikasi status pesanan & histori poin masuk. | **Need Revision** | High |
| **WRG-010** | `Profile Screen` | Warga | Profil akun warga, alamat default, dan logout. | **Existing** | Medium |
| **DRV-001** | `Driver Auth Screens` | Driver | Login kredensial khusus armada penjemput. | **Existing** | High |
| **DRV-002** | `Dashboard Screen` | Driver | Daftar tugas aktif (`pending`, `accepted`, `on_the_way`). | **Existing** | **Critical** |
| **DRV-003** | `Pickup Detail Screen` | Driver | Rincian alamat warga & tombol navigasi Google Maps. | **Existing** | High |
| **DRV-004** | `Pickup Verification Screen` | Driver | Form timbang awal lapangan (Tahap 2: `berat_driver_kg`). | **Need Revision** | **Critical** |
| **DRV-005** | `Warehouse Handover Screen` | Driver | Serah terima muatan di gudang (`validating`). | **New Screen** | **Critical** |
| **DRV-006** | `Schedule & History Screen` | Driver | Jadwal mendatang & riwayat penjemputan selesai. | **Existing** | Medium |
| **DRV-007** | `Alerts & Profile Screen` | Driver | Notifikasi tugas baru & profil kendaraan armada. | **Existing** | Low |
| **ADM-001** | `Admin Login Page` | Web Admin | Autentikasi sesi pengelola portal Bank Sampah. | **Existing** | High |
| **ADM-002** | `Executive Dashboard` | Web Admin | Statistik total warga, order, dan grafik transaksi. | **Existing** | Medium |
| **ADM-003** | `Orders Management Table` | Web Admin | Tabel jemputan, filter 6 status & penugasan driver. | **Need Revision** | **Critical** |
| **ADM-004** | `Warehouse Final Weighing Modal` | Web Admin | Form timbang final gudang (Tahap 3: `berat_aktual_kg` & ACID). | **New Screen** | **Critical** |
| **ADM-005** | `Waste Catalog Management` | Web Admin | CRUD harga tukar poin per kg (`jenis_sampah`). | **Existing** | High |
| **ADM-006** | `Users & Drivers Management` | Web Admin | Manajemen akun nasabah (`warga`) & armada (`driver`). | **Existing** | Medium |
| **ADM-007** | `Education & Reports Page` | Web Admin | CRUD artikel edukasi & cetak laporan operasional PDF/Excel. | **Existing** | Medium |

---

## 3. SPESIFIKASI LENGKAP 18 PARAMETER PER SCREEN

---

### A. AKTOR WARGA (`WRG-***` — Aplikasi Mobile Flutter)

#### WRG-001 : Onboarding & Splash Screen
1. **Screen ID**: `WRG-001`
2. **Screen Name**: `SplashScreen` & `SplashIntroScreen`
3. **Role**: Warga
4. **Tujuan Screen**: Menampilkan identitas branding Bank Sampah Bersinar saat aplikasi dimuat dan memandu pengguna baru memahami manfaat layanan penjemputan sampah digital.
5. **Deskripsi Singkat**: `SplashScreen` adalah layar transisi pembuka dengan logo dan animasi singkat saat memuat sesi penyimpanan lokal (`shared_preferences`). Jika pengguna baru pertama kali mengunduh aplikasi, sistem akan mengarahkan ke `SplashIntroScreen` yang berisi 3 slide penjelasan singkat tentang cara kerja pilah sampah, jemput ke rumah, dan dapat poin reward.
6. **Existing Status**: **Existing**
7. **Priority**: Low
8. **Navigation**:
   - *Masuk dari*: Launching Aplikasi Mobile.
   - *Keluar ke*: `WRG-002 (LoginScreen)` jika belum login; atau `WRG-003 (HomeScreen)` jika token sesi masih valid.
9. **Komponen UI**: `App Logo`, `Animated Progress Bar`, `Carousel / Slide Pager`, `Illustration Banner`, `Primary Button ("Mulai Sekarang")`, `Text Button ("Lewati")`.
10. **Informasi yang Ditampilkan**: Logo Bank Sampah Bersinar, Slogan aplikasi, Teks panduan 3 langkah penjemputan sampah.
11. **User Action**: *Geser Slide Intro*, *Klik Mulai Sekarang*, *Klik Lewati*.
12. **Business Rules**: Pengecekan token API (`api_token`) dilakukan secara otomatis di latar belakang saat `SplashScreen` aktif.
13. **Empty State**: Tidak berlaku.
14. **Loading State**: Animasi putar loading (*Spinner / Linear Progress*) saat memeriksa koneksi awal ke server `192.168.167.68`.
15. **Error State**: Teks pemberitahuan *"Gagal terhubung ke server Bank Sampah. Periksa koneksi internet Anda."* bersertakan tombol *Coba Lagi*.
16. **Data Dependency**: `SharedPreferences (token, is_first_time)`.
17. **API Dependency**: `GET auth_api.php?action=check_token` (opsional untuk pengecekan keaktifan sesi).
18. **Future Enhancement**: Penambahan animasi lottie interaktif dan pemilihan bahasa antarmuka (ID/EN).

---

#### WRG-002 : Authentication Screens
1. **Screen ID**: `WRG-002`
2. **Screen Name**: `LoginScreen`, `RegisterScreen`, `ForgotPasswordScreen`, `VerificationCodeScreen`
3. **Role**: Warga
4. **Tujuan Screen**: Mengamankan akses pengguna dan memfasilitasi pendaftaran akun nasabah baru ke dalam sistem Bank Sampah.
5. **Deskripsi Singkat**: Kumpulan layar autentikasi berseri. `LoginScreen` meminta masukan nomor telepon/email dan kata sandi. `RegisterScreen` meminta kelengkapan data diri nasabah (Nama Lengkap, Username, Password, No. Telepon, dan Alamat Domisili) yang langsung dicatat ke tabel `pengguna`. `ForgotPasswordScreen` dan `VerificationCodeScreen` melayani pemulihan sandi melalui kode verifikasi 4/6 digit.
6. **Existing Status**: **Existing**
7. **Priority**: High
8. **Navigation**:
   - *Masuk dari*: `WRG-001 (SplashScreen / Intro)` atau tombol *Logout* di `ProfileScreen`.
   - *Keluar ke*: `WRG-003 (HomeScreen)` setelah autentikasi berhasil; atau antar layar autentikasi (Login $\leftrightarrow$ Register).
9. **Komponen UI**: `AppBar (Transparent)`, `TextFormField (Nama, Phone, Email, Password)`, `Password Visibility Toggle`, `Primary Submit Button`, `Text Button (Daftar / Lupa Sandi)`, `PinCodeTextField (OTP/Code)`, `Snackbar / Dialog Alert`.
10. **Informasi yang Ditampilkan**: Judul halaman ("Masuk ke Akun Anda" / "Daftar Akun Warga"), Instruksi pengisian form, Teks validasi error input.
11. **User Action**: *Input Kredensial*, *Klik Lihat Kata Sandi*, *Klik Masuk*, *Klik Daftar*, *Klik Kirim Ulang Kode Verifikasi*.
12. **Business Rules**:
    - Nomor telepon wajib bertipe angka dan unik di database (`no_telepon`).
    - Kata sandi minimal 6 karakter.
    - Setelah berhasil login/register, backend menerbitkan string `api_token` yang wajib disimpan secara permanen di `SharedPreferences` perangkat mobile.
13. **Empty State**: Form input kosong saat pertama kali dibuka.
14. **Loading State**: Tombol *Masuk / Daftar* berubah menjadi indikator putar (*CircularProgressIndicator*) dan dinonaktifkan sementara saat request ke server berlangsung.
15. **Error State**:
    - *Kredensial salah*: Snackbar merah *"Nomor telepon atau kata sandi tidak cocok."*
    - *No. Telepon sudah terdaftar*: Snackbar merah *"Nomor telepon sudah digunakan oleh akun lain."*
    - *Network Error*: Dialog peringatan gangguan koneksi server.
16. **Data Dependency**: Tabel `pengguna` (level = `'warga'`).
17. **API Dependency**: `POST auth_api.php?action=login`, `POST auth_api.php?action=register`.
18. **Future Enhancement**: Login cepat berbasis biometrik (*Fingerprint / FaceID*) dan otentikasi tunggal (*Single Sign-On / Google Login*).

---

#### WRG-003 : Home Screen (Dasbor Utama Warga)
1. **Screen ID**: `WRG-003`
2. **Screen Name**: `HomeScreen`
3. **Role**: Warga
4. **Tujuan Screen**: Memberikan ikhtisar instan mengenai saldo poin reward, informasi promo, serta menyediakan jalan pintas cepat menuju fitur penjemputan sampah.
5. **Deskripsi Singkat**: Layar utama yang selalu diakses warga melalui tab beranda di `MainNavigationScreen`. Menampilkan kartu saldo poin berwarna kontras di bagian atas, tombol aksi cepat (*Buat Jemputan*, *Scan AI*, *Edukasi*), kartu notifikasi jemputan aktif (*Tracking Card*), dan daftar artikel lingkungan terbaru.
6. **Existing Status**: **Existing**
7. **Priority**: High
8. **Navigation**:
   - *Masuk dari*: `WRG-002 (LoginScreen)` atau Tab 1 `MainNavigationScreen`.
   - *Keluar ke*: `WRG-004 (PickupRequestScreen)`, `WRG-006 (OrderDetailScreen via Tracking Card)`, `WRG-008 (ScanScreen)`, atau Tab lain (`Orders`, `Alerts`, `Profile`).
9. **Komponen UI**: `Custom Header AppBar (Greeting & Notification Icon)`, `Hero Card (Saldo Poin & Estimasi Rupiah)`, `Banner Carousel (PageIndicator)`, `Grid Action Icons (Quick Menu)`, `Conditional Tracking Card (Active Order Alert)`, `Section Header`, `ListView (Artikel Edukasi)`, `Shimmer Loading`.
10. **Informasi yang Ditampilkan**: Sapaan pengguna (`nama_lengkap`), Angka `saldo_poin` mutlak, Banner pengumuman, Status order aktif terkini (`pending`/`accepted`/`on_the_way`/`picked_up`/`validating`), Judul & ringkasan artikel daur ulang.
11. **User Action**: *Klik Tombol Buat Jemputan*, *Klik Tombol Scan AI*, *Klik Kartu Tracking Aktif*, *Geser Banner*, *Klik Artikel Edukasi*, *Pull-to-Refresh Halaman*.
12. **Business Rules**:
    - **Kartu Tracking Aktif (*Active Order Alert*)** hanya muncul apabila warga memiliki minimal 1 pesanan dengan status `pending`, `accepted`, `on_the_way`, `picked_up`, atau `validating`. Jika seluruh order berstatus `completed` atau `cancelled`, kartu ini disembunyikan.
    - Nilai `saldo_poin` yang ditampilkan pada Hero Card adalah angka pasti dari kolom `pengguna.saldo` yang diakumulasikan khusus dari hasil penimbangan akhir petugas di gudang Bank Sampah.
13. **Empty State**: Jika belum ada pesanan aktif, Tracking Card disembunyikan. Jika belum ada artikel, ditampilkan teks *"Belum ada artikel edukasi terbaru."*
14. **Loading State**: Tampilan kerangka bayangan abu-abu (*Shimmer Loading*) pada Hero Card dan daftar artikel saat memuat data profil dan berita dari server.
15. **Error State**: Jika gagal memuat saldo poin, Hero Card menampilkan tanda seru kuning dengan teks *"Gagal memuat saldo. Ketuk untuk segarkan."*
16. **Data Dependency**: `pengguna (saldo, nama_lengkap)`, `orders (active status)`, `edukasi`.
17. **API Dependency**: `GET profile_api.php`, `GET orders_api.php?id_warga={id}&active_only=true`, `GET edukasi.php`.
18. **Future Enhancement**: Widget grafik pertumbuhan saldo poin bulanan dan pencapaian lencana peduli lingkungan (*Gamification Badges*).

---

#### WRG-004 : Pickup Request Screen (Form Buat Order Jemputan — Tahap 1)
1. **Screen ID**: `WRG-004`
2. **Screen Name**: `PickupRequestScreen`
3. **Role**: Warga
4. **Tujuan Screen**: Memungkinkan nasabah mengajukan permintaan penjemputan sampah ke alamat domisili beserta pelaporan estimasi awal berat dan perkiraan poin.
5. **Deskripsi Singkat**: Formulir interaktif tempat warga merencanakan penyerahan sampah. Warga dapat memilih atau mengonfirmasi alamat jemput, menetapkan tanggal dan sesi waktu jemput (Pagi/Siang), memilih kategori item sampah (Kertas, Plastik, Logam, Kaca), memasukkan angka `estimasi_berat_kg` per item, serta menuliskan catatan khusus untuk driver.
6. **Existing Status**: **Existing**
7. **Priority**: **Critical**
8. **Navigation**:
   - *Masuk dari*: Tombol *Buat Jemputan* di `WRG-003 (HomeScreen)`.
   - *Keluar ke*: `WRG-005 (OrdersScreen)` atau `WRG-006 (OrderDetailScreen)` setelah form berhasil disubmit.
9. **Komponen UI**: `AppBar ("Buat Jemputan Baru")`, `Form`, `Address Card & Map Selector Button`, `DatePicker / TimeSlot Radio Buttons`, `Dynamic Item Cards (Dropdown Jenis Sampah + TextField Berat KG + Delete Button)`, `Add Item Button ("+ Tambah Jenis Sampah")`, `Summary Calculation Box (Total KG & Estimasi Poin)`, `TextFormField (Catatan Driver)`, `Info Banner Alert ("Poin asli ditentukan setelah verifikasi gudang")`, `Primary Submit Button ("Ajukan Penjemputan")`.
10. **Informasi yang Ditampilkan**: Alamat jemput aktif, Pilihan tanggal/waktu, Daftar katalog nama sampah dan harga tukar poin per kg, Teks kalkulasi real-time (`Total Estimasi Berat KG` & `Total Estimasi Poin`), Peringatan aturan bisnis poin.
11. **User Action**: *Klik Ubah Alamat/Titik Peta*, *Pilih Tanggal & Sesi*, *Pilih Jenis Sampah*, *Input Angka Estimasi Berat*, *Klik Tambah/Hapus Item Sampah*, *Tulis Catatan*, *Klik Ajukan Penjemputan*.
12. **Business Rules (MUTLAK & KRITIS)**:
    - Warga wajib mendaftarkan minimal 1 item sampah dengan nilai `estimasi_berat_kg > 0`.
    - **Otoritas Penimbangan Tahap 1**: Nilai `estimasi_poin` dihitung secara langsung di antarmuka menggunakan rumus:
      $$\text{Estimasi Poin} = \sum \Big(\text{estimasi\_berat\_kg} \times \text{harga\_poin\_per\_kg}\Big)$$
    - **LARANGAN MUTLAK**: Angka `estimasi_poin` dan `estimasi_berat_kg` ini **TIDAK BOLEH** ditambahkan ke saldo database `pengguna.saldo`. Angka ini hanya disimpan di tabel `order_items` sebagai perkiraan awal dan rincian informasi nasabah.
    - Sesaat setelah order berhasil disubmit melalui API, status pesanan otomatis diatur menjadi `pending` (`orders.status = 'pending'`).
13. **Empty State**: Form input item sampah diawali dengan 1 kartu kosong siap pilih.
14. **Loading State**: Pemuatan daftar jenis sampah menampilkan indikator loading tipis. Saat tombol *Ajukan Penjemputan* ditekan, tombol menampilkan putaran loading dan dinonaktifkan untuk mencegah *double-submit*.
15. **Error State**:
    - *Item kosong/nol*: Dialog peringatan *"Mohon masukkan estimasi berat minimal untuk jenis sampah yang dipilih."*
    - *Alamat belum lengkap*: Snackbar *"Alamat penjemputan tidak boleh kosong."*
    - *Gagal Submit API*: Dialog peringatan *"Pesanan gagal dikirim ke server. Periksa koneksi atau coba beberapa saat lagi."*
16. **Data Dependency**: Tabel `jenis_sampah`, `orders`, `order_items`.
17. **API Dependency**: `GET jenis_sampah_api.php`, `POST orders_api.php (payload: id_warga, alamat_jemput, latitude, longitude, jadwal, estimasi_poin, items[])`.
18. **Future Enhancement**: Pemilihan foto lampiran sampah saat membuat order dan fitur simpan draf pesanan (*Draft Pick-up*).

---

#### WRG-005 : Orders Screen (Daftar Riwayat Jemputan & Filter Tab 6 Status)
1. **Screen ID**: `WRG-005`
2. **Screen Name**: `OrdersScreen`
3. **Role**: Warga
4. **Tujuan Screen**: Menyajikan daftar kronologis seluruh pesanan penjemputan sampah yang pernah diajukan nasabah bersertakan label status terkininya.
5. **Deskripsi Singkat**: Halaman riwayat utama yang diakses melalui navigasi bawah tab ke-2. Memiliki bilah tab filter di bagian atas (*Semua*, *Berjalan*, *Selesai*, *Dibatalkan*) dan menampilkan daftar kartu pesanan yang memuat nomor ID, tanggal, alamat, ringkasan berat/poin, dan lencana warna untuk ke-6 status resmi.
6. **Existing Status**: **Need Revision** *(Perlu penyesuaian parser & penambahan label/warna untuk status `validating`)*
7. **Priority**: High
8. **Navigation**:
   - *Masuk dari*: Tab 2 `MainNavigationScreen` atau setelah submit order di `WRG-004`.
   - *Keluar ke*: `WRG-006 (OrderDetailScreen)` saat kartu pesanan diklik.
9. **Komponen UI**: `AppBar ("Riwayat Jemputan")`, `TabBar / Filter Chips (Semua, Berjalan, Selesai, Batal)`, `ListView`, `Order Summary Cards`, `Status Badges (6 Warna Kontras)`, `Empty State Widget (Illustration & Text)`, `Pull-to-Refresh Indicator`.
10. **Informasi yang Ditampilkan**: Nomor Order (`#ORD-XXXX`), Tanggal & waktu pengajuan, Alamat singkat, Lencana Status (`pending`, `accepted`, `on_the_way`, `picked_up`, `validating`, `completed`, `cancelled`), Teks ringkasan (`Total Estimasi: X kg / Y Poin` atau `Berat Aktual Final: A kg / B Poin Sah`).
11. **User Action**: *Klik Tab Filter Status*, *Klik Kartu Pesanan untuk Buka Rincian*, *Tarik Layar ke Bawah untuk Segarkan Data*.
12. **Business Rules**:
    - Pemetaan warna dan label lencana status (*Status Badge Mapping*) pada kartu order ditentukan sebagai berikut:
      - `pending`: Kuning / *Menunggu Armada*
      - `accepted`: Biru Muda / *Armada Ditugaskan*
      - `on_the_way`: Oranye / *Armada Menuju Lokasi*
      - `picked_up`: Biru Tua / *Sampah Diangkut Driver*
      - `validating`: **Ungu / *Sampah Sedang Divalidasi Gudang*** *(Perlu Revisi Penambahan)*
      - `completed`: Hijau Tajam / *Selesai (Poin Masuk)*
      - `cancelled`: Merah / *Dibatalkan*
    - Tab filter *"Berjalan"* mengelompokkan pesanan berstatus `pending`, `accepted`, `on_the_way`, `picked_up`, dan `validating`.
13. **Empty State**: Tampilan ilustrasi grafis tempat sampah bersih dengan teks *"Belum ada riwayat penjemputan pada kategori ini."* dan tombol CTA *"Buat Jemputan Sekarang"*.
14. **Loading State**: Tampilan 4 kartu kerangka bayangan (*Shimmer Loading Cards*) saat mengambil daftar pesanan dari server.
15. **Error State**: Tampilan pesan kesalahan jaringan dengan tombol *Segarkan Ulang*.
16. **Data Dependency**: Tabel `orders`, `order_items`.
17. **API Dependency**: `GET orders_api.php?id_warga={id}`.
18. **Future Enhancement**: Fitur ekspor riwayat penjemputan warga dalam format e-receipt PDF.

---

#### WRG-006 : Order Detail Screen (Detail Order, Audit 3 Tahap Berat & Timeline 6 Status)
1. **Screen ID**: `WRG-006`
2. **Screen Name**: `OrderDetailScreen`
3. **Role**: Warga
4. **Tujuan Screen**: Menampilkan transparansi penuh rincian pesanan, rekam jejak lini masa status (*tracking timeline*), serta tabel audit perbandingan penimbangan 3 tahap kepada nasabah.
5. **Deskripsi Singkat**: Layar rincian mendalam yang diakses ketika warga menekan kartu order di `WRG-005`. Layar ini memuat 4 blok informasi kunci: (1) Lini masa vertikal/horizontal transisi 6 status, (2) Kartu informasi armada driver penjemput, (3) Tabel audit sanding penimbangan barang (*Estimasi Warga vs Timbang Driver vs Timbang Final Gudang*), dan (4) Tombol aksi kontekstual untuk membuka peta tracking atau menelepon driver.
6. **Existing Status**: **Need Revision** *(Perlu penambahan titik `validating` pada lini masa & pemunculkan kolom `berat_driver_kg` di tabel rincian item)*
7. **Priority**: **Critical**
8. **Navigation**:
   - *Masuk dari*: `WRG-005 (OrdersScreen)`, `WRG-003 (HomeScreen via Tracking Card)`, atau `WRG-009 (AlertsScreen)`.
   - *Keluar ke*: `WRG-007 (DriverTrackingScreen)` jika menekan tombol *Lihat Peta Realtime*; atau kembali ke layar sebelumnya.
9. **Komponen UI**: `AppBar ("Detail Pesanan #ORD-XXXX")`, `Vertical Status Timeline Stepper (6 Step Checkpoints)`, `Driver Info Card (Photo, Name, Plate, Call Button)`, `Comparison Data Table / Item List (3-Column Weighing Audit)`, `Contextual Action Button ("Lihat Peta Realtime & ETA" / "Batalkan Order")`, `Status Alert Banner`.
10. **Informasi yang Ditampilkan**: 
    - Nomor Order, Tanggal buat, Jadwal jemput, Alamat lengkap, Catatan warga.
    - Status aktif pada lini masa (`pending` → `accepted` → `on_the_way` → `picked_up` → `validating` → `completed`).
    - Foto, nama, nomor telepon, dan plat kendaraan armada (muncul setelah `accepted`).
    - Tabel Rincian Item: Nama sampah, harga poin/kg, `estimasi_berat_kg` (Tahap 1), `berat_driver_kg` (Tahap 2 — muncul jika `status >= picked_up`), dan `berat_aktual_kg` (Tahap 3 — muncul jika `status == completed`).
    - Nilai Total Poin Sah (jika `completed`).
11. **User Action**: *Klik Tombol Lihat Peta Realtime*, *Klik Tombol Hubungi Driver (Telepon/WA)*, *Klik Batalkan Order (jika masih `pending`/`accepted`)*.
12. **Business Rules (MUTLAK & KRITIS)**:
    - **Lini Masa 6 Status**: Widget *Timeline Stepper* wajib memperlihatkan 6 titik berurutan:
      1. Menunggu Armada (`pending`)
      2. Armada Ditugaskan (`accepted`)
      3. Menuju Lokasi (`on_the_way`) — *Tombol Lihat Peta Realtime aktif di titik ini*
      4. Sampah Diangkut Driver (`picked_up`) — *Kolom `berat_driver_kg` mulai ditampilkan*
      5. **Sampah Divalidasi Gudang (`validating`)** — *Titik baru untuk memperjelas inspeksi fisik*
      6. Selesai & Poin Masuk (`completed`) — *Kolom `berat_aktual_kg` & Poin Sah ditampilkan*
    - **Otoritas Penimbangan 3 Tahap**: Pada tabel audit item, warga dapat melihat dengan jelas perbedaan antara angka yang dia perkirakan (`estimasi_berat_kg`), angka yang ditimbang driver di depan rumah (`berat_driver_kg`), dan angka final yang disahkan petugas di gudang (`berat_aktual_kg`). Sistem menegaskan dengan label bahwa **Poin Sah hanya dihitung dari `berat_aktual_kg`**.
13. **Empty State**: Tidak berlaku (layar dipanggil dari order ID yang pasti).
14. **Loading State**: Indikator loading putar di tengah layar saat mengambil rincian pesanan dan item dari API.
15. **Error State**: Pesan *"Rincian order tidak ditemukan atau terjadi kesalahan jaringan."*
16. **Data Dependency**: Tabel `orders`, `order_items`, `pengguna (driver)`, `detail_driver`.
17. **API Dependency**: `GET orders_api.php?id_order={id}`, `PUT orders_api.php?action=cancel` (untuk pembatalan).
18. **Future Enhancement**: Fitur komplain/sanggahan otomatis jika selisih antara `berat_driver_kg` dan `berat_aktual_kg` melebihi batas toleransi 20%.

---

#### WRG-007 : Driver Tracking Screen (Peta Tracking Realtime & ETA — *New Screen*)
1. **Screen ID**: `WRG-007`
2. **Screen Name**: `DriverTrackingScreen`
3. **Role**: Warga
4. **Tujuan Screen**: Memberikan pemantauan visual pergerakan armada penjemput menuju rumah warga secara *real-time* bersertakan perkiraan waktu tiba (*Estimated Time of Arrival / ETA*) untuk memberikan kenyamanan dan kepastian operasional.
5. **Deskripsi Singkat**: Halaman peta interaktif baru yang diakses warga saat status order berada pada tahap `on_the_way`. Layar menampilkan peta digital dengan penanda titik rumah warga (*Destination Marker*) dan penanda posisi mobil driver (*Driver Marker*) yang bergerak secara berkala, didukung oleh panel floating di bawah yang menyajikan jarak tersisa (`km`), ETA (`menit`), dan tombol panggilan cepat.
6. **Existing Status**: **New Screen**
7. **Priority**: Medium
8. **Navigation**:
   - *Masuk dari*: Tombol *Lihat Peta Realtime & ETA* di `WRG-006 (OrderDetailScreen)`.
   - *Keluar ke*: Kembali ke `WRG-006 (OrderDetailScreen)`.
9. **Komponen UI**: `AppBar ("Tracking Armada Penjemput")`, `Interactive Map Widget (flutter_map / Google Maps)`, `Custom Marker Icons (Home & Truck)`, `Polyline Route Path`, `Bottom Floating Sheet (ETA & Distance Display)`, `Driver Mini Card (Photo, Name, Plate)`, `Call & WhatsApp Action Buttons`, `Auto-Center Map Button`.
10. **Informasi yang Ditampilkan**: Peta rute, Koordinat aktif driver, Koordinat rumah warga, Angka perkiraan waktu tiba (`ETA: ± X Menit`), Jarak tersisa (`Y KM`), Nama dan plat armada penjemput.
11. **User Action**: *Zoom In/Out Peta*, *Klik Center to Driver*, *Klik Center to Home*, *Klik Hubungi Driver*.
12. **Business Rules**:
    - **Akses Eksklusif Kontekstual**: Layar ini **hanya dapat dibuka ketika `status == 'on_the_way'`**. Jika driver sudah mengubah status menjadi `picked_up` atau pesanan selesai, tombol akses ke layar ini di nonaktifkan.
    - Peta melakukan penyegaran koordinat posisi driver (`latitude_driver`, `longitude_driver`) secara otomatis dari API setiap 10–15 detik atau menggunakan *polling/websocket*.
13. **Empty State**: Tidak berlaku.
14. **Loading State**: Tampilan skeleton peta dan putaran loading *"Memuat lokasi armada..."* saat pertama kali membuka halaman.
15. **Error State**:
    - *Gagal memuat GPS driver*: Toast/Banner *"Lokasi terkini armada belum dapat diperbarui. Mencoba kembali..."*
    - *Koneksi terputus*: Dialog kesalahan jaringan.
16. **Data Dependency**: Tabel `orders`, `detail_driver (current_lat, current_long)`.
17. **API Dependency**: `GET driver_api.php?action=get_location&id_driver={id}`, Paket `latlong2`.
18. **Future Enhancement**: Live chat terintegrasi di dalam halaman tracking dan animasi pergerakan mobil mulus (*Smooth Marker Interpolation*).

---

#### WRG-008 : AI Scan & Education Screen (Deteksi Kamera & Katalog Edukasi)
1. **Screen ID**: `WRG-008`
2. **Screen Name**: `ScanScreen` & `EducationScreen`
3. **Role**: Warga
4. **Tujuan Screen**: Membantu nasabah memilah jenis sampah dengan benar melalui teknologi kecerdasan buatan (*Machine Learning*) serta meningkatkan kesadaran lingkungan melalui artikel edukasi.
5. **Deskripsi Singkat**: `ScanScreen` mengaktifkan kamera perangkat mobile atau galeri foto, kemudian memproses gambar untuk mendeteksi kategori sampah (misal: Plastik PET, Kertas Kardus, Logam Kaleng) serta memberikan perkiraan harga poinnya. `EducationScreen` adalah daftar katalog panduan daur ulang dan berita lingkungan yang dikelola dari Web Admin.
6. **Existing Status**: **Existing**
7. **Priority**: Low
8. **Navigation**:
   - *Masuk dari*: Tombol *Scan AI* atau *Edukasi* di `WRG-003 (HomeScreen)`.
   - *Keluar ke*: `WRG-004 (PickupRequestScreen)` dengan parameter jenis sampah hasil deteksi AI (opsional); atau kembali ke beranda.
9. **Komponen UI**: `Camera Viewfinder`, `Capture Shutter Button`, `Gallery Picker Button`, `ML Result Modal Bottom Sheet (Classification Label, Confidence Score, Estimated Points)`, `ListView / GridView (Articles)`, `Article Detail Card / Reader View`.
10. **Informasi yang Ditampilkan**: Pratinjau kamera, Hasil prediksi AI (Nama Sampah, Akurasi %), Tips pemilahan, Judul & isi lengkap artikel edukasi.
11. **User Action**: *Arahkan Kamera*, *Klik Ambil Foto*, *Pilih Foto dari Galeri*, *Klik Gunakan Jenis Ini untuk Jemputan*, *Baca Artikel*.
12. **Business Rules**: Hasil klasifikasi AI hanya sebagai rekomendasi visual. Warga tetap berhak menyesuaikan jenis item sampah secara manual pada layar `PickupRequestScreen`.
13. **Empty State**: Daftar artikel kosong jika Web Admin belum menerbitkan konten edukasi.
14. **Loading State**: Animasi pemindaian laser (*Scanning Laser Animation*) saat gambar dikirim ke endpoint model AI.
15. **Error State**: Dialog *"Gagal mengenali gambar sampah. Pastikan pencahayaan cukup atau pilih jenis sampah secara manual."*
16. **Data Dependency**: Tabel `jenis_sampah`, `edukasi`.
17. **API Dependency**: `POST detect.php (payload: image file / base64)`, `GET edukasi.php`.
18. **Future Enhancement**: Pemindaian barcode produk kemasan untuk langsung mengenali bahan material daur ulangnya.

---

#### WRG-009 : Alerts & Reward Screen (Daftar Notifikasi & Histori Saldo Poin)
1. **Screen ID**: `WRG-009`
2. **Screen Name**: `AlertsScreen` & `RewardHistoryScreen`
3. **Role**: Warga
4. **Tujuan Screen**: Menyajikan pemberitahuan langsung kepada warga mengenai setiap perubahan tahapan status jemputan dan merangkum riwayat penambahan saldo poin secara transparan.
5. **Deskripsi Singkat**: Halaman pusat pemberitahuan yang diakses melalui navigasi bawah tab ke-3. Menampilkan daftar pesan kronologis yang dibagi dalam filter tab (*Semua Notifikasi* vs *Riwayat Poin Masuk*). Setiap pesan memiliki ikon pembeda berdasarkan tipe kejadiannya (Transisi Status vs Reward Poin).
6. **Existing Status**: **Need Revision** *(Perlu penyelarasan redaksi pesan otomatis saat pesanan beralih ke `validating` dan `completed`)*
7. **Priority**: High
8. **Navigation**:
   - *Masuk dari*: Tab 3 `MainNavigationScreen` atau ikon lonceng di `HomeScreen`.
   - *Keluar ke*: `WRG-006 (OrderDetailScreen)` saat item notifikasi ditekan.
9. **Komponen UI**: `AppBar ("Notifikasi & Reward")`, `Filter Tab / Filter Chips (Semua, Status Order, Poin Masuk)`, `ListView`, `Notification Card / ListTile`, `Category Icons (Check Circle, Truck, Coin/Gift)`, `Unread Badge Indicator`, `Mark All as Read Button`.
10. **Informasi yang Ditampilkan**: Judul pemberitahuan, Isi ringkas pesan, Waktu penerimaan (*Time Ago*), Indikator status baca (*Read / Unread*).
11. **User Action**: *Klik Tab Filter*, *Klik Item Notifikasi (langsung mengarahkan ke `OrderDetailScreen` terkait)*, *Klik Tandai Semua Dibaca*.
12. **Business Rules**:
    - **Otomasi Pesan Status**: Sistem wajib menampilkan pesan notifikasi resmi sesuai transisi:
      - Saat `accepted`: *"Armada [Nama Driver] telah ditugaskan untuk jemputan #ORD-XXXX."*
      - Saat `on_the_way`: *"Armada sedang dalam perjalanan menuju lokasi Anda."*
      - Saat `picked_up`: *"Sampah telah diangkut oleh Driver. Menuju ke Bank Sampah."*
      - Saat `validating`: *"Sampah tiba di gudang dan sedang divalidasi oleh petugas."*
      - Saat `completed`: **"Reward Poin Berhasil Ditambahkan! Anda menerima +[X] Poin dari penjemputan #ORD-XXXX berdasarkan hasil timbang akhir gudang ([Y] kg)."**
13. **Empty State**: Ilustrasi lonceng bersih dengan teks *"Belum ada pemberitahuan baru untuk Anda."*
14. **Loading State**: Tampilan 5 baris skeleton loading (*Shimmer List*).
15. **Error State**: Teks *"Gagal memuat notifikasi. Periksa koneksi internet Anda."*
16. **Data Dependency**: Tabel `notifikasi`.
17. **API Dependency**: `GET notifikasi_api.php?id_pengguna={id}`, `PUT notifikasi_api.php?action=mark_read`.
18. **Future Enhancement**: Pengaturan preferensi notifikasi (*Push Notification Toggle* via Firebase FCM).

---

#### WRG-010 : Profile Screen (Profil & Pengaturan Akun)
1. **Screen ID**: `WRG-010`
2. **Screen Name**: `ProfileScreen`
3. **Role**: Warga
4. **Tujuan Screen**: Memungkinkan nasabah mengelola identitas diri, memperbarui alamat penjemputan default, melihat statistik singkat akun, dan mengakhiri sesi login secara aman.
5. **Deskripsi Singkat**: Layar pengaturan akun yang diakses melalui navigasi bawah tab ke-4. Menampilkan foto profil, nama lengkap, nomor telepon, alamat default, serta menu-menu administratif seperti *Ubah Profil*, *Bantuan/FAQ*, *Tentang Aplikasi*, dan tombol merah *Keluar (Logout)*.
6. **Existing Status**: **Existing**
7. **Priority**: Medium
8. **Navigation**:
   - *Masuk dari*: Tab 4 `MainNavigationScreen`.
   - *Keluar ke*: `WRG-002 (LoginScreen)` setelah klik *Logout*; atau ke form *Ubah Profil*.
9. **Komponen UI**: `AppBar ("Profil Saya")`, `Profile Avatar & Edit Photo Button`, `User Info Header Card`, `ListView / Menu Settings Tiles (Ubah Profil, Alamat Default, FAQ, Tentang, Logout)`, `Edit Profile Modal / Screen`, `Logout Confirmation Dialog`.
10. **Informasi yang Ditampilkan**: Foto profil, Nama Lengkap, Username, Nomor Telepon, Alamat Domisili, Versi Aplikasi (`v1.0.0`).
11. **User Action**: *Klik Ubah Foto Profil*, *Klik Ubah Data Diri*, *Input Nama/Alamat Baru & Simpan*, *Klik FAQ/Tentang*, *Klik Tombol Keluar / Logout*.
12. **Business Rules**:
    - Perubahan alamat domisili di `ProfileScreen` akan otomatis menjadi alamat penjemputan default saat warga membuka form `PickupRequestScreen`.
    - Saat konfirmasi *Logout* disetujui, sistem wajib menghapus `api_token` dari `SharedPreferences` dan mengembalikan pengguna ke `WRG-002 (LoginScreen)`.
13. **Empty State**: Tidak berlaku (selalu ada data user yang login).
14. **Loading State**: Putaran loading saat memperbarui data profil via API PUT.
15. **Error State**: Snackbar *"Gagal memperbarui profil. Nomor telepon mungkin sudah digunakan."*
16. **Data Dependency**: Tabel `pengguna`.
17. **API Dependency**: `GET profile_api.php?id={id}`, `PUT profile_api.php`.
18. **Future Enhancement**: Fitur hapus akun mandiri sesuai regulasi privasi data (*Account Deletion Request*).

---

### B. AKTOR DRIVER (`DRV-***` — Aplikasi Mobile Flutter)

#### DRV-001 : Driver Auth Screens
1. **Screen ID**: `DRV-001`
2. **Screen Name**: `LoginScreen` (Driver)
3. **Role**: Driver
4. **Tujuan Screen**: Memastikan hanya armada penjemput resmi yang berwenang yang dapat mengakses portal komando penugasan lapangan.
5. **Deskripsi Singkat**: Layar login berdesain tegas khusus armada driver. Meminta masukan *username/nomor telepon* dan *kata sandi* yang diverifikasi ke tabel `pengguna` dengan syarat `level = 'driver'`.
6. **Existing Status**: **Existing**
7. **Priority**: High
8. **Navigation**:
   - *Masuk dari*: Launching Aplikasi `Halaman-Driver`.
   - *Keluar ke*: `DRV-002 (DashboardScreen)`.
9. **Komponen UI**: `AppBar (Driver Theme Header)`, `TextFormField (Username/Phone & Password)`, `Password Visibility Toggle`, `Primary Login Button ("Masuk sebagai Driver")`, `Error Snackbar`.
10. **Informasi yang Ditampilkan**: Logo Driver Bank Sampah, Form kredensial, Pesan error autentikasi.
11. **User Action**: *Input Kredensial Driver*, *Klik Masuk*.
12. **Business Rules**: Akun warga biasa (`level = 'warga'`) yang mencoba login pada aplikasi `Halaman-Driver` akan ditolak oleh sistem dengan pesan khusus.
13. **Empty State**: Form kosong saat dibuka.
14. **Loading State**: Indikator loading pada tombol saat memvalidasi sesi ke server.
15. **Error State**: Snackbar *"Akses Ditolak: Akun ini tidak terdaftar sebagai Armada Driver Bank Sampah."*
16. **Data Dependency**: Tabel `pengguna (level = 'driver')`.
17. **API Dependency**: `POST auth_api.php?action=login`.
18. **Future Enhancement**: Pemindaian ID Card Driver berbasis QR Code untuk absen harian.

---

#### DRV-002 : Dashboard Screen (Dasbor Tugas Aktif — *Active Tasks*)
1. **Screen ID**: `DRV-002`
2. **Screen Name**: `DashboardScreen`
3. **Role**: Driver
4. **Tujuan Screen**: Menjadi pusat kendali operasional harian armada yang menampilkan pesanan baru siap jemput di wilayah kerja dan pesanan yang sedang dijalankan oleh armada tersebut.
5. **Deskripsi Singkat**: Layar utama aplikasi `Halaman-Driver`. Menampilkan header profil armada beserta tombol *Ready/Online Toggle*. Di bawahnya terdapat bilah tab kritis: **Tab "Tugas Pending"** (daftar pesanan baru berstatus `pending` dari seluruh warga yang siap diambil) dan **Tab "Tugas Saya (*My Tasks*)"** (daftar pesanan berstatus `accepted` atau `on_the_way` yang sedang ditangani oleh driver bersangkutan).
6. **Existing Status**: **Existing**
7. **Priority**: **Critical**
8. **Navigation**:
   - *Masuk dari*: `DRV-001 (LoginScreen)`.
   - *Keluar ke*: `DRV-003 (PickupDetailScreen)` saat kartu tugas diklik.
9. **Komponen UI**: `AppBar (Driver Info & Online Toggle Switch)`, `TabBar (Tugas Pending vs Tugas Saya)`, `ListView`, `Task Card (Order ID, Customer Address, Schedule, Est. Weight)`, `Action Button ("Terima Tugas" / "Lihat Detail")`, `Pull-to-Refresh`.
10. **Informasi yang Ditampilkan**: Status ketersediaan armada, Jumlah tugas pending, Jumlah tugas aktif, Rincian singkat kartu pesanan (Alamat, Jarak perkiraan, Waktu jemput, Perkiraan berat muatan).
11. **User Action**: *Klik Toggle Online/Offline*, *Klik Tab Filter*, *Klik Tombol Terima Tugas*, *Klik Kartu Tugas untuk Detail*, *Pull-to-Refresh*.
12. **Business Rules (MUTLAK & KRITIS)**:
    - **Pengambilan Tugas (*Task Acceptance & Binding*)**: Saat driver menekan tombol **"Terima Tugas"** pada kartu di Tab Pending, sistem mengirim `PUT orders_api.php` yang mengubah `orders.status = 'accepted'` dan mengikat `orders.id_driver = [id_driver_aktif]`.
    - Pesanan yang telah berstatus `accepted` akan hilang dari Tab Pending seluruh driver lain dan resmi berpindah ke Tab *"Tugas Saya"* milik driver tersebut.
13. **Empty State**: 
    - *Tab Pending Kosong*: Ilustrasi truk santai dengan teks *"Belum ada pesanan penjemputan baru di wilayah Anda."*
    - *Tab My Tasks Kosong*: Teks *"Anda belum mengambil tugas penjemputan. Pilih dari tab Tugas Pending."*
14. **Loading State**: Tampilan kartu kerangka bayangan (*Shimmer Cards*) saat mengambil daftar tugas dari `driver_api.php`.
15. **Error State**: Teks *"Gagal memuat daftar tugas. Periksa koneksi jaringan Anda."*
16. **Data Dependency**: Tabel `orders`, `pengguna (warga)`, `detail_driver`.
17. **API Dependency**: `GET driver_api.php?action=get_active_task`, `PUT orders_api.php (status: accepted, id_driver: active_id)`.
18. **Future Enhancement**: Pembagian tugas penjemputan otomatis berdasarkan radius jarak terdekat berbasis algoritmik (*Automated Radius Dispatch*).

---

#### DRV-003 : Pickup Detail Screen (Detail Jemput, Alamat & Navigasi Google Maps)
1. **Screen ID**: `DRV-003`
2. **Screen Name**: `PickupDetailScreen`
3. **Role**: Driver
4. **Tujuan Screen**: Memberikan rincian kontak dan navigasi rute lengkap kepada armada driver menuju titik rumah warga, serta menyediakan tombol pemicu transisi status perjalanan.
5. **Deskripsi Singkat**: Layar rincian tugas yang memandu driver di jalan. Menampilkan nama nasabah, nomor telepon yang dapat langsung ditelepon, peta pratinjau alamat, daftar item sampah dan estimasi berat yang dilaporkan warga, serta tombol aksi utama yang berubah secara dinamis sesuai status pesanan.
6. **Existing Status**: **Existing**
7. **Priority**: High
8. **Navigation**:
   - *Masuk dari*: `DRV-002 (DashboardScreen)`.
   - *Keluar ke*: Aplikasi navigasi eksternal (Google Maps) atau `DRV-004 (PickupVerificationScreen)` saat tiba di lokasi.
9. **Komponen UI**: `AppBar ("Detail Tugas #ORD-XXXX")`, `Customer Contact Card (Name, Phone, Direct Call/WA Button)`, `Address & Location Card`, `Open Google Maps Navigation Button (External Launcher)`, `Items List Section (Estimasi Warga)`, `Fixed Bottom Action Button (Dynamic Label)`.
10. **Informasi yang Ditampilkan**: Nomor Order, Nama & Telepon Warga, Alamat Jemput & Koordinat Peta, Rincian item estimasi (`estimasi_berat_kg`), Catatan dari warga untuk driver.
11. **User Action**: *Klik Telepon/WA Warga*, *Klik Buka Google Maps*, *Klik Tombol "Mulai Menuju Lokasi" (`on_the_way`)*, *Klik Tombol "Tiba di Lokasi (Mulai Penimbangan)"*.
12. **Business Rules**:
    - **Transisi Dinamis**: 
      - Jika status pesanan `accepted`: Tombol bawah bertuliskan **"Mulai Menuju Lokasi (`on_the_way`)"**. Saat ditekan, status order berubah ke `on_the_way` dan sistem mulai mengirim koordinat armada ke server untuk fitur tracking warga.
      - Jika status pesanan `on_the_way`: Tombol bawah bertuliskan **"Tiba di Lokasi (Mulai Penimbangan)"**. Saat ditekan, driver langsung diarahkan ke layar `DRV-004 (PickupVerificationScreen)`.
    - Tombol *Buka Google Maps* memanggil `url_launcher` dengan parameter `google.navigation:q={latitude},{longitude}`.
13. **Empty State**: Tidak berlaku.
14. **Loading State**: Putaran loading saat memperbarui status ke `on_the_way` di server.
15. **Error State**: Snackbar *"Gagal memperbarui status perjalanan. Coba lagi."*
16. **Data Dependency**: Tabel `orders`, `order_items`, `pengguna (warga)`.
17. **API Dependency**: `PUT orders_api.php (status: on_the_way)`, Paket `url_launcher` & `latlong2`.
18. **Future Enhancement**: Optimalisasi rute penjemputan multi-titik dalam satu kali jalan (*Multi-Stop Route Optimization*).

---

#### DRV-004 : Pickup Verification Screen (Form Timbang Awal Lapangan — Tahap 2)
1. **Screen ID**: `DRV-004`
2. **Screen Name**: `PickupVerificationScreen`
3. **Role**: Driver
4. **Tujuan Screen**: Memfasilitasi armada driver mencatat hasil penimbangan awal fisik di depan rumah warga sebagai bukti serah terima lapangan sebelum muatan diangkut ke kendaraan.
5. **Deskripsi Singkat**: Formulir verifikasi lapangan yang sangat penting. Layar ini menampilkan setiap jenis item sampah yang diajukan oleh warga bersertakan angka perkiraan warga (`estimasi_berat_kg` - Tahap 1). Driver disediakan kolom input khusus untuk mengisi **`berat_driver_kg` (Tahap 2)** berdasarkan timbangan gantung/timbangan digital lapangan yang dibawa di armada. Selain itu, terdapat fitur pengambilan foto bukti tumpukan sampah dan kolom catatan driver.
6. **Existing Status**: **Need Revision** *(Perlu penyesuaian penambahan input `berat_driver_kg` untuk setiap item yang diangkut)*
7. **Priority**: **Critical**
8. **Navigation**:
   - *Masuk dari*: Tombol *Tiba di Lokasi* di `DRV-003 (PickupDetailScreen)`.
   - *Keluar ke*: `DRV-005 (WarehouseHandoverScreen)` atau kembali ke `DRV-002 (DashboardScreen)` setelah muatan diangkut.
9. **Komponen UI**: `AppBar ("Verifikasi & Timbang Lapangan")`, `Form`, `Dynamic Item Comparison Cards (Nama Sampah + Teks Estimasi Warga KG + Number TextFormField Berat Driver KG)`, `Camera / Image Picker Widget (Foto Bukti Pengambilan)`, `TextFormField (Catatan Lapangan Driver)`, `Primary Submit Button ("Konfirmasi Angkut Sampah (`picked_up`)")`.
10. **Informasi yang Ditampilkan**: Daftar item sampah order, Angka perbandingan `estimasi_berat_kg` (Tahap 1), Form input `berat_driver_kg` (Tahap 2), Pratinjau foto bukti terunggah, Peringatan aturan bisnis lapangan.
11. **User Action**: *Input Angka Berat Driver (`berat_driver_kg`) per Item*, *Klik Ambil Foto dari Kamera*, *Tulis Catatan Lapangan (jika ada selisih/sampah basah)*, *Klik Konfirmasi Angkut Sampah*.
12. **Business Rules (MUTLAK & KRITIS)**:
    - Driver **wajib mengisi kolom `berat_driver_kg`** untuk setiap item yang diangkut dengan nilai $> 0$.
    - **Otoritas Penimbangan Tahap 2**: Angka `berat_driver_kg` yang diinput oleh armada adalah **bukti fisik serah terima lapangan dari warga ke driver**.
    - **LARANGAN MUTLAK**: Angka `berat_driver_kg` ini **TIDAK BOLEH MEMUTASI ATAU MENAMBAH SALDO POIN** di tabel `pengguna.saldo`. Angka ini hanya disimpan di kolom `order_items.berat_driver_kg` untuk kebutuhan audit dan verifikasi akhir di gudang Bank Sampah.
    - Saat tombol *Konfirmasi Angkut Sampah* ditekan, sistem mengirim `PUT orders_api.php` yang memperbarui status menjadi `picked_up` (`orders.status = 'picked_up'`).
13. **Empty State**: Tidak berlaku (daftar item diisi berdasarkan pesanan).
14. **Loading State**: Indikator loading saat mengunggah foto bukti dan mengirim data timbang lapangan ke server.
15. **Error State**:
    - *Berat kosong*: Dialog *"Mohon isi angka penimbangan lapangan (`berat_driver_kg`) untuk semua item muatan."*
    - *Gagal Unggah*: Snackbar *"Gagal mengunggah foto bukti. Periksa koneksi jaringan."*
16. **Data Dependency**: Tabel `orders`, `order_items`.
17. **API Dependency**: `PUT orders_api.php (payload: items[] with berat_driver_kg, foto_bukti, catatan_driver, status: picked_up)`.
18. **Future Enhancement**: Integrasi koneksi Bluetooth dari timbangan digital lapangan ke aplikasi driver untuk auto-input angka berat.

---

#### DRV-005 : Warehouse Handover Screen (Serah Terima Gudang `validating` — *New Screen*)
1. **Screen ID**: `DRV-005`
2. **Screen Name**: `WarehouseHandoverScreen`
3. **Role**: Driver
4. **Tujuan Screen**: Memberikan batas tanggung jawab operasional yang jelas dengan memungkinkan driver mencatat momen penyerahan muatan fisik sampah dari kendaraan armada ke petugas verifikator di gudang Bank Sampah.
5. **Deskripsi Singkat**: Layar konfirmasi ketibaan armada di area gudang Bank Sampah. Menampilkan ringkasan total muatan lapangan yang dibawa driver (`berat_driver_kg`), nama petugas gudang yang menerima, pernyataan serah terima muatan, serta tombol penegasan **"Serahkan Muatan ke Gudang (`validating`)"**.
6. **Existing Status**: **New Screen** *(Fitur baru krusial hasil penyelarasan alur bisnis)*
7. **Priority**: **Critical**
8. **Navigation**:
   - *Masuk dari*: `DRV-004 (PickupVerificationScreen)` setelah angkut, atau dari kartu order `picked_up` di Dasbor Driver.
   - *Keluar ke*: `DRV-002 (DashboardScreen)` dengan pemberitahuan bahwa tugas penjemputan armada telah selesai dilimpahkan ke gudang.
9. **Komponen UI**: `AppBar ("Serah Terima Gudang")`, `Summary Card (Order ID, Customer Name, Total Berat Driver KG)`, `Warehouse Info Card (Nama Bank Sampah & Verifikator)`, `Handover Checkbox ("Saya menyatakan muatan telah diturunkan dan diserahkan ke gudang")`, `Primary Action Button ("Serahkan Muatan ke Gudang (`validating`)")`.
10. **Informasi yang Ditampilkan**: Ringkasan ID Order, Nama nasabah penyetor, Total `berat_driver_kg` yang diangkut, Lokasi gudang tujuan, Checkbox konfirmasi serah terima.
11. **User Action**: *Centang Checkbox Konfirmasi*, *Klik Tombol Serahkan Muatan ke Gudang*.
12. **Business Rules (MUTLAK & KRITIS)**:
    - Tombol *Serahkan Muatan ke Gudang* akan mengubah status pesanan dari `picked_up` menjadi `validating` (`orders.status = 'validating'`).
    - Sesaat setelah status berubah ke `validating`:
      1. Tanggung jawab armada driver terhadap barang fisik dinyatakan **selesai**.
      2. Order tersebut hilang dari antrean aktif driver dan berpindah sepenuhnya ke antrean penimbangan akhir petugas di portal Web Admin (`ADM-003`).
      3. Warga menerima notifikasi otomatis bahwa sampah mereka sedang divalidasi di gudang.
13. **Empty State**: Tidak berlaku.
14. **Loading State**: Putaran loading saat mengeksekusi transisi status `validating` ke API.
15. **Error State**: Snackbar *"Gagal mencatat serah terima gudang. Coba lagi."*
16. **Data Dependency**: Tabel `orders`, `order_items`, `detail_driver`.
17. **API Dependency**: `PUT orders_api.php (status: validating)`.
18. **Future Enhancement**: Tanda tangan digital (*Digital Signature / E-Sign*) pada layar perangkat driver oleh petugas gudang saat menerima muatan.

---

#### DRV-006 : Schedule & History Screen (Jadwal Mendatang & Riwayat Tugas Armada)
1. **Screen ID**: `DRV-006`
2. **Screen Name**: `ScheduleScreen` & `HistoryScreen`
3. **Role**: Driver
4. **Tujuan Screen**: Membantu armada memantau jadwal penjemputan hari esok/mendatang serta mengarsip rekam jejak tugas penjemputan yang telah berhasil diselesaikan atau diserahkan ke gudang.
5. **Deskripsi Singkat**: Layar riwayat dan penjadwalan armada. `ScheduleScreen` menampilkan daftar pesanan yang dijadwalkan untuk hari berikutnya di wilayah operasi driver. `HistoryScreen` memuat daftar pesanan yang telah tuntas diserahkan (`validating` / `completed`) lengkap dengan rincian alamat dan catatan `berat_driver_kg` yang telah diangkut.
6. **Existing Status**: **Existing**
7. **Priority**: Medium
8. **Navigation**:
   - *Masuk dari*: Menu navigasi samping / tab di `DRV-002 (DashboardScreen)`.
   - *Keluar ke*: `DRV-003 (PickupDetailScreen)` untuk melihat rincian arsip tugas.
9. **Komponen UI**: `AppBar ("Jadwal & Riwayat Tugas")`, `TabBar (Jadwal vs Riwayat Selesai)`, `ListView`, `History Task Card (Status Label, Date, Customer, Berat Driver KG)`, `Filter by Date Picker`, `Pull-to-Refresh`.
10. **Informasi yang Ditampilkan**: Daftar tanggal & waktu jemput mendatang, Daftar pesanan selesai (`completed`/`validating`), Angka total muatan `berat_driver_kg` yang berhasil diangkut armada.
11. **User Action**: *Klik Tab Filter*, *Pilih Filter Tanggal*, *Klik Kartu untuk Lihat Rincian*, *Pull-to-Refresh*.
12. **Business Rules**: Pesanan yang ditampilkan pada `HistoryScreen` driver adalah pesanan yang `id_driver`-nya cocok dengan sesi armada dan statusnya telah mencapai tahap `validating` atau `completed`.
13. **Empty State**: Tampilan ikon riwayat bersih dengan teks *"Belum ada tugas penjemputan yang selesai pada rentang tanggal ini."*
14. **Loading State**: Tampilan 4 kartu kerangka bayangan (*Shimmer Cards*).
15. **Error State**: Teks pemberitahuan error jaringan.
16. **Data Dependency**: Tabel `orders`, `order_items`.
17. **API Dependency**: `GET driver_api.php?action=get_history&id_driver={id}`.
18. **Future Enhancement**: Rekapitulasi insentif operasional driver berdasarkan total kilogram muatan yang berhasil dijemput setiap bulan.

---

#### DRV-007 : Alerts & Profile Screen (Notifikasi Tugas & Profil Armada)
1. **Screen ID**: `DRV-007`
2. **Screen Name**: `AlertsScreen` & `ProfileScreen` (Driver)
3. **Role**: Driver
4. **Tujuan Screen**: Menyampaikan pemberitahuan tugas baru dari sistem dan memungkinkan armada mengelola identitas profil serta spesifikasi kendaraan penjemput.
5. **Deskripsi Singkat**: `AlertsScreen` adalah daftar pesan masuk untuk driver (misal: penugasan baru dari admin, perubahan jadwal oleh warga). `ProfileScreen` menampilkan foto armada, nama, nomor telepon, informasi spesifikasi kendaraan (Plat Nomor, Tipe Truk/Motor, Kapasitas Muatan KG), serta tombol merah untuk keluar dari akun (`Logout`).
6. **Existing Status**: **Existing**
7. **Priority**: Low
8. **Navigation**:
   - *Masuk dari*: Menu profil/alert di Dasbor Driver.
   - *Keluar ke*: `DRV-001 (LoginScreen)` setelah *Logout*; atau ke rincian tugas.
9. **Komponen UI**: `AppBar ("Profil Armada")`, `Driver Profile Card`, `Vehicle Specification Card (Plat, Tipe, Kapasitas)`, `ListView (Alerts)`, `Logout Confirmation Dialog`.
10. **Informasi yang Ditampilkan**: Nama Driver, Nomor Telepon, Spesifikasi Kendaraan (`plat_nomor`, `tipe_kendaraan`, `kapasitas_kg`), Daftar notifikasi tugas.
11. **User Action**: *Klik Notifikasi Tugas*, *Klik Tombol Keluar (Logout)*.
12. **Business Rules**: Saat *Logout* dikonfirmasi, sistem menghapus `api_token` driver dari `SharedPreferences` dan mengarahkan kembali ke `DRV-001`.
13. **Empty State**: Notifikasi kosong jika tidak ada pesan tugas baru.
14. **Loading State**: Putaran loading saat memuat data kendaraan.
15. **Error State**: Pesan error jika gagal memuat profil kendaraan.
16. **Data Dependency**: Tabel `pengguna`, `detail_driver`.
17. **API Dependency**: `GET profile_api.php`, `GET notifikasi_api.php`.
18. **Future Enhancement**: Pelaporan kondisi peremajaan dan perawatan rutin kendaraan armada langsung dari aplikasi.

---

### C. AKTOR PETUGAS BANK SAMPAH (`ADM-***` — Web Admin PHP Native)

#### ADM-001 : Admin Login Page
1. **Screen ID**: `ADM-001`
2. **Screen Name**: `auth/login` (Web Admin Login)
3. **Role**: Petugas Bank Sampah (Web Admin / Verifikator Gudang)
4. **Tujuan Screen**: Mengamankan portal administrasi Bank Sampah Bersinar dari akses yang tidak sah.
5. **Deskripsi Singkat**: Halaman login berbasis web PHP Native dengan tata letak bersih dan profesional. Meminta masukan *username* dan *password* yang diverifikasi ke tabel `pengguna` dengan syarat `level IN ('admin', 'petugas')`.
6. **Existing Status**: **Existing**
7. **Priority**: High
8. **Navigation**:
   - *Masuk dari*: Mengakses URL portal `index.php`.
   - *Keluar ke*: `ADM-002 (Executive Dashboard)` setelah login sukses.
9. **Komponen UI**: `Web Login Card`, `Text Input (Username & Password)`, `Primary Web Button ("Masuk ke Portal Admin")`, `Alert Box (Error Notification)`.
10. **Informasi yang Ditampilkan**: Logo & Judul Portal Admin Bank Sampah, Form input kredensial, Pesan error login.
11. **User Action**: *Input Kredensial*, *Klik Tombol Masuk*.
12. **Business Rules**: Setelah login berhasil, sistem PHP memulai sesi (`$_SESSION['user'] = ...`) untuk mengontrol akses ke seluruh modul halaman `index.php?page=...`.
13. **Empty State**: Form kosong.
14. **Loading State**: Indikator loading pada tombol saat memproses login.
15. **Error State**: Alert Box merah *"Kredensial salah atau Anda tidak memiliki hak akses sebagai Admin/Petugas."*
16. **Data Dependency**: Tabel `pengguna (level IN ('admin', 'petugas'))`.
17. **API Dependency**: Kueri `SELECT * FROM pengguna WHERE username = ? AND password = ?`.
18. **Future Enhancement**: Log aktivitas keamanan masuk (*Audit Trail Login History*) untuk melacak IP petugas.

---

#### ADM-002 : Executive Dashboard (Dasbor Statistik Operasional)
1. **Screen ID**: `ADM-002`
2. **Screen Name**: `dashboard` (Executive Dashboard)
3. **Role**: Petugas Bank Sampah (Web Admin)
4. **Tujuan Screen**: Memberikan ikhtisar eksekutif dan statistik kinerja operasional Bank Sampah secara menyeluruh dan real-time kepada pengelola.
5. **Deskripsi Singkat**: Halaman utama sesaat setelah login ke Web Admin. Menampikan 4 kartu metrik utama di bagian atas (Total Warga Terdaftar, Total Armada Driver, Order Jemputan Aktif, dan Total Poin Terverifikasi), didukung oleh grafik statistik penjemputan bulanan serta tabel ringkas pesanan terbaru yang membutuhkan tindakan verifikasi.
6. **Existing Status**: **Existing**
7. **Priority**: Medium
8. **Navigation**:
   - *Masuk dari*: `ADM-001 (Admin Login)` atau klik menu Dasbor di Sidebar.
   - *Keluar ke*: `ADM-003 (Orders Management Table)` saat mengklik kartu pesanan aktif.
9. **Komponen UI**: `Sidebar Navigation`, `Top Navbar (Admin Profile)`, `Metric Cards / Stat Boxes (4 Columns)`, `Interactive Chart / Graph (Chart.js / ApexCharts)`, `Recent Orders Table Summary`, `Quick Action Buttons`.
10. **Informasi yang Ditampilkan**: Angka statistik total pengguna & transaksi, Grafik tren penyetoran sampah (kg/poin), 5 pesanan terbaru berstatus `pending` atau `validating`.
11. **User Action**: *Klik Menu Sidebar*, *Klik Kartu Metrik*, *Filter Rentang Grafik*, *Klik Tombol "Validasi Sekarang" pada tabel ringkas*.
12. **Business Rules**: Angka metrik *Total Poin Terverifikasi* dan statistik sampah hanya dihitung dari pesanan yang telah disahkan berstatus `completed`.
13. **Empty State**: Jika belum ada transaksi sama sekali, grafik menampilkan angka nol/kosong dengan ilustrasi bersih.
14. **Loading State**: Spinner loading pada area grafik saat memuat data statistik dari MySQL.
15. **Error State**: Pesan *"Gagal memuat statistik dasbor."*
16. **Data Dependency**: Tabel `pengguna`, `orders`, `order_items`.
17. **API Dependency**: Kueri agregasi `SELECT COUNT(*), SUM(...) FROM ...`.
18. **Future Enhancement**: Prediksi lonjakan volume sampah tahunan berbasis analisis regresi.

---

#### ADM-003 : Orders Management Table (Tabel Manajemen Jemputan & Penugasan Driver)
1. **Screen ID**: `ADM-003`
2. **Screen Name**: `orders/data` (Orders Management Table)
3. **Role**: Petugas Bank Sampah (Web Admin)
4. **Tujuan Screen**: Menjadi pusat komando pengelola gudang dalam memonitor seluruh transaksi jemputan, melakukan penugasan armada driver secara manual, dan menyeleksi pesanan yang siap divalidasi akhir.
5. **Deskripsi Singkat**: Halaman tabel berfilter lengkap pada Web Admin (`modules/orders/index.php`). Memiliki bilah filter untuk ke-6 status resmi (`Semua`, `pending`, `accepted`, `on_the_way`, `picked_up`, `validating`, `completed`). Untuk pesanan `pending`, tabel menyediakan *Dropdown Assign Driver* untuk memilih armada. Untuk pesanan berstatus `validating` (atau `picked_up`), tabel menyediakan tombol aksi hijau tajam **"Validasi Timbang Akhir"** yang akan memunculkan Modal Timbang Final (`ADM-004`).
6. **Existing Status**: **Need Revision** *(Perlu penambahan tab filter & pemetaan warna untuk status baru `validating`)*
7. **Priority**: **Critical**
8. **Navigation**:
   - *Masuk dari*: Menu Sidebar "Data Penjemputan (`orders/data`)".
   - *Keluar ke*: `ADM-004 (Warehouse Final Weighing Modal)` saat tombol Validasi diklik.
9. **Komponen UI**: `Sidebar Menu`, `Top Navbar`, `Status Filter Tabs / Buttons (6 Status)`, `Search Box (Cari ID / Warga / Driver)`, `DataTables / Responsive Table`, `Status Badge Labels`, `Assign Driver Dropdown + Submit Button`, `Action Button ("Validasi Timbang Akhir")`, `Pagination Controls`.
10. **Informasi yang Ditampilkan**: ID Order (`#ORD-XXXX`), Tanggal buat, Nama Warga & Alamat, Armada Driver Ditugaskan, Label Status (`pending` → `completed`), Ringkasan angka berat (`estimasi_berat_kg` vs `berat_driver_kg`), Tombol Aksi.
11. **User Action**: *Klik Filter Status (`validating`)*, *Cari Order ID*, *Pilih Driver di Dropdown & Klik Assign*, *Klik Tombol "Validasi Timbang Akhir"*.
12. **Business Rules**:
    - **Penugasan Armada (*Manual Dispatch*)**: Pesanan berstatus `pending` dapat dipasangkan dengan driver melalui dropdown. Saat disimpan, status berubah menjadi `accepted` dan order masuk ke aplikasi driver bersangkutan.
    - **Pemicu Verifikasi Gudang**: Tombol **"Validasi Timbang Akhir"** diprioritaskan muncul dengan warna hijau tajam pada baris order berstatus `validating` (atau `picked_up`), sebagai penanda bahwa muatan telah tiba di gudang dan siap diperiksa.
13. **Empty State**: Tabel menampilkan satu baris kosong *"Tidak ada data pesanan pada filter status ini."*
14. **Loading State**: Tabel memuat animasi *Processing / Skeleton Loader* saat mengganti filter status.
15. **Error State**: Alert box merah jika terjadi kesalahan kueri database.
16. **Data Dependency**: Tabel `orders JOIN pengguna JOIN order_items`.
17. **API Dependency**: Kueri `SELECT ... JOIN ... WHERE status = ?`, Kueri `UPDATE orders SET id_driver = ?, status = 'accepted' WHERE id_order = ?`.
18. **Future Enhancement**: Pemutakhiran status tabel secara *real-time via Ajax Polling* tanpa perlu refresh halaman.

---

#### ADM-004 : Warehouse Final Weighing Modal (Modal Timbang Final Gudang — Tahap 3 & Atomic ACID Completion)
1. **Screen ID**: `ADM-004`
2. **Screen Name**: `orders/verify_modal` (Warehouse Final Weighing & Completion Modal)
3. **Role**: Petugas Bank Sampah (Web Admin / Verifikator Gudang)
4. **Tujuan Screen / Komponen**: Memastikan petugas gudang melakukan penimbangan fisik ulang yang akurat dan mengaudit perbedaan berat muatan sebelum sistem mengkalkulasi dan menyalurkan reward poin secara sah ke akun warga melalui transaksi database yang amat aman (*Atomic ACID Transaction*).
5. **Deskripsi Singkat**: Komponen modal pop-up atau halaman form verifikasi akhir yang menjadi **gerbang penentuan hak poin warga (*Final Truth & Single Source of Truth for Reward*)**. Saat dibuka, modal menyajikan tabel audit bersanding: kolom Estimasi Warga (`estimasi_berat_kg` - Tahap 1), kolom Timbang Driver (`berat_driver_kg` - Tahap 2), dan **Kolom Input Berat Aktual Gudang (`berat_aktual_kg` - Tahap 3)**. Petugas mengisi berat akhir tiap item, dan sistem langsung menghitung total poin sah secara *real-time* via JavaScript sebelum tombol Selesai ditekan.
6. **Existing Status**: **New Screen / Component** *(Saat ini tombol Selesai di Web Admin langsung memutasi status tanpa modal timbang final)*
7. **Priority**: **Critical**
8. **Navigation**:
   - *Masuk dari*: Tombol *Validasi Timbang Akhir* pada tabel `ADM-003 (orders/data)`.
   - *Keluar ke*: Kembali ke tabel `ADM-003` dengan pemutakhiran status menjadi `completed` setelah transaksi berhasil disimpan.
9. **Komponen UI**: `Bootstrap/Tailwind Modal Dialog (Large size)`, `Order Audit Header (Order ID, Customer Info, Driver Info)`, `3-Tier Comparison Table (Item Name | Estimasi Warga KG | Berat Driver KG | Input Berat Aktual Gudang KG | Harga Poin/KG)`, `Number Input Fields (Berat Aktual KG per Item)`, `Dynamic Real-time JS Calculator Display (Total KG Final & Total Poin Sah)`, `Textarea (Catatan Audit/Potongan Kualitas Gudang)`, `Modal Action Buttons ("Batal" vs "Selesaikan Order & Salurkan Poin (`completed`)")`.
10. **Informasi yang Ditampilkan**: Nomor Order (`#ORD-XXXX`), Nama Warga & Driver, Rincian item sampah beserta sanding angka `estimasi_berat_kg` dan `berat_driver_kg`, Harga tukar poin per kg, Teks preview real-time Total Poin Sah, Peringatan aturan bisnis mutlak.
11. **User Action**: *Input Angka Berat Aktual Gudang (`berat_aktual_kg`) untuk setiap item*, *Periksa Angka Total Poin Sah pada kalkulator real-time*, *Tulis Catatan Inspeksi Gudang*, *Klik Tombol "Selesaikan Order & Salurkan Poin (`completed`)"*.
12. **Business Rules (MUTLAK & KRITIS — SINGLE SOURCE OF TRUTH)**:
    1. Petugas **wajib mengisi kolom `berat_aktual_kg`** untuk setiap baris item muatan dengan angka pasti hasil penimbangan timbangan digital resmi gudang Bank Sampah.
    2. **Acuan Mutlak (*Final Authority for Reward*)**: Perhitungan total poin yang disahkan **WAJIB DAN HANYA MENGGUNAKAN KOLOM `berat_aktual_kg` (Tahap 3)**. Angka `estimasi_berat_kg` (Tahap 1) dan `berat_driver_kg` (Tahap 2) sepenuhnya diabaikan dalam kalkulasi poin akhir:
       $$\text{Poin Item} = \text{berat\_aktual\_kg}_{\text{Tahap 3}} \times \text{harga\_poin\_per\_kg}$$
       $$\text{Total Poin Sah} = \sum (\text{Poin Item})$$
    3. **Integritas Transaksi ACID (*Atomic Database Transaction*)**: Saat tombol Selesaikan ditekan, backend PHP Native (`modules/orders/index.php`) wajib membungkus seluruh mutasi data ke dalam satu transaksi atomic bersyarat (`mysqli_begin_transaction`):
       ```sql
       START TRANSACTION;
       -- Langkah 1: Simpan berat_aktual_kg mutlak pada setiap baris order_items
       UPDATE order_items SET berat_aktual_kg = ? WHERE id_order_item = ?;
       -- Langkah 2: Ubah status order menjadi completed dan catat poin final
       UPDATE orders SET status = 'completed', poin_final = ? WHERE id_order = ?;
       -- Langkah 3: Suntikkan poin final secara sah ke saldo akun warga (tanpa race condition)
       UPDATE pengguna SET saldo = saldo + ? WHERE id_pengguna = ?;
       -- Langkah 4: Terbitkan pesan notifikasi otomatis untuk aplikasi Warga
       INSERT INTO notifikasi (id_pengguna, judul, pesan, created_at) 
       VALUES (?, 'Reward Poin Masuk!', 'Selesai! Anda mendapatkan +... Poin dari jemputan #ORD-...', NOW());
       COMMIT;
       ```
       Jika terjadi kesalahan jaringan, gangguan daya, atau kegagalan pada salah satu langkah di atas, sistem **WAJIB MELAKUKAN ROLLBACK (`mysqli_rollback`)** agar saldo warga tidak rusak atau tergandakan.
13. **Empty State**: Tidak berlaku (modal diisi dari ID Order yang dipilih).
14. **Loading State**: Tombol Selesai berubah menjadi putaran loading *"Menyimpan Transaksi Atomic..."* dan dinonaktifkan sementara.
15. **Error State**:
    - *Berat aktual kosong/negatif*: Alert box *"Mohon lengkapi angka penimbangan akhir (`berat_aktual_kg`) untuk semua item muatan."*
    - *Kegagalan Transaksi ACID*: Alert box merah *"Transaksi Gagal: Terjadi kesalahan pada penyimpanan database. Seluruh perubahan telah dibatalkan (Rollback)."*
16. **Data Dependency**: Tabel `orders`, `order_items`, `jenis_sampah`, `pengguna (warga)`, `notifikasi`.
17. **API Dependency**: Eksekusi Prosedural/API di `modules/orders/index.php (action: verify_final_order)`.
18. **Future Enhancement**: Pencetakan otomatis struk/faktur bukti serah terima gudang langsung ke printer thermal (*POS Thermal Printer*).

---

#### ADM-005 : Waste Catalog Management (CRUD Katalog Sampah & Harga Poin)
1. **Screen ID**: `ADM-005`
2. **Screen Name**: `jenis_sampah/data` (Waste Catalog Management)
3. **Role**: Petugas Bank Sampah (Web Admin)
4. **Tujuan Screen**: Mengelola master data jenis-jenis sampah yang diterima oleh Bank Sampah bersertakan rasio tukar poin per kilogramnya.
5. **Deskripsi Singkat**: Halaman CRUD katalog sampah pada Web Admin (`modules/jenis_sampah/index.php`). Menampilkan tabel daftar nama sampah (misal: Plastik PET, Kardus Bekas, Besi Logam), satuan ukur (`kg`), dan nilai tukar poin per unit berat (`harga_per_kg`). Petugas dapat menambah jenis sampah baru, mengubah harga poin, atau menghapus item yang tidak aktif.
6. **Existing Status**: **Existing**
7. **Priority**: High
8. **Navigation**:
   - *Masuk dari*: Menu Sidebar "Jenis Sampah (`jenis_sampah/data`)".
   - *Keluar ke*: Modal/Form Tambah & Edit Jenis Sampah.
9. **Komponen UI**: `Sidebar Menu`, `Top Navbar`, `Add New Button ("+ Tambah Jenis Sampah")`, `DataTables`, `Edit & Delete Row Buttons`, `Modal Form CRUD (Input Nama, Satuan, Harga Poin/KG)`.
10. **Informasi yang Ditampilkan**: ID Jenis, Nama Sampah, Satuan, Harga Poin per KG (`harga_per_kg`), Tombol Aksi.
11. **User Action**: *Klik Tambah Jenis Sampah*, *Input Form & Simpan*, *Klik Edit Harga Poin*, *Klik Hapus Item*.
12. **Business Rules**:
    - Nilai `harga_per_kg` adalah faktor pengali mutlak dalam perhitungan estimasi maupun kalkulasi poin final di seluruh layar Warga, Driver, dan Admin (`ADM-004`).
    - Jenis sampah yang telah digunakan dalam transaksi riwayat (`order_items`) tidak boleh dihapus fisik (*Hard Delete*), melainkan hanya dinonaktifkan (*Soft Delete / Deactivate*) demi menjaga integritas data riwayat TA.
13. **Empty State**: Teks *"Belum ada jenis sampah di katalog. Klik Tambah untuk membuat baru."*
14. **Loading State**: Tabel memuat indikator *Processing* saat menyimpan data CRUD.
15. **Error State**: Alert box merah jika nama sampah duplikat.
16. **Data Dependency**: Tabel `jenis_sampah`.
17. **API Dependency**: Kueri `SELECT, INSERT, UPDATE, DELETE FROM jenis_sampah`.
18. **Future Enhancement**: Kategori hierarkis sampah (Super Kategori $\rightarrow$ Sub Kategori $\rightarrow$ Item).

---

#### ADM-006 : Users & Drivers Management (Manajemen Nasabah & Armada)
1. **Screen ID**: `ADM-006`
2. **Screen Name**: `warga/data` & `driver/data` (Users & Drivers Management)
3. **Role**: Petugas Bank Sampah (Web Admin)
4. **Tujuan Screen**: Mengelola database akun pengguna teregistrasi, memeriksa riwayat saldo poin nasabah, serta mengadministrasikan data armada penjemput dan spesifikasi kendaraannya.
5. **Deskripsi Singkat**: Dua modul halaman CRUD pengelola pengguna di Web Admin. `warga/data` menyajikan tabel seluruh akun warga bersertakan alamat domisili dan saldo poin terkini. `driver/data` menyajikan tabel akun armada driver bersertakan rincian spesifikasi kendaraan (`detail_driver: plat_nomor, tipe_kendaraan, kapasitas_kg`).
6. **Existing Status**: **Existing**
7. **Priority**: Medium
8. **Navigation**:
   - *Masuk dari*: Menu Sidebar "Data Warga" atau "Data Driver".
   - *Keluar ke*: Modal Tambah/Edit Data Pengguna & Armada.
9. **Komponen UI**: `Sidebar Menu`, `Top Navbar`, `Add New Driver/Warga Button`, `DataTables`, `Status Badge (Aktif/Nonaktif)`, `Modal Form CRUD`.
10. **Informasi yang Ditampilkan**: Nama Lengkap, Username, No. Telepon, Alamat, Saldo Poin (`warga`), Spesifikasi Kendaraan (`driver`), Tombol Aksi.
11. **User Action**: *Cari Nama Pengguna*, *Tambah Armada Driver Baru*, *Edit Spesifikasi Kendaraan (`plat_nomor`)*, *Reset Kata Sandi Pengguna*.
12. **Business Rules**: Pendaftaran akun driver baru **hanya dapat dilakukan melalui halaman `driver/data` oleh Web Admin**, tidak ada fitur pendaftaran mandiri (*Self-Register*) untuk armada driver di aplikasi mobile.
13. **Empty State**: Tabel kosong jika data belum tersedia.
14. **Loading State**: Indikator *Processing* pada tabel.
15. **Error State**: Pesan error jika nomor telepon atau username bentrok.
16. **Data Dependency**: Tabel `pengguna`, `detail_driver`.
17. **API Dependency**: Kueri `SELECT, INSERT, UPDATE FROM pengguna WHERE level = 'warga'/'driver'`.
18. **Future Enhancement**: Penonaktifan otomatis akun yang tidak aktif selama 1 tahun.

---

#### ADM-007 : Education & Reports Page (CRUD Artikel Edukasi & Cetak Laporan Operasional)
1. **Screen ID**: `ADM-007`
2. **Screen Name**: `edukasi/data` & `laporan/data` (Education & Reports Page)
3. **Role**: Petugas Bank Sampah (Web Admin)
4. **Tujuan Screen**: Memperbarui wawasan lingkungan yang ditampilkan di aplikasi warga (`edukasi/data`) serta mencetak dokumen rekapitulasi penjemputan sampah untuk kebutuhan administrasi dan lampiran Tugas Akhir (`laporan/data`).
5. **Deskripsi Singkat**: `edukasi/data` adalah halaman CRUD artikel panduan daur ulang. `laporan/data` adalah halaman rekapitulasi transaksi operasional di mana petugas dapat memfilter pesanan berdasarkan rentang tanggal tertentu, melihat total volume sampah (`kg`) yang terkumpul, dan menekan tombol cetak untuk menghasilkan dokumen PDF atau Excel (*Export Reports*).
6. **Existing Status**: **Existing**
7. **Priority**: Medium
8. **Navigation**:
   - *Masuk dari*: Menu Sidebar "Edukasi" atau "Laporan".
   - *Keluar ke*: Jendela cetak dokumen (*Browser Print Preview / Download PDF*).
9. **Komponen UI**: `Sidebar Menu`, `Top Navbar`, `Date Range Picker (Filter Tanggal Dari - Sampai)`, `Filter Status Dropdown`, `Summary Metrics Box (Total Order, Total KG, Total Poin)`, `DataTables Rekapitulasi`, `Export Buttons ("Cetak PDF" / "Export Excel")`.
10. **Informasi yang Ditampilkan**: Rekapitulasi pesanan per periode, Total kilogram sampah terangkut, Total reward poin disalurkan, Tombol unduh laporan.
11. **User Action**: *Pilih Rentang Tanggal*, *Klik Filter Laporan*, *Klik Cetak PDF untuk Lampiran TA*, *Klik Export Excel*.
12. **Business Rules**: Laporan operasional resmi yang dicetak **wajib memuat angka dari kolom `berat_aktual_kg` (Tahap 3)** sebagai bukti sah penimbangan akhir di gudang Bank Sampah.
13. **Empty State**: Teks *"Tidak ada transaksi penjemputan selesai pada rentang tanggal yang dipilih."*
14. **Loading State**: Spinner loading saat menghitung rekapitulasi data periode besar.
15. **Error State**: Alert box jika rentang tanggal tidak valid (misal: tanggal awal > tanggal akhir).
16. **Data Dependency**: Tabel `orders JOIN order_items JOIN pengguna JOIN jenis_sampah`.
17. **API Dependency**: Kueri rekapitulasi `SELECT ... FROM orders JOIN ... WHERE status = 'completed' AND created_at BETWEEN ? AND ?`.
18. **Future Enhancement**: Pembuatan laporan otomatis via email mingguan untuk pimpinan Bank Sampah.

---

## 4. RINGKASAN EXISTING VS NEW VS REVISION (*Status Breakdown Summary*)

Berdasarkan inventarisasi 18 parameter di atas, berikut adalah rekapitulasi statistik status kesiapan 17 layar/komponen utama sistem kita:

```text
+-------------------------------------------------------------------------+
|                  STATISTIK KESIAPAN LAYAR SISTEM                        |
+-------------------------------------------------------------------------+
|  TOTAL LAYAR DIPETAKAN : 17 Screen Classes / Modul Controller           |
|                                                                         |
|  [✓] EXISTING (Sudah Sesuai)     : 10 Layar (58.8%)                     |
|  [⚠] NEED REVISION (Perlu Revisi):  4 Layar (23.5%)                     |
|  [★] NEW SCREEN (Layar Baru)     :  3 Layar (17.7%)                     |
+-------------------------------------------------------------------------+
```

### 📋 Daftar Rincian per Kategori Status:

1. **[✓] EXISTING SCREENS (10 Layar — Sudah Siap / Fungsional)**:
   - `WRG-001` : Onboarding & Splash Screen (Warga)
   - `WRG-002` : Authentication Screens (Warga)
   - `WRG-003` : Home Screen (Warga)
   - `WRG-004` : Pickup Request Screen (Form Buat Order Tahap 1 — Warga)
   - `WRG-008` : AI Scan & Education Screen (Warga)
   - `WRG-010` : Profile Screen (Warga)
   - `DRV-001` : Driver Auth Screens (Driver)
   - `DRV-002` : Dashboard Screen (`Active Tasks` — Driver)
   - `DRV-003` : Pickup Detail Screen & Navigasi Google Maps (Driver)
   - `DRV-006` : Schedule & History Screen (Driver)
   - `DRV-007` : Alerts & Profile Screen (Driver)
   - `ADM-001` : Admin Login Page (Web Admin)
   - `ADM-002` : Executive Dashboard (Web Admin)
   - `ADM-005` : Waste Catalog Management (`jenis_sampah` — Web Admin)
   - `ADM-006` : Users & Drivers Management (`warga` & `driver` — Web Admin)
   - `ADM-007` : Education & Reports Page (`edukasi` & `laporan` — Web Admin)

2. **[⚠] NEED REVISION SCREENS (4 Layar — Perlu Penyelarasan Kritis & Status Baru)**:
   - **`WRG-005` (Orders Screen - Warga)**: Penambahan lencana warna & tab filter untuk status baru `'validating'`.
   - **`WRG-006` (Order Detail Screen - Warga)**: Penambahan titik check ke-5 (`validating`) pada *Timeline Stepper* 6 Status, serta pemunculan kolom perbandingan `berat_driver_kg` (Tahap 2) pada tabel rincian item muatan.
   - **`WRG-009` (Alerts & Reward Screen - Warga)**: Penyelarasan redaksi notifikasi otomatis saat pesanan beralih ke status `validating` dan `completed` (menyebutkan angka poin sah).
   - **`DRV-004` (Pickup Verification Screen - Driver)**: **[REVISI KRITIS]** Penambahan form input angka penimbangan awal lapangan (`berat_driver_kg` - Tahap 2) untuk setiap jenis item sampah saat menekan tombol angkut (`picked_up`).
   - **`ADM-003` (Orders Management Table - Web Admin)**: Penambahan tab filter status `'validating'` dan tombol aksi hijau tajam *"Validasi Timbang Akhir"*.

3. **[★] NEW SCREENS / COMPONENTS (3 Layar — Wajib Dibangun sebagai Enhancements)**:
   - **`WRG-007` (Driver Tracking Screen - Warga)**: Layar peta pemantauan koordinat posisi armada secara *real-time* bersertakan perkiraan waktu tiba (*ETA*) saat status pesanan berada pada tahap `on_the_way`.
   - **`DRV-005` (Warehouse Handover Screen - Driver)**: Layar konfirmasi serah terima muatan fisik di area gudang Bank Sampah yang memicu transisi status dari `picked_up` menjadi `validating`.
   - **`ADM-004` (Warehouse Final Weighing Modal - Web Admin)**: **[LAYAR BARU PALING KRITIS]** Modal pop-up verifikasi akhir tempat petugas gudang menginput angka penimbangan akhir (`berat_aktual_kg` - Tahap 3) dan menjalankan eksekusi **Transaksi Atomic Database (ACID Transaction)** untuk menyuntikkan poin sah ke akun warga.

---

## 5. KESIMPULAN & PENUTUP (*Conclusion*)

Dokumen **Screen Catalog (`SCREEN_CATALOG.md`)** ini telah secara sempurna membedah seluruh 17 kelas layar/modul pada sistem Bank Sampah Bersinar dengan tingkat kedalaman spesifikasi 18 parameter yang amat rapi dan konsisten dengan seluruh dokumen *Single Source of Truth (SSOT)* kita (`MASTER_PROJECT_PLAN.md`, `FEATURE_INVENTORY.md`, `CONTENT_INVENTORY.md`, dan `INFORMATION_ARCHITECTURE.md`).

Melalui pemetaan spesifikasi layar yang lugas dan berstandar *Enterprise Architecture* ini, kita telah:
1. **Mengunci Otoritas Penimbangan 3 Tahap**: Menegaskan di setiap parameter layar bahwa `estimasi_berat_kg` (Tahap 1 di `WRG-004`) dan `berat_driver_kg` (Tahap 2 di `DRV-004`) tidak memutasi saldo, sedangkan `berat_aktual_kg` (Tahap 3 di `ADM-004`) adalah **Satu-Satunya Acuan Mutlak (*Single Source of Truth for Reward*)**.
2. **Mengamankan Integritas Keuangan (*ACID Transaction*)**: Menetapkan aturan bisnis mutlak pada layar `ADM-004` bahwa penyelesaian pesanan (`completed`) wajib dibungkus dalam transaksi `mysqli_begin_transaction` / `COMMIT` / `ROLLBACK`.
3. **Menciptakan Panduan Presisi untuk UI/UX & Coding**: Memastikan bahwa tim pada fase berikutnya (*Sitemap, Wireframe, Stitch UI, Figma, dan coding Flutter*) tinggal mengikuti 18 spesifikasi parameter layar ini tanpa keraguan sedikit pun.

---
*Dokumen SCREEN_CATALOG.md ini mengacu penuh pada MASTER_PROJECT_PLAN.md, FEATURE_INVENTORY.md, CONTENT_INVENTORY.md, dan INFORMATION_ARCHITECTURE.md sebagai Single Source of Truth (SSOT).*
