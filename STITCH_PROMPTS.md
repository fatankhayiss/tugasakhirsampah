# MASTER STITCH AI UI DESIGN PROMPTS (`STITCH_PROMPTS.md`)
**Sistem Informasi Bank Sampah Bersinar — Modul Penjemputan Sampah Berbasis Mobile & Web Admin**
*Katalog Master Spesifikasi Antarmuka & Prompt Generatif UI Presisi Tinggi untuk AI Stitch / Figma Generator (Phase 8 Unified Master Prompt)*

---

## EXECUTIVE SUMMARY & GUIDELINES FOR STITCH AI GENERATION

Dokumen **`STITCH_PROMPTS.md`** ini disusun dalam kapasitas rekayasa arsitektur antarmuka (*Enterprise UI/UX Architecture*) sebagai dokumen **Master Prompt Repository** yang memuat 24 (dua puluh empat) spesifikasi layar lengkap dan prompt generatif siap pakai untuk dipindai oleh **Stitch AI** (atau AI UI generator eksternal lainnya).

Seluruh isi dokumen ini berakar mutlak pada rantai *Single Source of Truth (SSOT)* kita: **`MASTER_PROJECT_PLAN.md`**, **`FEATURE_INVENTORY.md`**, **`CONTENT_INVENTORY.md`**, **`INFORMATION_ARCHITECTURE.md`**, **`SCREEN_CATALOG.md`**, **`SITEMAP.md`**, **`USER_FLOW.md`**, dan **`UI_REQUIREMENTS.md`**.

### Aturan Baku Pemakaian Prompt Stitch (*Global Prompt Injection Rules*):
1. **Salin Seluruh Isi Kotak Prompt (` ```prompt `)**: Setiap rincian layar di bawah ini dilengkapi dengan satu blok prompt khusus yang telah dioptimalkan untuk sintaks generatif Stitch AI. Salin isi blok tersebut secara utuh ke dalam kolom prompt Stitch AI.
2. **Kunci Identitas Visual Material Design 3 Green Eco-Theme**: Seluruh prompt telah diinstruksikan untuk menggunakan palet warna zamrud (`#1E7D32`), aksen daun (`#4CAF50`), latar belakang bersih (`#FFFFFF` / `#F8FAFC`), font **Plus Jakarta Sans**, serta ikon **Material Symbols Outlined 24px/2px stroke**.
3. **Kepatuhan Mutlak Logika 3 Tahap Berat & 6 Status**: Prompt Stitch dilarang menampilkan angka saldo/poin sah pada status selain `completed`. Untuk layar Warga dan Driver pada status `pending` hingga `validating`, prompt secara eksplisit menginstruksikan AI untuk hanya memunculkan label estimasi/bukti lapangan tanpa penambahan poin.

---

## 1. KATALOG PROMPT APLIKASI MOBILE WARGA (`WRG-001` – `WRG-010`)

---

### WRG-001 : Splash & Onboarding Intro Screen
- **Nama Screen**: `Splash & Intro Screen`
- **Role**: Warga (Nasabah / Calon Nasabah)
- **Tujuan Screen**: Memvisualisasikan identitas Bank Sampah Bersinar, mengecek status sesi (`api_token`), serta memandu calon nasabah melalui 3 slide edukasi singkat tentang manfaat pemilahan dan penjemputan sampah.
- **Business Goal**: Meningkatkan *first-time user onboarding conversion* dan menanamkan citra pelayanan publik yang profesional, sejuk, dan terpercaya.
- **Referensi dari Screen Catalog**: `WRG-001` (*Existing Screen - High Priority*).
- **Komponen yang harus tampil**:
  - Logo resmi Bank Sampah Bersinar dengan latar putih `#FFFFFF`.
  - *PageView Carousel* dengan 3 slide ilustrasi vektor bertema hijau eco-friendly.
  - Indikator dot aktif berwarna hijau utama `#1E7D32`.
  - Tombol aksi primary utama full-width `radiusXL (24px)`.
- **Komponen yang tidak boleh tampil**:
  - *Bottom Navigation Bar*, *AppBar* dengan tombol back, atau kartu saldo poin (karena pengguna belum login).
- **Navigasi masuk**: *App Launch* (Aplikasi pertama kali dibuka dari layar utama OS Android/iOS).
- **Navigasi keluar**: `LoginScreen (WRG-002)` atau auto-forward ke `HomeScreen (WRG-003)` jika `api_token` aktif ditemukan di `SharedPreferences`.
- **Data yang dibutuhkan**: `api_token` (cek lokal SharedPreferences), teks dan aset gambar/vektor onboarding slide.
- **State**:
  - `Loading`: *Spinner circular green (`#1E7D32`)* di bawah logo saat sistem memeriksa token sesi di latar belakang.
  - `Empty`: *Not applicable* (halaman statis intro).
  - `Error`: *Not applicable*.
  - `Success`: Tampilan penuh slide intro 1, 2, 3 dengan animasi pergeseran halus.
- **Business Rules**: Jika `api_token` valid dan tidak expired, lewati halaman intro dan langsung arahkan ke `HomeScreen (WRG-003)` (*Zero Friction Entry*).
- **Status yang digunakan**: *None* (Pra-otentikasi).
- **CTA utama**: Tombol *Filled Primary Button* **"Mulai Sekarang"** (`#1E7D32`, teks putih Bold `16px`, `height 48px`).
- **CTA sekunder**: Tombol *Text Button* **"Lewati (Skip)"** (`#1E7D32`, `Label Large`) di pojok kanan atas slide 1 dan 2.
- **Design Notes**: Gunakan ruang putih bersih secara maksimal (*Clean White Space*). Ilustrasi vektor harus memiliki aksen gradasi hijau lembut yang menenangkan.
- **Accessibility**: Teks judul slide berukuran `24px Bold` dengan rasio kontras `7.5:1` terhadap latar `#FFFFFF`. Tombol memiliki area sentuh minimal `48x48px`.
- **Animation**: Pergeseran slide (*Page transition*) menggunakan kurva `Curves.easeInOut` `300ms`. Dot indikator memanjang secara elastis saat slide berganti (`AnimatedContainer`).
- **Responsive Rules**: Mengikuti Mobile Grid `< 600px`. Ilustrasi menyesuaikan tinggi layar secara proporsional (`BoxFit.contain` maksimal `45% height`).

```prompt
[STITCH AI MASTER PROMPT - WRG-001: Splash & Onboarding Intro Screen]
Design an enterprise-grade, modern, clean, and minimalist Mobile Onboarding / Intro screen for a green eco-friendly waste management application named "Bank Sampah Bersinar".

Style & Theme Requirements:
- Material Design 3 (M3) Android Native Mobile First paradigm.
- Color Palette: Primary Emerald Green (#1E7D32), Secondary Leaf Green (#4CAF50), Pure White Background (#FFFFFF), Text Primary Dark (#0F172A), Text Secondary Slate (#64748B).
- Typography: Plus Jakarta Sans (Modern Geometric Sans-Serif).
- Icons: Material Symbols Outlined (24px size, 2px stroke width).
- Grid & Spacing: Strict 8pt spacing grid (16px standard horizontal margin, 24px vertical section gaps).

Layout Anatomy:
1. Top Bar: Clean white background with a subtle "Lewati (Skip)" Text Button (#1E7D32, 14px SemiBold) in the top-right corner.
2. Center Hero Area: A large, elegant flat vector illustration depicting a friendly community member separating recyclable plastic and paper waste into neat green containers, surrounded by subtle floating green leaf accents.
3. Typography Section right below the illustration:
   - Headline Large: "Jemput Sampah dari Rumah" (24px Bold, #0F172A, centered).
   - Body Medium: "Tidak perlu repot mengantar ke tempat penampungan. Armada resmi kami siap menjemput sampah daur ulang langsung ke pintu rumah Anda." (14px Regular, #64748B, centered, line-height 20px).
4. Bottom Navigation & Action Area:
   - Pagination Indicator: 3 dots centered horizontally. The first dot is an elongated active pill (lebar 24px, tinggi 8px, #1E7D32), while the other two are small circular dots (8px x 8px, #E2E8F0).
   - Primary Call-to-Action: A full-width Filled Button (#1E7D32 background, white text "Mulai Sekarang", 16px SemiBold, height 48px, BorderRadius 24px XL pill shape, elevation-2 soft shadow).

Visual Vibe: Professional, welcoming, trustworthy, clutter-free, and inspiring environmental action.
```

---

### WRG-002 : Authentication Gate (Login & Register Screen)
- **Nama Screen**: `Authentication Screens (Login & Register)`
- **Role**: Warga (Nasabah)
- **Tujuan Screen**: Mengotentikasi kredensial pengguna (Nomor Telepon/Email dan Kata Sandi) serta mendaftarkan nasabah baru dengan pengisian alamat domisili default.
- **Business Goal**: Menjamin keamanan data nasabah (*Account Security*) dan membangun identitas terverifikasi di database `pengguna`.
- **Referensi dari Screen Catalog**: `WRG-002` (*Existing Screen - Critical Priority*).
- **Komponen yang harus tampil**:
  - Header logo mini dan judul sambutan (*Headline Large*).
  - *TextFormField* Nomor Telepon (dengan prefix ikon `phone` dan format angka).
  - *TextFormField* Kata Sandi (dengan prefix ikon `lock` dan tombol toggle `visibility_off`).
  - Link *Text Button* **"Lupa Kata Sandi?"**.
  - Tombol utama **"Masuk ke Akun"** (`height 48px`).
  - Pemisah teks *"Atau daftar sebagai nasabah baru"*.
  - Tombol sekunder Outlined **"Daftar Akun Baru"**.
- **Komponen yang tidak boleh tampil**:
  - *Bottom Navigation Bar*, *Search Bar*, atau elemen Dasbor.
- **Navigasi masuk**: `WRG-001 (Splash/Intro)` atau *Force Logout Redirect* dari `WRG-010`.
- **Navigasi keluar**: `HomeScreen (WRG-003)` saat login/registrasi sukses (*Push Replacement*).
- **Data yang dibutuhkan**: Payload POST `no_telepon`, `password`, dan untuk registrasi: `nama_lengkap`, `alamat_domisili`.
- **State**:
  - `Loading`: *CircularProgressIndicator* putih `3px` di dalam tombol utama saat API mengirim request.
  - `Empty`: Form kosong siap diisi dengan *placeholder text* `#94A3B8`.
  - `Error`: Border kolom input berubah merah `#D32F2F` (`2px solid`) disertai *Error Label Small* di bawah kotak (`12px`) dan *Snackbar Error* melayang.
  - `Success`: *Not applicable* (langsung beralih ke `WRG-003`).
- **Business Rules**: Hanya akun dengan `level = 'warga'` yang diizinkan masuk melalui layar ini. Akses driver/admin akan ditolak dengan pesan kesalahan khusus.
- **Status yang digunakan**: *None* (Autentikasi).
- **CTA utama**: Tombol *Filled Primary* **"Masuk ke Akun"** (`#1E7D32`, `radiusXL`).
- **CTA sekunder**: Tombol *Outlined Secondary* **"Daftar Akun Baru"** (`border #1E7D32`, `radiusXL`).
- **Design Notes**: Kotak form input (`TextFormField`) harus menggunakan `BorderRadius 8px` dengan padding horizontal `14px` agar nyaman diketik di layar sentuh.
- **Accessibility**: Label form harus menyertakan teks petunjuk yang jelas. Seluruh input mendukung pembacaan *Screen Reader*.
- **Animation**: Tombol beralih secara halus ke mode spinner saat ditekan (`200ms`).
- **Responsive Rules**: Mengikuti Mobile Grid `< 600px`. Lebar maksimal form dibatasi `400px` di tengah layar pada tablet.

```prompt
[STITCH AI MASTER PROMPT - WRG-002: Authentication Gate (Login Screen)]
Design a high-fidelity, professional Material Design 3 Mobile Login screen for the citizen app of "Bank Sampah Bersinar".

Style & Theme Requirements:
- Clean white background (#FFFFFF) with high-contrast text and emerald green brand accents.
- Typography: Plus Jakarta Sans.
- Icons: Material Symbols Outlined (24px).
- 8pt spacing grid with crisp form structure.

Layout Anatomy:
1. Top Header Area (Centered, padding top 48px):
   - A small, crisp green vector emblem of Bank Sampah Bersinar (56px x 56px).
   - Headline Large: "Selamat Datang Kembali!" (24px Bold, #0F172A).
   - Body Medium: "Masuk dengan nomor telepon dan kata sandi Anda." (14px Regular, #64748B, margin top 4px).
2. Form Fields Container (Margin top 32px, 16px horizontal margin):
   - Phone Input Field: A modern M3 Outlined TextField (height 52px, BorderRadius 8px, border color #E2E8F0). Features a green prefix icon 'phone' (#1E7D32), placeholder text "0812-3456-7890" (#94A3B8), and floating label "Nomor Telepon" (#1E7D32 SemiBold).
   - Password Input Field (Margin top 16px): Outlined TextField with green prefix icon 'lock', masked dots text (••••••••), and a right suffix icon 'visibility_off' (#64748B).
   - Forgot Password Action: Right-aligned Text Button below the password field ("Lupa Kata Sandi?", 13px SemiBold, #1E7D32, margin top 8px).
3. Primary & Secondary CTA Section (Margin top 32px):
   - Primary Button: Full-width Filled Button (#1E7D32 background, white text "Masuk ke Akun", 16px SemiBold, height 48px, BorderRadius 24px pill shape, elevation-2).
   - Divider: A clean horizontal divider with centered text "Atau belum punya akun?" (12px Regular, #94A3B8, margin vertical 24px).
   - Secondary Button: Full-width Outlined Button (1.5px solid border #1E7D32, transparent background, text "Daftar Akun Baru" #1E7D32, 16px SemiBold, height 48px, BorderRadius 24px).

Visual Vibe: Trustworthy, highly legible, secure, clean, and intuitive.
```

---

### WRG-003 : Home Screen (Dasbor Warga & Hero Card)
- **Nama Screen**: `Home Screen (Tab 1 Dasbor Warga)`
- **Role**: Warga (Nasabah)
- **Tujuan Screen**: Menyajikan ringkasan informasi akun (Saldo Poin Sah & Estimasi Nilai Rupiah), pintu masuk cepat ke fitur utama (*Pickup Request & AI Scan*), serta artikel edukasi lingkungan terbaru.
- **Business Goal**: Mendorong partisipasi penjemputan sampah secara berkelanjutan melalui transparansi reward dan kemudahan akses ke form jemputan.
- **Referensi dari Screen Catalog**: `WRG-003` (*Existing Screen - High Priority*).
- **Komponen yang harus tampil**:
  - *AppBar* dengan Avatar Profil warga, teks sambutan *"Halo, [Nama Warga]"*, dan ikon lonceng notifikasi `notifications`.
  - **Hero Card Saldo Poin** (Gradasi `#1E7D32` $\rightarrow$ `#2E7D32`, `radiusLG 16px`) yang menampung angka Saldo Poin aktual (`Display Large`), estimasi konversi rupiah, dan tombol mini *"Riwayat Poin"*.
  - *Quick Action Grid (2 Kolom Cards)*: Kartu 1 *"Buat Jemputan (`local_shipping`)"* dan Kartu 2 *"Scan AI Sampah (`qr_code_scanner`)"*.
  - *Active Order Alert Card* (Hanya muncul jika ada pesanan berstatus `accepted` / `on_the_way` / `picked_up` / `validating`).
  - *Section Header*: *"Edukasi Daur Ulang"* berserta *Horizontal Card Carousel* artikel lingkungan.
  - **Bottom Navigation Bar (4 Tabs Shell)**: Tab 1 Beranda (Aktif hijau `#E8F5E9`), Tab 2 Pesanan, Tab 3 Notifikasi, Tab 4 Profil.
- **Komponen yang tidak boleh tampil**:
  - Form input penimbangan driver (`berat_driver_kg`) atau tombol manajemen admin.
- **Navigasi masuk**: `WRG-002 (Login)` atau perpindahan Tab *Bottom Navigation*.
- **Navigasi keluar**: `PickupRequest (WRG-004)` saat klik *Buat Jemputan*, `AI Scan (WRG-008)` saat klik *Scan AI*, atau `OrderDetail (WRG-006)` saat klik *Active Order Alert*.
- **Data yang dibutuhkan**: `pengguna.saldo`, `pengguna.nama_lengkap`, daftar `orders` aktif (`WHERE status NOT IN ('completed','cancelled')`), daftar artikel `edukasi`.
- **State**:
  - `Loading`: *Shimmer Skeleton Box* bergelombang pada area Hero Card (`height 140px`) dan kartu aksi cepat.
  - `Empty`: Hero Card menunjukkan Saldo `0 Poin (Rp 0)`. Area *Active Order Alert* disembunyikan.
  - `Error`: *Error Card mini* abu-abu merah jika gagal mengambil saldo terbaru dari server.
  - `Success`: Dasbor dimuat lengkap dengan saldo poin aktual yang bersumber sah dari tabel `pengguna.saldo`.
- **Business Rules**: Saldo poin yang ditampilkan di sini **murni hasil akumulasi pesanan yang berstatus `completed` (berdasarkan `berat_aktual_kg` Tahap 3)**. Angka estimasi warga (`estimasi_berat_kg`) dilarang dimasukkan ke dalam saldo ini.
- **Status yang digunakan**: Menyoroti status pesanan aktif jika ada (`accepted`, `on_the_way`, `picked_up`, `validating`).
- **CTA utama**: Kartu Aksi Cepat **"Buat Jemputan Baru (`WRG-004`)"**.
- **CTA sekunder**: Kartu Aksi Cepat **"Scan AI Deteksi Sampah (`WRG-008`)"**.
- **Design Notes**: Hero Card harus menjadi titik fokus visual tertinggi di layar ini (*Visual Anchor*). Gunakan bayangan `elevation-2` pada kartu cepat.
- **Accessibility**: Teks saldo poin putih di atas gradasi hijau memiliki kontras `8.1:1 (AAA)`. Seluruh kartu aksi dapat diklik dan memiliki *Touch Target* $> 64$px.
- **Animation**: *RefreshIndicator pull-to-refresh* dengan spinner hijau. Kartu aktif bergoyang halus saat ditekan (`scale 0.98`).
- **Responsive Rules**: Mengikuti Mobile Grid `< 600px`. Pada tablet `600px-1024px`, Hero Card dan Quick Action Grid bersanding horisontal dalam 2 kolom terpisah (`50% - 50% width`).

```prompt
[STITCH AI MASTER PROMPT - WRG-003: Home Screen (Dasbor Warga)]
Design an exquisite, high-fidelity Material Design 3 Mobile Home Dashboard for the citizen app of "Bank Sampah Bersinar".

Style & Theme Requirements:
- Modern Android M3 layout with a clean off-white scaffold background (#F8FAFC).
- Color Tokens: Primary Forest Green (#1E7D32), Emerald Gradient (#2E7D32), Card Surface White (#FFFFFF), Text Slate (#0F172A).
- Typography: Plus Jakarta Sans.
- Icons: Material Symbols Outlined (24px).
- Bottom Navigation Bar 4 Tabs active shell.

Layout Anatomy:
1. Top App Bar (Height 64px, background #F8FAFC, padding horizontal 16px):
   - Left: Circular profile avatar image (40px x 40px, border 1.5px green) next to text column: "Selamat Pagi," (12px Regular #64748B) and "Kevin Khayiss" (16px Bold #0F172A).
   - Right: Notification bell icon button ('notifications', #1E7D32) with a tiny red notification dot.
2. Hero Card Container (Margin horizontal 16px, top 8px):
   - A stunning gradient container (#1E7D32 to #2E7D32, BorderRadius 16px, elevation-2 shadow).
   - Top row: Label "Saldo Poin Saya" (13px Medium, white with 85% opacity) and a small pill badge "Verified Member" (white border, 11px).
   - Middle row: Large typography display "14.500 Poin" (32px Bold, #FFFFFF, letter-spacing -0.5px).
   - Bottom row: Text "Setara dengan Rp 14.500" (13px Regular, white with 80% opacity) on the left, and a mini white action pill button "Riwayat Poin ->" (text #1E7D32, height 28px, BorderRadius 14px) on the right.
3. Quick Action Grid (Margin top 20px, horizontal 16px, 2 columns with 12px gap):
   - Action Card 1 (Buat Jemputan): White card (#FFFFFF, BorderRadius 12px, elevation-1, padding 16px). Features a large circle background (#E8F5E9) with green truck icon 'local_shipping' (32px, #1E7D32), Title "Buat Jemputan" (15px Bold #0F172A), and Subtitle "Jemput ke rumah" (12px #64748B).
   - Action Card 2 (Scan AI): White card with light green circle background, camera scanner icon 'qr_code_scanner' (#4CAF50), Title "Scan AI Sampah", Subtitle "Cek estimasi poin".
4. Active Order Alert Card (Margin top 16px, horizontal 16px):
   - A prominent info card with light blue background (#E1F5FE, border 1px solid #0288D1, BorderRadius 12px, padding 14px). Features icon 'local_shipping' (#0288D1), text "Armada sedang menuju lokasi Anda (#ORD-1024)" (13px SemiBold #01579B), and a right-aligned pill CTA "Lihat Peta ->" (#0288D1).
5. Section Header & Education Carousel (Margin top 24px, horizontal 16px):
   - Section Title: "Edukasi Daur Ulang" (18px Bold #0F172A) with right link "Lihat Semua" (#1E7D32).
   - Horizontal scrollable article card displaying an eco-friendly thumbnail image and title "Cara Memilah Plastik PET agar Bernilai Tinggi" (14px SemiBold).
6. Bottom Navigation Bar (Height 68px, white surface, elevation-3):
   - 4 equal tabs: 'Beranda' (ACTIVE with #E8F5E9 pill indicator and green icon 'home'), 'Pesanan' (inactive gray 'local_shipping'), 'Notifikasi' ('notifications'), and 'Profil' ('person').

Visual Vibe: Vibrant, rewarding, highly organized, premium, and frictionless.
```

---

### WRG-004 : Pickup Request Screen (Form Tahap 1 `estimasi_berat_kg`)
- **Nama Screen**: `Pickup Request Screen (Form Jemputan Tahap 1)`
- **Role**: Warga (Nasabah)
- **Tujuan Screen**: Memfasilitasi warga mengajukan pesanan penjemputan sampah baru dengan memilih alamat, sesi waktu, jenis sampah, serta menginput **`estimasi_berat_kg` (Tahap 1)**.
- **Business Goal**: Mengumpulkan data pengajuan jemputan akurat yang akan masuk sebagai antrean tugas `pending` bagi armada driver di wilayah kerja.
- **Referensi dari Screen Catalog**: `WRG-004` (*Existing Screen - Critical Priority*).
- **Komponen yang harus tampil**:
  - *AppBar* dengan judul *"Buat Permintaan Jemput"* dan tombol Back Arrow (`Navigator.pop`).
  - *Section 1 - Lokasi Penjemputan*: Kartu alamat default warga dengan tombol *"Ubah Alamat / Peta (`location_on`)"*.
  - *Section 2 - Sesi Waktu*: Grid pilihan tanggal & 2 sesi waktu (*Pagi 08.00–11.00* vs *Siang 13.00–16.00*).
  - *Section 3 - Rincian Sampah (Dynamic Item Table)*: Dropdown Kategori Jenis Sampah, *Number TextField* **`estimasi_berat_kg`**, dan tombol *"+ Tambah Jenis Sampah Lain"*.
  - *Section 4 - Kalkulator Poin Real-time*: Kotak ringkasan kuning/hijau yang menampilkan total KG dan **Estimasi Poin (`estimasi_berat_kg * harga_poin`)** dengan label jelas *"Perkiraan Poin"*.
  - **Info Banner Peringatan Mutlak**: *"Perhatian: Poin yang tertera adalah estimasi awal. Poin sah final akan ditentukan berdasarkan hasil timbangan akhir di gudang Bank Sampah Bersinar."*
  - Tombol submit utama di dasar layar (*Bottom Sticky CTA*).
- **Komponen yang tidak boleh tampil**:
  - Input `berat_driver_kg` (Tahap 2) atau `berat_aktual_kg` (Tahap 3).
- **Navigasi masuk**: `HomeScreen (WRG-003)` saat klik *Buat Jemputan*.
- **Navigasi keluar**: `OrdersScreen (WRG-005)` pasca-submit berhasil, atau kembali ke `WRG-003` jika batal.
- **Data yang dibutuhkan**: `pengguna.alamat_domisili`, katalog `jenis_sampah` (harga poin/kg dari API).
- **State**:
  - `Loading`: *Spinner circular green* saat mengambil daftar jenis sampah terbaru dari `jenis_sampah_api.php`.
  - `Empty`: Form dimulai dengan 1 baris item kosong secara default.
  - `Error`: *TextFormField error border merah `#D32F2F`* jika warga memasukkan angka `0` atau mengosongkan berat, disertai *Alert Dialog Validasi*.
  - `Success`: Muncul **Dialog Konfirmasi Submission** sebelum API dikirim, lalu setelah sukses memunculkan *Success Modal* dengan tombol *"Lihat Pesanan Saya (`WRG-005`)"*.
- **Business Rules**: **ATURAN MUTLAK**: Angka estimasi poin yang dihitung di layar ini **DILARANG KERAS ditambah ke kolom `pengguna.saldo`**. Payload dikirim melalui `POST orders_api.php` dan menciptakan baris order berstatus awal **`pending`**.
- **Status yang digunakan**: Menghasilkan pesanan baru berstatus **`pending`**.
- **CTA utama**: Tombol *Sticky Bottom Primary Button* **"Ajukan Penjemputan Sekarang"** (`#1E7D32`, `height 52px`).
- **CTA sekunder**: Tombol *Outlined Secondary* **"+ Tambah Jenis Sampah Lain"** (`radiusSM 8px`).
- **Design Notes**: Gunakan pembatas antar-section (`SizedBox(height: 24)`) agar form tidak terasa menumpuk. Kolom input berat menggunakan *Number Keyboard (`TextInputType.numberWithOptions(decimal: true)`)*.
- **Accessibility**: Label input harus membedakan dengan jelas antara jenis sampah dan satuan kilogram.
- **Animation**: Kalkulator poin memperbarui angka secara halus (`AnimatedSwitcher` `200ms`) saat warga mengetik berat.
- **Responsive Rules**: Mengikuti Mobile Grid `< 600px`. Tombol submit diposisikan sebagai *Fixed Bottom Bar* dengan *safe area padding*.

```prompt
[STITCH AI MASTER PROMPT - WRG-004: Pickup Request Screen (Form Tahap 1)]
Design an intuitive, highly structured Material Design 3 Mobile Form screen for requesting a waste pickup in "Bank Sampah Bersinar".

Style & Theme Requirements:
- Scaffold background #F8FAFC, Card containers #FFFFFF, Primary Green #1E7D32, Warning Accent #FFF3E0.
- Plus Jakarta Sans Typography, Material Symbols Outlined Icons 24px.
- Clean 8pt grid with distinct section separations.

Layout Anatomy:
1. Top App Bar (Height 56px, white background, elevation-1):
   - Left Back arrow icon ('arrow_back', #0F172A).
   - Title Large: "Buat Permintaan Jemput" (18px Bold #0F172A).
2. Scrollable Form Body (Margin horizontal 16px, padding top 16px, bottom 100px):
   - Section 1: Lokasi Penjemputan (Header 15px Bold #0F172A).
     - White card (#FFFFFF, BorderRadius 12px, padding 14px, elevation-1, border 1px solid #E2E8F0). Features green location pin icon 'location_on', text "Rumah Utama - Jl. Merpati No. 45, Bandung" (14px SemiBold #0F172A), and right small link button "Ubah Alamat ->" (#1E7D32).
   - Section 2: Jadwal & Sesi Waktu (Margin top 20px).
     - Two selectable pill session cards: Card 1 "Besok Pagi (08.00 - 11.00 WIB)" (ACTIVE state: border 2px solid #1E7D32, background #E8F5E9, check icon), Card 2 "Besok Siang (13.00 - 16.00 WIB)" (inactive white border #E2E8F0).
   - Section 3: Rincian Sampah - Tahap 1 Estimasi (Margin top 20px).
     - Dynamic Item Card 1: White card container with 2 input fields side-by-side. Left (65% width): Outlined Dropdown "Jenis Sampah" showing "Plastik PET Bersih (2.500 Poin/Kg)". Right (33% width): Outlined Number TextField "Estimasi Berat (Kg)" showing "3.5" kg.
     - Outlined Button below card: "+ Tambah Jenis Sampah Lain" (border #1E7D32, text #1E7D32, height 40px, BorderRadius 8px, margin top 10px).
   - Section 4: Real-time Estimasi & Info Banner (Margin top 24px).
     - Warning Info Banner: Light orange container (#FFF3E0, border 1px solid #FF9800, BorderRadius 8px, padding 12px) featuring icon 'info' (#FF9800) and text "Perhatian: Poin yang tertera adalah estimasi awal. Poin sah final akan ditentukan berdasarkan hasil timbangan akhir di gudang Bank Sampah Bersinar." (12px Regular #E65100).
     - Real-time Summary Box: Card #E8F5E9 showing "Total Estimasi Berat: 3.5 Kg" and "Estimasi Poin: ~8.750 Poin" (16px Bold #1E7D32).
3. Fixed Bottom Sticky Action Bar (Height 80px, white surface, elevation-3 shadow, padding horizontal 16px, vertical 14px):
   - Primary Filled Button: Full width "Ajukan Penjemputan Sekarang" (#1E7D32, white text 16px Bold, height 52px, BorderRadius 26px pill).

Visual Vibe: Transparent, effortless, structured, informative, and foolproof.
```

---

### WRG-005 : Orders Screen (Tab 2 Riwayat & Daftar Jemputan)
- **Nama Screen**: `Orders Screen (Tab 2 Daftar Pesanan)`
- **Role**: Warga (Nasabah)
- **Tujuan Screen**: Menampilkan seluruh riwayat dan antrean pesanan penjemputan warga dalam bentuk kartu-kartu ringkas yang dikelompokkan oleh tab filter status.
- **Business Goal**: Memberikan transparansi status pelacakan secara nyata kepada warga agar tidak terjadi kebingungan mengenai posisi jemputan mereka.
- **Referensi dari Screen Catalog**: `WRG-005` (*Need Revision Screen - High Priority*).
- **Komponen yang harus tampil**:
  - *AppBar* dengan judul *"Riwayat Jemputan"* dan tombol refresh.
  - **Horizontal Filter Chips Bar**: `Semua (12)`, `Berjalan (2)` (`pending`, `accepted`, `on_the_way`, `picked_up`, `validating`), `Selesai (9)` (`completed`), `Dibatalkan (1)` (`cancelled`).
  - *Vertical Card ListView* berisi kartu-kartu ringkasan pesanan (*Order Summary Cards*).
  - Setiap kartu pesanan wajib memuat: Nomor Pesanan (`#ORD-XXXX`), Tanggal & Waktu, Alamat Ringkas, Rincian Singkat Item (`Plastik PET 3.5 kg...`), serta **Status Badge Pill** warna-warni sesuai Bab 13.
  - **Bottom Navigation Bar (4 Tabs Shell)** dengan Tab 2 Pesanan aktif.
- **Komponen yang tidak boleh tampil**:
  - Tombol verifikasi admin atau form input berat driver.
- **Navigasi masuk**: *Bottom Navigation Tab 2*, atau redirect dari `WRG-004` pasca-submit.
- **Navigasi keluar**: `OrderDetailScreen (WRG-006)` saat kartu pesanan diklik.
- **Data yang dibutuhkan**: Daftar `orders` milik `id_pengguna` aktif dari endpoint `orders_api.php?id_warga=X`.
- **State**:
  - `Loading`: *Shimmer Skeleton List* (`3 kartu kerangka abu-abu` bersusun vertikal) saat API memuat data.
  - `Empty`: **Empty State Card** dengan ilustrasi vektor tong sampah bersih & pesan *"Belum ada riwayat penjemputan pada tab ini"* berserta tombol CTA *"Buat Jemputan Baru (`WRG-004`)"*.
  - `Error`: *Error State Card mini* berlatar `#FFEBEE` dengan tombol *"Coba Lagi (Retry)"*.
  - `Success`: Daftar kartu dimuat lengkap dan terurut dari waktu terbaru (*DESC*).
- **Business Rules**: Pada kartu berstatus selain `completed` (misal: `pending` atau `validating`), **dilarang menampilkan angka poin sah final**. Kartu tersebut hanya boleh mencantumkan label `estimasi_berat_kg` dan tulisan *"Poin dihitung gudang"*.
- **Status yang digunakan**: Menampilkan seluruh 6 status (`pending` hingga `completed`) dan `cancelled`.
- **CTA utama**: Kartu pesanan itu sendiri (*Clickable Card* menuju `WRG-006`).
- **CTA sekunder**: Tombol *"Buat Jemputan Baru"* pada saat *Empty State*.
- **Design Notes**: Filter chips bar harus diletakkan persis di bawah *AppBar* dengan efek geser horizontal halus. Kartu pesanan menggunakan `elevation-1` dan border `1px solid #E2E8F0`.
- **Accessibility**: Lencana status harus disertai teks label yang jelas (*High contrast badge*). Kartu memiliki padding sentuh `16px`.
- **Animation**: Transisi antar-tab filter menggunakan animasi *fade & scale* `250ms`.
- **Responsive Rules**: Mengikuti Mobile Grid `< 600px`. Pada tablet, kartu-kartu disusun dalam grid 2 kolom (`GridView.builder`).

```prompt
[STITCH AI MASTER PROMPT - WRG-005: Orders Screen (Tab Daftar Pesanan)]
Design a clean, professional Material Design 3 Mobile Orders History screen for the citizen app of "Bank Sampah Bersinar".

Style & Theme Requirements:
- Scaffold background #F8FAFC, Card surface #FFFFFF, Primary Green #1E7D32.
- Plus Jakarta Sans Typography, Material Symbols Outlined Icons 24px.
- Bottom Navigation Bar 4 Tabs active shell (Tab 2 'Pesanan' active).

Layout Anatomy:
1. Top App Bar (Height 56px, white surface, elevation-1):
   - Center Title: "Riwayat Jemputan" (18px Bold #0F172A).
   - Right icon button: 'refresh' (#1E7D32).
2. Horizontal Status Filter Chips Bar (Height 52px, background #FFFFFF, border bottom 1px solid #E2E8F0, horizontal padding 16px):
   - Horizontal scrollable pill chips: Chip 1 "Semua (12)" (inactive white border #E2E8F0), Chip 2 "Berjalan (2)" (ACTIVE state: #1E7D32 background, white text 13px SemiBold, BorderRadius 20px), Chip 3 "Selesai (9)" (inactive), Chip 4 "Dibatalkan (1)" (inactive).
3. Orders Card ListView (Scrollable vertical, margin horizontal 16px, top 16px, bottom 80px, 12px gap between cards):
   - Active Order Card 1 (Status: on_the_way): White card (#FFFFFF, BorderRadius 12px, border 1.5px solid #1565C0, elevation-2 shadow, padding 16px). Top row: Order ID "#ORD-1024" (15px Bold #0F172A) next to right-aligned Badge Pill "Armada Menuju Lokasi" (Blue #E3F2FD background, text #1565C0 11px SemiBold, icon 'local_shipping'). Middle row: Icon 'calendar_today' with text "10 Jul 2026, 09:30 WIB" (12px #64748B) and icon 'delete_outline' with text "Plastik PET & Kardus (~3.5 Kg Estimasi)" (13px #0F172A). Bottom row: A subtle divider with right text link "Lihat Tracking & Detail ->" (#1565C0 SemiBold).
   - Completed Order Card 2 (Status: completed): White card (BorderRadius 12px, border 1px solid #E2E8F0, elevation-1, padding 16px). Top row: "#ORD-1018" next to Green Badge Pill "Selesai (Poin Sah)" (#E8F5E9 background, text #1B5E20, icon 'check_circle'). Middle row: "05 Jul 2026, 14:15 WIB" and "Plastik PET (Berat Aktual: 4.2 Kg)". Bottom row: Prominent text "Reward Sah: +10.500 Poin" (14px Bold #2E7D32).
   - Pending Order Card 3 (Status: pending): White card with Orange Badge Pill "Menunggu Driver" (#FFF3E0 background, text #E65100, icon 'schedule'). Middle row shows Tahap 1 "Estimasi Berat: 2.0 Kg".
4. Bottom Navigation Bar (Tab 2 active with green icon and pill indicator).

Visual Vibe: Organized, highly scannable, transparent, reassuring, and pristine.
```

---

### WRG-006 : Order Detail Screen (Lini Masa 6 Status & Tabel Audit 3 Tahap)
- **Nama Screen**: `Order Detail Screen (Detail Pesanan & Audit 3 Tahap)`
- **Role**: Warga (Nasabah)
- **Tujuan Screen**: Menyajikan rincian lengkap pesanan tunggal, memvisualisasikan perjalanan 6 status pesanan via *Timeline Stepper*, menyajikan **Tabel Audit Sanding 3 Tahap Berat (`estimasi` vs `driver` vs `aktual`)**, dan menyediakan kontak/tracking armada penjemput.
- **Business Goal**: Memberikan transparansi mutlak (*Total Auditability*) atas seluruh proses penimbangan, sehingga nasabah percaya penuh bahwa tidak ada manipulasi dalam perhitungan reward poin.
- **Referensi dari Screen Catalog**: `WRG-006` (*Need Revision Screen - Critical Priority*).
- **Komponen yang harus tampil**:
  - *AppBar* dengan judul *"Detail Jemputan #ORD-XXXX"* dan tombol Back Arrow.
  - **Lini Masa 6 Status Pesanan (*Timeline Stepper*)**: Menunjukkan progress dari `pending` $\rightarrow$ `accepted` $\rightarrow$ `on_the_way` $\rightarrow$ `picked_up` $\rightarrow$ `validating` $\rightarrow$ `completed`.
  - **Driver & Vehicle Contact Card**: Foto armada, Nama Driver (`driver.nama`), Plat Kendaraan (`driver.plat`), serta 2 tombol mini **"Call (`phone`)"** & **"WhatsApp (`chat`)"** (menggunakan `url_launcher`).
  - **Tabel Audit Sanding 3 Tahap Penimbangan Muatan**:
    - Kolom 1: Nama Item Sampah (`Plastik PET`, `Kardus`).
    - Kolom 2: **Estimasi Warga (`estimasi_berat_kg` Tahap 1)**.
    - Kolom 3: **Timbang Driver (`berat_driver_kg` Tahap 2)** (Muncul pasca `picked_up`).
    - Kolom 4: **Timbang Akhir Gudang (`berat_aktual_kg` Tahap 3)** (Muncul pasca `completed`).
  - *Reward Summary Card*: Menampilkan total Poin Sah Masuk (`poin_final`) **HANYA JIKA status == `completed`**.
  - **Tombol Aksi Utama Bersyarat**: Tombol Biru Bersinar **"Lihat Peta Realtime & ETA (`WRG-007`)"** (HANYA AKTIF SAAT `status == 'on_the_way'`).
  - Tombol sekunder: **"Batalkan Jemputan"** (Hanya aktif saat `pending` / `accepted`).
- **Komponen yang tidak boleh tampil**:
  - Tombol edit atau hapus data pesanan yang sudah berjalan.
- **Navigasi masuk**: `OrdersScreen (WRG-005)` atau *deep-link* dari notifikasi `WRG-009`.
- **Navigasi keluar**: `DriverTrackingScreen (WRG-007)` saat klik tracking peta, atau `url_launcher` saat kontak WA/telepon.
- **Data yang dibutuhkan**: Detail `orders` + `order_items` (kumpulan ketiga angka berat per item), `driver.nama`, `driver.no_telepon`, `driver.plat_nomor`.
- **State**:
  - `Loading`: *Shimmer skeleton* pada area timeline dan tabel audit (`height 280px`).
  - `Empty`: *Not applicable*.
  - `Error`: *Error Card* jika ID pesanan tidak ditemukan di database (`404 Not Found`).
  - `Success`: Rincian dimuat utuh dengan perbandingan angka berat yang akurat.
- **Business Rules**: **ATURAN MUTLAK TRANSPARANSI**: Jika status belum mencapai `completed`, kolom `berat_aktual_kg` dan `poin_final` pada tabel audit harus diisi tanda hubung (` - `) dengan keterangan label *"Sedang divalidasi oleh petugas gudang"*. Poin sah dilarang ditampilkan sebelum waktu tersebut. Tombol *Tracking Peta* wajib disembunyikan/disabled jika status bukan `on_the_way`.
- **Status yang digunakan**: Menyoroti 1 dari 6 status pesanan saat ini.
- **CTA utama**: Tombol Biru **"Lihat Peta Realtime & ETA"** (Khusus `on_the_way`).
- **CTA sekunder**: Tombol Merah Outlined **"Batalkan Jemputan"** (Khusus `pending` / `accepted`).
- **Design Notes**: Tabel audit 3 tahap harus dirancang dalam format kartu putih bersih dengan garis pembatas halus agar angka kilogram mudah dipindai dan dibandingkan oleh warga.
- **Accessibility**: Teks pada tabel audit minimal `13px` dengan kontras tinggi. Lini masa status menyertakan ikon centang pada langkah yang selesai.
- **Animation**: Stepper status aktif memiliki animasi kilau berdenyut halus (*Soft Pulse Glow*).
- **Responsive Rules**: Mengikuti Mobile Grid `< 600px`. Tabel audit dapat digeser secara horizontal jika nama item terlalu panjang di layar kecil.

```prompt
[STITCH AI MASTER PROMPT - WRG-006: Order Detail Screen (Audit 3 Tahap)]
Design a comprehensive, high-fidelity Material Design 3 Mobile Order Detail & Audit screen for the citizen app of "Bank Sampah Bersinar".

Style & Theme Requirements:
- Scaffold background #F8FAFC, Card containers #FFFFFF, Primary Green #1E7D32, Info Blue #1565C0.
- Plus Jakarta Sans Typography, Material Symbols Outlined Icons 24px.
- Clean 8pt grid with sharp informational hierarchy.

Layout Anatomy:
1. Top App Bar (Height 56px, white background, elevation-1):
   - Left Back arrow icon ('arrow_back', #0F172A).
   - Title Large: "Detail Jemputan #ORD-1024" (18px Bold #0F172A).
   - Right Status Badge Pill: "Armada Menuju Lokasi" (#E3F2FD background, text #1565C0 12px SemiBold).
2. Scrollable Detail Body (Margin horizontal 16px, top 16px, bottom 100px):
   - Section 1: Lini Masa 6 Status Pesanan (Timeline Stepper Card, #FFFFFF, BorderRadius 12px, padding 16px, elevation-1).
     - Vertical Stepper displaying 6 chronological circles: Step 1 'Pending' (Green check #2E7D32), Step 2 'Accepted' (Green check), Step 3 'On The Way' (ACTIVE glowing blue circle #1565C0 with truck icon 'local_shipping'), Step 4 'Picked Up' (Gray dashed #E2E8F0), Step 5 'Validating' (Gray), Step 6 'Completed' (Gray).
   - Section 2: Kontak Armada Driver (Margin top 16px, White card, BorderRadius 12px, padding 14px, border 1px solid #E3F2FD).
     - Left: Circular avatar image of driver (44px) next to text: "Budi Santoso (Driver Armada)" (14px Bold #0F172A) and "Plat Truk: D 8821 XA" (12px #64748B).
     - Right: Two circular action buttons (36px x 36px): Green WhatsApp icon button (#E8F5E9 background, icon #1E7D32) and Blue Call icon button (#E1F5FE background, icon #0288D1).
   - Section 3: Tabel Audit Sanding 3 Tahap Penimbangan (Margin top 20px, White card, BorderRadius 12px, padding 16px, elevation-1).
     - Title: "Audit Penimbangan & Rincian Muatan" (15px Bold #0F172A).
     - A clean data comparison table/grid displaying 2 rows of items:
       - Row 1: Item "Plastik PET Bersih" | Tahap 1 Estimasi: "3.5 Kg" | Tahap 2 Driver: "3.2 Kg (Diangkut)" | Tahap 3 Gudang: " - (Menunggu Gudang)".
       - Row 2: Item "Kertas Kardus" | Tahap 1 Estimasi: "5.0 Kg" | Tahap 2 Driver: "4.8 Kg (Diangkut)" | Tahap 3 Gudang: " - (Menunggu Gudang)".
     - Bottom note inside card: "Poin sah final akan dikalkulasi otomatis dari angka Tahap 3 (Timbang Akhir Gudang)." (12px Italic #64748B).
3. Fixed Bottom Action Container (Height 80px, white surface, elevation-3 shadow, padding horizontal 16px, vertical 14px):
   - Primary Glowing Button: Full width "Lihat Peta Realtime & ETA ->" (#1565C0 Blue background, white text 16px Bold, height 52px, BorderRadius 26px pill, prominent elevation-2).

Visual Vibe: Highly transparent, authoritative, meticulously audited, trustworthy, and clear.
```

---

### WRG-007 : Driver Tracking Screen (Peta Live & ETA - New Screen)
- **Nama Screen**: `Driver Tracking Screen (Peta Pemantauan Realtime)`
- **Role**: Warga (Nasabah)
- **Tujuan Screen**: Memvisualisasikan posisi armada truk secara live pada peta OpenStreetMap (`flutter_map`) dan menyajikan estimasi waktu kedatangan (*Estimated Time of Arrival / ETA*) secara tepat saat status order berstatus `on_the_way`.
- **Business Goal**: Menghadirkan rasa tenang dan kepastian waktu bagi warga, mengurangi panggilan telepon pertanyaan ke admin/driver.
- **Referensi dari Screen Catalog**: `WRG-007` (*New Screen - Medium Priority*).
- **Komponen yang harus tampil**:
  - **Fullscreen Map View (`flutter_map` / OpenStreetMap TileLayer)**: Membentang penuh di seluruh latar belakang layar.
  - Penanda Titik Rumah Warga (*Destination Pin* berwarna merah/hijau dengan ikon `home`).
  - Penanda Titik Armada Truk Bergerak (*Driver Truck Marker* berwarna biru/hijau tajam dengan ikon `local_shipping` bersinar).
  - Garis Rute Polyline (*PolylineLayer*) berwarna hijau/biru `#1565C0` (`width 4px`) yang menghubungkan truk dengan rumah warga.
  - *Floating Back Button* di pojok kiri atas lingkaran putih `radiusFull (40px)` bershadow.
  - **Draggable Bottom Sheet Panel** (melayang di bagian bawah dengan `radiusLG 16px` di sudut atas):
    - *Drag Handle Pill* abu-abu.
    - Judul Status: **"Armada Sedang Menuju Rumah Anda"**.
    - Rincian ETA & Jarak: **"Perkiraan Tiba: ± 12 Menit (2.8 KM)"** (Teks *Headline Large* `#1E7D32`).
    - Kartu Info Driver (Foto, Nama Driver `Budi Santoso`, Plat Truk `D 8821 XA`).
    - Tombol Aksi Langsung: **"Hubungi Driver via WhatsApp"** (`url_launcher`).
- **Komponen yang tidak boleh tampil**:
  - Tombol edit order, input penimbangan, atau navigasi admin.
- **Navigasi masuk**: `OrderDetailScreen (WRG-006)` saat menekan tombol *Lihat Peta Realtime* (khusus status `on_the_way`).
- **Navigasi keluar**: Kembali ke `WRG-006` saat menekan tombol Back atau meminimalkan *Bottom Sheet*.
- **Data yang dibutuhkan**: Kueri `driver_api.php?action=get_location&id_driver=X` (menghasilkan JSON `current_lat`, `current_long` secara berkala setiap 10 detik via background polling).
- **State**:
  - `Loading`: Peta memuat ubin (*map tiles*) dengan *shimmer loading overlay* sementara.
  - `Empty`: *Not applicable*.
  - `Error`: Jika sinyal GPS armada terputus $> 3$ menit, muncul **Banner Peringatan Kuning `#FFF3E0`** di atas *Bottom Sheet*: *"Sinyal GPS armada lemah. Menampilkan posisi terakhir yang diketahui pada pukul 09:35 WIB."*
  - `Success`: Peta menampilkan pergerakan live truk secara presisi.
- **Business Rules**: **ATURAN AKSES KETAT**: Layar ini **HANYA DAPAT DIAKSES jika status pesanan == `'on_the_way'`**. Jika order berubah menjadi `picked_up` atau `completed`, aplikasi akan mengalihkan warga kembali ke `WRG-006`.
- **Status yang digunakan**: Khusus status **`on_the_way`**.
- **CTA utama**: Tombol *Filled Green Button* **"Hubungi Driver via WhatsApp (`chat`)"** di dalam *Bottom Sheet*.
- **CTA sekunder**: Tombol ikon *Call (`phone`)* berdampingan dengan WhatsApp.
- **Design Notes**: *Bottom Sheet* harus dirancang dengan mode *peek (`initialChildSize: 0.35`)* agar peta di atasnya tetap terlihat luas sebesar 65% layar.
- **Accessibility**: Panel bottom sheet memiliki kontras tinggi (`#FFFFFF` surface dengan teks `#0F172A`).
- **Animation**: Penanda ikon truk bergeser secara mulus di atas peta menggunakan animasi interpolasi koordinat (`TweenAnimationBuilder` `1000ms`).
- **Responsive Rules**: Mengikuti Mobile Grid `< 600px`. Peta menyesuaikan rasio aspek layar secara otomatis.

```prompt
[STITCH AI MASTER PROMPT - WRG-007: Driver Tracking Screen (Peta Live & ETA)]
Design a state-of-the-art, high-fidelity Material Design 3 Mobile Live Tracking & GPS Map screen for the citizen app of "Bank Sampah Bersinar".

Style & Theme Requirements:
- Fullscreen OpenStreetMap / GPS Map layout with pristine white overlay components (#FFFFFF), Brand Green (#1E7D32), and Tracking Blue (#1565C0).
- Plus Jakarta Sans Typography, Material Symbols Outlined Icons 24px.
- Clean 8pt spacing inside floating panels.

Layout Anatomy:
1. Fullscreen Map Layer (Background across 100% of the screen):
   - Highly detailed, crisp street map of a residential area in Bandung.
   - A thick, glowing blue/green navigation polyline route (`4px width, #1565C0`) connecting the driver truck to the citizen's home.
   - Citizen Home Pin: A red/green circular destination marker ('home' icon, 36px) at the end of the route labeled "Rumah Anda".
   - Live Driver Truck Marker: A glowing circular blue badge (44px, #1565C0 with white border) containing truck icon 'local_shipping', positioned along the polyline.
2. Floating Top Controls (Padding top 44px, horizontal 16px):
   - Left: A clean circular white Back button (40px x 40px, elevation-2 shadow, #0F172A 'arrow_back' icon).
   - Right: A floating white Status Pill badge (padding 6px 14px, elevation-2, text "Live GPS Active" with a pulsing green dot #1E7D32).
3. Draggable Bottom Sheet Panel (Resting at the bottom 38% of the screen, white surface #FFFFFF, top corner BorderRadius 20px, elevation-3 shadow):
   - Top Center: Gray drag handle pill (width 40px, height 4px, #CBD5E1).
   - ETA & Status Header (Padding horizontal 20px, top 12px):
     - Headline Large: "Perkiraan Tiba: ± 12 Menit" (22px Bold #1E7D32).
     - Subtitle: "Armada berjarak 2.8 KM dari rumah Anda (#ORD-1024)" (13px Regular #64748B).
   - Driver Contact Divider Card (Margin top 16px, horizontal 20px, light gray container #F8FAFC, padding 12px, BorderRadius 12px):
     - Left: Driver profile photo (44px avatar) next to "Budi Santoso" (14px Bold #0F172A) and "Plat Truk: D 8821 XA" (12px #64748B).
     - Right: Two round action buttons (36px): Green WhatsApp button ('chat', #1E7D32) and Blue Call button ('phone', #0288D1).
   - Bottom Primary CTA (Margin top 16px, horizontal 20px, bottom 20px):
     - Full-width Filled Button: "Hubungi Driver via WhatsApp" (#1E7D32 background, white text 15px SemiBold, height 48px, BorderRadius 24px pill).

Visual Vibe: Dynamic, reassuring, highly responsive, modern, and trustworthy.
```

---

### WRG-008 : AI Scan & Education Module
- **Nama Screen**: `AI Scan & Education Module (Kamera Deteksi & Edukasi)`
- **Role**: Warga (Nasabah)
- **Tujuan Screen**: Menyediakan fitur pemindaian kamera pintar berteknologi *Machine Learning* untuk mendeteksi jenis sampah secara otomatis dari gambar, memperkirakan nilai poin per kg, serta menyajikan katalog artikel edukasi daur ulang.
- **Business Goal**: Meningkatkan literasi lingkungan warga dalam memilah sampah dengan benar sejak dari rumah, sekaligus memberikan kemudahan pengisian form jemputan.
- **Referensi dari Screen Catalog**: `WRG-008` (*Existing Screen - Low Priority enhancement*).
- **Komponen yang harus tampil**:
  - *Tabbed Header Bar*: Tab 1 **"Kamera Scan AI (`qr_code_scanner`)"** vs Tab 2 **"Katalog Edukasi (`menu_book`)"**.
  - *Tab 1 Camera Viewfinder*:
    - Tampilan kamera fullscreen (`camera` package viewfinder) dengan bingkai pembatas persegi bergaris hijau berdenyut (`Bounding Box`).
    - Tombol Shutter kamera circular besar `radiusFull (68px)` di tengah bawah berborder putih tebal.
    - Tombol *Flashlight toggle* dan *Gallery Upload* di kanan/kiri shutter.
    - **AI Classification Result Bottom Sheet** (Muncul setelah foto diambil): Menampilkan thumbnail foto, Nama Deteksi AI (*e.g., "Terdeteksi: Plastik PET Bersih (Akurasi 94%)"*), Estimasi Poin per KG (`Rp 2.500 / Poin per Kg`), dan tombol CTA **"Simpan & Masukkan ke Form Jemputan (`WRG-004`)"**.
  - *Tab 2 Katalog Edukasi*:
    - Daftar artikel lingkungan berbentuk *Vertical Card ListView* (`edukasi_api.php`) dengan gambar thumbnail vektor, judul artikel *Title Medium*, dan ringkasan singkat *Body Medium*.
- **Komponen yang tidak boleh tampil**:
  - Form penimbangan akhir gudang atau tombol modifikasi admin.
- **Navigasi masuk**: `HomeScreen (WRG-003)` saat klik *Scan AI*.
- **Navigasi keluar**: `PickupRequestScreen (WRG-004)` saat tombol *"Simpan ke Form Jemputan"* diklik, atau `ArticleDetailModal` saat artikel diklik.
- **Data yang dibutuhkan**: Akses hardware kamera peramban/mobile, model ML klasifikasi sampah lokal/API, daftar `edukasi` dari `edukasi_api.php`.
- **State**:
  - `Loading`: *Spinner circular green* saat model ML sedang menganalisis gambar foto (`Processing AI Inference...`).
  - `Empty`: Tab Edukasi menampilkan *Empty State Card* jika belum ada artikel yang diterbitkan admin.
  - `Error`: Pesan kesalahan *"Kamera tidak dapat diakses atau izin ditolak. Silakan aktifkan izin kamera di pengaturan telepon Anda."*
  - `Success`: Klasifikasi AI sukses memunculkan *Bottom Sheet* hasil yang akurat.
- **Business Rules**: Hasil klasifikasi AI dan estimasi poin di layar ini **bersifat informatif dan TIDAK BOLEH memutasi saldo poin warga**.
- **Status yang digunakan**: *None* (Fitur pendukung/edukasi).
- **CTA utama**: Tombol Shutter Kamera (`68px`) $\rightarrow$ Tombol **"Masukkan ke Form Jemputan (`WRG-004`)"**.
- **CTA sekunder**: Tombol **"Pilih dari Galeri Foto"**.
- **Design Notes**: Viewfinder kamera harus memiliki *dark vignette overlay* (opasitas 40%) di luar area kotak pembatas agar fokus pengguna tertuju pada objek sampah di tengah.
- **Accessibility**: Tombol shutter berukuran sangat besar dan dilengkapi umpan balik getaran (*Haptic Feedback*).
- **Animation**: Garis pemindai (*laser scan line*) hijau `#1E7D32` bergerak naik turun di dalam kotak viewfinder (`1500ms loop`).
- **Responsive Rules**: Mengikuti Mobile Grid `< 600px`.

```prompt
[STITCH AI MASTER PROMPT - WRG-008: AI Scan & Education Module]
Design an interactive, futuristic yet clean Material Design 3 Mobile AI Camera Scanner & Education screen for the citizen app of "Bank Sampah Bersinar".

Style & Theme Requirements:
- Fullscreen Camera Viewfinder with dark semi-transparent vignette surrounding a crisp white/green scan frame (#1E7D32), paired with a pristine white Bottom Sheet (#FFFFFF).
- Plus Jakarta Sans Typography, Material Symbols Outlined Icons 24px.
- 8pt spacing inside data panels.

Layout Anatomy:
1. Top Header Controls (Floating over camera viewfinder, top 44px, horizontal 16px):
   - Left: Circular white Back button ('arrow_back', #0F172A).
   - Center Top Tab Pill: Segmented toggle with Tab 1 "Scan AI" (ACTIVE green pill #1E7D32, white text) and Tab 2 "Edukasi" (transparent, white text).
   - Right: Circular Flashlight toggle button ('flash_on', white).
2. Center Camera Viewfinder Area:
   - Live camera feed showing plastic bottles on a table.
   - Center Bounding Box: A square scan frame (`260px x 260px`) with glowing emerald green corner borders (`#1E7D32, 3px thickness`) and a subtle green laser scanning line moving vertically across the box.
   - Helper text below box: "Arahkan kamera ke sampah daur ulang Anda" (14px Medium, white with drop shadow).
3. Bottom Camera Shutter Bar (Fixed at bottom, height 110px, dark acrylic background):
   - Left: Gallery upload icon button ('photo_library', 32px, white).
   - Center: Large circular Shutter button (68px x 68px, white outer ring 4px, solid emerald green inner circle #1E7D32 with camera icon).
   - Right: Help/Guide icon button ('help_outline', 32px, white).
4. AI Classification Result Bottom Sheet (Overlaid floating over bottom half, white surface #FFFFFF, top corner BorderRadius 20px, elevation-3):
   - Top Drag Handle pill.
   - Header: Green Verified Badge "AI Klasifikasi Berhasil (Akurasi 94%)" (#E8F5E9 background, text #1E7D32 12px SemiBold).
   - Main Result Card (Margin top 12px, horizontal 20px):
     - Left: Thumbnail of scanned plastic bottle (`60px x 60px`, rounded).
     - Right Column: Title "Plastik PET Bersih" (16px Bold #0F172A), Subtitle "Kategori: Botol Minuman Plastik" (13px #64748B), and Value Pill "Estimasi: Rp 2.500 / Poin per Kg" (14px Bold #1E7D32).
   - Bottom CTA (Margin top 16px, horizontal 20px, bottom 20px):
     - Full-width Filled Button: "Simpan & Masukkan ke Form Jemputan" (#1E7D32 background, white text 15px SemiBold, height 48px, BorderRadius 24px pill).

Visual Vibe: High-tech, smart, engaging, eco-conscious, precise, and user-friendly.
```

---

### WRG-009 : Alerts & Reward History Screen
- **Nama Screen**: `Alerts & Reward History Screen (Tab 3 Notifikasi & Poin)`
- **Role**: Warga (Nasabah)
- **Tujuan Screen**: Menampilkan daftar notifikasi sistem (perubahan status pesanan, penugasan driver) dan menyajikan riwayat lengkap penambahan **Saldo Poin Sah (`poin_final`)** yang masuk dari pesanan yang telah berstatus `completed`.
- **Business Goal**: Memperkuat kepercayaan nasabah melalui riwayat audit penambahan saldo poin yang transparan dan akurat.
- **Referensi dari Screen Catalog**: `WRG-009` (*Need Revision Screen - High Priority*).
- **Komponen yang harus tampil**:
  - *AppBar* dengan judul *"Notifikasi & Riwayat Poin"*.
  - **Top Segmented Tabs**: Tab 1 **"Notifikasi Sistem (`notifications`)"** vs Tab 2 **"Riwayat Poin Sah (`payments`)"**.
  - *Tab 1 ListView*: Kartu-kartu notifikasi masuk dari tabel `notifikasi` dengan ikon lonceng, judul, pesan, dan *timestamp* `Body Small`.
  - *Tab 2 ListView (Reward History)*:
    - Kartu-kartu riwayat mutasi poin sah yang HANYA bersumber dari pesanan `completed`.
    - Setiap kartu mencantumkan: Nomor Pesanan (`#ORD-XXXX`), Tanggal Penyelesaian, Berat Aktual Gudang (`berat_aktual_kg` Tahap 3), serta **Angka Penambahan Poin Hijau (`+14.500 Poin`)**.
  - **Bottom Navigation Bar (4 Tabs Shell)** dengan Tab 3 Notifikasi aktif.
- **Komponen yang tidak boleh tampil**:
  - Poin dari pesanan yang masih berstatus `pending`, `accepted`, `on_the_way`, `picked_up`, atau `validating` (karena belum sah diakumulasikan).
- **Navigasi masuk**: *Bottom Navigation Tab 3* atau klik ikon lonceng di `HomeScreen`.
- **Navigasi keluar**: `OrderDetailScreen (WRG-006)` saat item notifikasi/riwayat diklik.
- **Data yang dibutuhkan**: Tabel `notifikasi WHERE id_pengguna = X`, dan `orders WHERE id_warga = X AND status = 'completed'`.
- **State**:
  - `Loading`: *Shimmer skeleton list* (`4 kartu kerangka`).
  - `Empty`: **Empty State Card** ilustrasi lonceng hening atau koin kosong dengan pesan *"Belum Ada Notifikasi atau Riwayat Poin yang Masuk"*.
  - `Error`: *Error Card mini* jika jaringan gagal memuat daftar notifikasi dari API.
  - `Success`: Daftar terurut sempurna dari tanggal terbaru (*DESC*).
- **Business Rules**: **ATURAN MUTLAK REWARD**: Tab 2 *"Riwayat Poin Sah"* dilarang menampilkan atau menjumlahkan estimasi poin dari pesanan yang belum `completed`. Poin yang tertera di sini harus persis sama dengan yang ditambahkan ke kolom `pengguna.saldo` oleh transaksi ACID Web Admin.
- **Status yang digunakan**: Menyoroti notifikasi perubahan dari ke-6 status order.
- **CTA utama**: Kartu notifikasi itu sendiri (*Clickable Card* menuju `WRG-006`).
- **CTA sekunder**: Tombol *"Tandai Semua Sudah Dibaca"*.
- **Design Notes**: Notifikasi yang belum dibaca (*Unread*) memiliki latar belakang hijau sangat muda `#E8F5E9` dan titik dot merah di sudut kanan atas. Notifikasi yang sudah dibaca berlatar `#FFFFFF`.
- **Accessibility**: Teks pertambahan poin `+XX.XXX` menggunakan font `SemiBold 15px` berkesan positif (`#2E7D32`).
- **Animation**: Pergeseran antar Tab 1 dan Tab 2 menggunakan `TabBarView` dengan geseran halus `250ms`.
- **Responsive Rules**: Mengikuti Mobile Grid `< 600px`.

```prompt
[STITCH AI MASTER PROMPT - WRG-009: Alerts & Reward History Screen]
Design a highly structured, trustworthy Material Design 3 Mobile Alerts & Reward History screen for the citizen app of "Bank Sampah Bersinar".

Style & Theme Requirements:
- Scaffold background #F8FAFC, Card containers #FFFFFF, Primary Green #1E7D32, Success Green #2E7D32.
- Plus Jakarta Sans Typography, Material Symbols Outlined Icons 24px.
- Bottom Navigation Bar 4 Tabs active shell (Tab 3 'Notifikasi' active).

Layout Anatomy:
1. Top App Bar (Height 56px, white surface, elevation-1):
   - Center Title: "Notifikasi & Riwayat Poin" (18px Bold #0F172A).
   - Right Text Button: "Tandai Dibaca" (#1E7D32, 12px SemiBold).
2. Segmented Top Tab Bar (Height 48px, white background, border bottom 1px solid #E2E8F0):
   - 2 Equal Tabs: Tab 1 "Notifikasi Sistem" (ACTIVE with solid green bottom border 2px #1E7D32 and text #1E7D32 SemiBold), Tab 2 "Riwayat Poin Sah" (inactive gray text #64748B).
3. Scrollable Notification ListView (Margin horizontal 16px, top 16px, bottom 80px, 12px gap between items):
   - Unread Notification Card 1 (Reward Added): Light green container (#E8F5E9, border 1px solid #4CAF50, BorderRadius 12px, padding 14px, elevation-1). Left icon: circular green badge with gold coin/check icon ('monetization_on', #1E7D32). Center Column: Title "Reward Poin Berhasil Ditambahkan!" (14px Bold #0F172A), Message "Selamat! Anda mendapatkan +14.500 Poin Sah dari pesanan #ORD-1018 berdasarkan penimbangan aktual gudang 4.2 Kg." (13px Regular #1E7D32, line-height 18px). Right Top: Tiny red unread dot and timestamp "10m lalu" (11px #64748B).
   - Notification Card 2 (Driver On The Way): White card (#FFFFFF, border 1px solid #E2E8F0, BorderRadius 12px, padding 14px). Left icon: blue circle with truck icon ('local_shipping', #0288D1). Title "Armada Sedang Menuju Rumah Anda" (14px Bold #0F172A), Message "Driver Budi Santoso (D 8821 XA) sedang dalam perjalanan. Lihat tracking peta sekarang." (13px #64748B). Timestamp "25m lalu".
   - Read Notification Card 3 (Order Accepted): White card with orange/schedule icon showing "Pesanan #ORD-1024 Diterima Driver" (Timestamp "2 jam lalu").
4. Bottom Navigation Bar (Tab 3 active with green icon and pill indicator).

Visual Vibe: Audited, transparent, rewarding, well-organized, and clear.
```

---

### WRG-010 : Profile & Settings Screen
- **Nama Screen**: `Profile & Settings Screen (Tab 4 Profil Warga)`
- **Role**: Warga (Nasabah)
- **Tujuan Screen**: Menyajikan informasi identitas akun nasabah, mengelola alamat domisili penjemputan default, melihat bantuan FAQ, dan melakukan *Logout* dari aplikasi.
- **Business Goal**: Memudahkan nasabah memelihara keakuratan data diri dan alamat penjemputan demi kelancaran operasional armada driver di lapangan.
- **Referensi dari Screen Catalog**: `WRG-010` (*Existing Screen - Medium Priority*).
- **Komponen yang harus tampil**:
  - *AppBar* dengan judul *"Profil Saya"*.
  - **Header User Profile Section**: Foto Avatar circular (`radiusFull 80px`), Nama Lengkap (`pengguna.nama_lengkap`), Nomor Telepon (`pengguna.no_telepon`), serta Lencana *"Nasabah Terverifikasi"*.
  - *Address Management Card*: Menampilkan alamat default saat ini dengan tombol *"Ubah Alamat Domisili"*.
  - *Settings Menu List (`ListTile with Chevron Arrow`)*:
    - Menu 1: *"Ubah Data Diri (`person_outline`)"*.
    - Menu 2: *"Daftar Alamat Tersimpan (`location_on`)"*.
    - Menu 3: *"Bantuan & Panduan FAQ (`help_outline`)"*.
    - Menu 4: *"Kebijakan Privasi & Ketentuan Layanan (`policy`)"*.
  - **Logout Action Button**: Tombol Outlined Merah `#D32F2F` di dasar halaman dengan label **"Keluar dari Akun (Logout)"**.
  - **Bottom Navigation Bar (4 Tabs Shell)** dengan Tab 4 Profil aktif.
- **Komponen yang tidak boleh tampil**:
  - Pengaturan spesifikasi truk armada atau tombol konfigurasi server admin.
- **Navigasi masuk**: *Bottom Navigation Tab 4*.
- **Navigasi keluar**: `LoginScreen (WRG-002)` pasca-logout berhasil, atau sub-page ubah alamat.
- **Data yang dibutuhkan**: Tabel `pengguna WHERE id_pengguna = X` dari `warga_api.php`.
- **State**:
  - `Loading`: *Shimmer avatar lingkaran* dan kerangka menu.
  - `Empty`: *Not applicable*.
  - `Error`: *Snackbar* merah jika gagal memutakhirkan data profil ke server.
  - `Success`: Data diri dimuat akurat dan tersimpan lokal di `SharedPreferences`.
- **Business Rules**: Saat tombol *Logout* ditekan, sistem wajib menampilkan **Dialog Konfirmasi Logout**: *"Apakah Anda yakin ingin keluar dari akun Bank Sampah Bersinar?"* Jika dikonfirmasi, seluruh token di `SharedPreferences` dihapus total (*Clear Session*).
- **Status yang digunakan**: *None*.
- **CTA utama**: Tombol Outlined Merah **"Keluar dari Akun (Logout)"** (`#D32F2F`, `height 48px`).
- **CTA sekunder**: Tombol *ListTile* *"Ubah Alamat Domisili"*.
- **Design Notes**: Header profil diberikan latar belakang gradasi hijau muda `#E8F5E9` yang menyatu dengan *AppBar* putih di atasnya.
- **Accessibility**: Tombol logout diberi warna merah peringatan jelas namun tetap memiliki kontras teks yang nyaman (`#D32F2F`).
- **Animation**: Dialog konfirmasi muncul dengan efek *scale-up* `200ms`.
- **Responsive Rules**: Mengikuti Mobile Grid `< 600px`.

```prompt
[STITCH AI MASTER PROMPT - WRG-010: Profile & Settings Screen]
Design a clean, elegant Material Design 3 Mobile Profile & Settings screen for the citizen app of "Bank Sampah Bersinar".

Style & Theme Requirements:
- Scaffold background #F8FAFC, Card surfaces #FFFFFF, Primary Green #1E7D32, Danger Red #D32F2F.
- Plus Jakarta Sans Typography, Material Symbols Outlined Icons 24px.
- Bottom Navigation Bar 4 Tabs active shell (Tab 4 'Profil' active).

Layout Anatomy:
1. Top App Bar (Height 56px, white surface, elevation-0):
   - Center Title: "Profil Saya" (18px Bold #0F172A).
2. Header Profile Section (Margin top 12px, horizontal 16px, gradient container #E8F5E9 to #FFFFFF, BorderRadius 16px, padding 20px, elevation-1 border 1px solid #E2E8F0):
   - Center Column: Circular avatar photo (80px x 80px, border 3px solid #1E7D32) displaying a smiling citizen.
   - Name: "Kevin Khayiss" (20px Bold #0F172A, margin top 12px).
   - Phone: "+62 812-3456-7890" (14px Regular #64748B, margin top 2px).
   - Badge Pill below phone: Green border pill "Verified Member Bank Sampah" (#1E7D32, 11px SemiBold, padding 4px 12px, margin top 8px).
3. Saved Address Card (Margin top 16px, horizontal 16px, white card #FFFFFF, BorderRadius 12px, padding 14px, elevation-1):
   - Top row: Icon 'home' next to "Alamat Jemput Default" (14px Bold #0F172A) and right link "Ubah ->" (#1E7D32).
   - Body: "Jl. Merpati No. 45, RT 03/RW 08, Sukajadi, Kota Bandung, Jawa Barat 40162" (13px Regular #64748B, margin top 6px).
4. Settings Menu ListView (Margin top 16px, horizontal 16px, white container #FFFFFF, BorderRadius 12px, elevation-1):
   - Menu Item 1: Icon 'person_outline' (#1E7D32), Title "Ubah Data Diri" (14px SemiBold #0F172A), Right chevron 'chevron_right' (#94A3B8). Divider below.
   - Menu Item 2: Icon 'location_on' (#1E7D32), Title "Daftar Alamat Tersimpan", Right chevron. Divider below.
   - Menu Item 3: Icon 'help_outline' (#1E7D32), Title "Bantuan & Panduan FAQ", Right chevron. Divider below.
   - Menu Item 4: Icon 'policy' (#1E7D32), Title "Kebijakan Privasi", Right chevron.
5. Logout Action Button (Margin horizontal 16px, top 24px, bottom 80px):
   - Full-width Outlined Danger Button: Border 1.5px solid #D32F2F, white background, red text "Keluar dari Akun (Logout)" (15px SemiBold, height 48px, BorderRadius 24px pill, icon 'logout' in red).
6. Bottom Navigation Bar (Tab 4 active with green icon and pill indicator).

Visual Vibe: Personal, clean, professional, highly organized, and secure.
```

---

## 2. KATALOG PROMPT APLIKASI MOBILE DRIVER (`DRV-001` – `DRV-007`)

---

### DRV-001 : Driver Authentication Gate
- **Nama Screen**: `Driver Login Screen (Portal Khusus Armada)`
- **Role**: Armada Driver Penjemput
- **Tujuan Screen**: Mengotentikasi akun resmi petugas armada penjemput (`level = 'driver'`) sebelum mengaktifkan dasbor penugasan operasional.
- **Business Goal**: Mencegah pihak yang tidak berwenang atau warga biasa mengakses antarmuka penugasan dan data alamat penjemputan nasabah.
- **Referensi dari Screen Catalog**: `DRV-001` (*Existing Screen - High Priority*).
- **Komponen yang harus tampil**:
  - Header berkarakter operasional tajam dengan ikon truk besar `local_shipping` (`#1E7D32`) dan judul **"Portal Armada Penjemput Resmi"**.
  - *TextFormField* Username / Nomor Telepon Armada.
  - *TextFormField* Kata Sandi Armada (dengan toggle visibility).
  - Tombol *Filled Primary High-Contrast* **"Masuk sebagai Armada"** (`height 52px`).
  - Lencana Peringatan Keamanan: *"Akses Terbatas: Hanya untuk petugas armada yang terdaftar resmi di Bank Sampah Bersinar."*
- **Komponen yang tidak boleh tampil**:
  - Tombol *"Daftar Akun Baru"* (karena akun driver hanya diregistrasikan oleh Web Admin di `ADM-006`).
- **Navigasi masuk**: *App Launch* aplikasi `/Halaman-Driver`.
- **Navigasi keluar**: `DashboardScreen (DRV-002)` saat login sukses (*Push Replacement*).
- **Data yang dibutuhkan**: Kredensial POST ke `auth_api.php?action=login_driver`.
- **State**:
  - `Loading`: *Spinner circular green* dalam tombol submit.
  - `Empty`: Form kosong.
  - `Error`: *Snackbar Merah `#D32F2F`* dan peringatan form jika akun yang dimasukkan bukan berlevel `driver`.
  - `Success`: Masuk langsung ke `DRV-002`.
- **Business Rules**: Akun warga biasa (`level = 'warga'`) dilarang login di sini. Akses ditolak secara sistem di API backend.
- **Status yang digunakan**: *None*.
- **CTA utama**: Tombol *Filled Primary* **"Masuk sebagai Armada (`DRV-002`)"**.
- **CTA sekunder**: Tombol *Text Button* *"Hubungi Admin Gudang"* jika lupa sandi armada.
- **Design Notes**: Gunakan font *Bold* dan kontras tinggi (`#0F172A` di atas `#FFFFFF`) agar mudah dibaca di lapangan.
- **Accessibility**: Rasio kontras tinggi $\ge 7.0:1$.
- **Animation**: Tombol beralih ke mode loading `200ms`.
- **Responsive Rules**: Mengikuti Mobile Grid `< 600px`.

```prompt
[STITCH AI MASTER PROMPT - DRV-001: Driver Authentication Gate]
Design a high-contrast, robust, and professional Material Design 3 Mobile Driver Login screen for the operational driver app ("/Halaman-Driver") of "Bank Sampah Bersinar".

Style & Theme Requirements:
- High-contrast operational palette: Pure White background #FFFFFF, Deep Forest Green #1E7D32, Dark Slate #0F172A, and Warning Yellow/Orange borders.
- Plus Jakarta Sans Typography, Material Symbols Outlined Icons 24px.
- Crisp 8pt grid with large touch-friendly form fields.

Layout Anatomy:
1. Top Header Section (Centered, padding top 48px):
   - A bold circular green emblem (`72px x 72px`, background #E8F5E9, border 2px solid #1E7D32) featuring a prominent delivery truck icon 'local_shipping' (40px, #1E7D32).
   - Headline Large: "Portal Armada Penjemput" (24px Bold #0F172A, margin top 16px).
   - Subtitle: "Sistem Manajemen Operasional Bank Sampah Bersinar" (13px Regular #64748B, margin top 4px).
2. Form Fields Container (Margin top 32px, horizontal 16px):
   - Driver ID / Phone Input: High-contrast Outlined TextField (height 54px, BorderRadius 8px, border 1.5px solid #CBD5E1). Prefix icon 'badge' (#1E7D32), floating label "Username / No. Telepon Armada" (#0F172A Bold).
   - Password Input (Margin top 16px): Outlined TextField with prefix icon 'lock', masked dots (••••••••), and right toggle 'visibility_off'.
   - Security Warning Box (Margin top 20px, light orange container #FFF3E0, border 1px solid #FF9800, BorderRadius 8px, padding 12px):
     - Icon 'admin_panel_settings' (#ED6C02) next to text "Akses Terbatas: Portal ini khusus untuk petugas armada resmi yang diregistrasikan oleh Web Admin." (12px SemiBold #E65100).
3. Primary CTA & Support Section (Margin top 24px, horizontal 16px):
   - Primary Button: Full-width Filled Button (#1E7D32 background, white text "Masuk sebagai Armada", 16px Bold, height 52px, BorderRadius 8px operational shape, elevation-2).
   - Support Link: Centered Text Button below "Lupa Sandi Armada? Hubungi Admin Gudang" (13px SemiBold #1E7D32, margin top 16px).

Visual Vibe: Authoritative, industrial-grade, highly legible outdoors, secure, and clear.
```

---

### DRV-002 : Dashboard & Operations Command Center
- **Nama Screen**: `Dashboard Screen (Command Center Tugas Armada)`
- **Role**: Armada Driver Penjemput
- **Tujuan Screen**: Menjadi pusat komando harian armada driver yang menampilkan tombol ketersediaan armada (*Ready / Online Toggle Switch*) serta membagi tugas ke dalam 2 tab operasional utama: **Tab Tugas Pending (Order Baru Siap Jemput)** dan **Tab Tugas Saya (*My Tasks* - Order yang sedang dijalankan)**.
- **Business Goal**: Mempercepat waktu tanggap (*Response Time*) armada dalam mengambil alih pesanan baru di wilayah mereka secara efisien.
- **Referensi dari Screen Catalog**: `DRV-002` (*Existing Screen - Critical Priority*).
- **Komponen yang harus tampil**:
  - *Operational Top Bar*: Status Kendaraan Truk (Plat Nomor `D 8821 XA`) & **Status Ketersediaan Armada Toggle Switch (`Online / Siap Jemput` berwarna hijau nyala vs `Offline`)**.
  - **Top Segmented 2 Tabs Bar**:
    - Tab 1: **"Tugas Pending (3)"** — Daftar order baru berstatus `pending` di wilayah kerja.
    - Tab 2: **"Tugas Saya / My Tasks (2)"** — Daftar order yang sedang ditangani driver ini (`accepted` & `on_the_way`).
  - *Task Card Items (High-Contrast Layout)*:
    - Kartu di Tab 1 (Pending): Menampilkan Nomor Order (`#ORD-1024`), Alamat Lengkap berukuran font besar (`15px Bold`), Estimasi Berat Tahap 1 (`~3.5 Kg`), dan **Tombol Aksi Hijau Tajam "Terima Tugas (`accepted`)"**.
    - Kartu di Tab 2 (My Tasks): Menampilkan Lencana Status (`accepted` / `on_the_way`), Alamat Warga, Nomor Telepon, dan **Tombol CTA "Buka Detail & Navigasi (`DRV-003`)"**.
- **Komponen yang tidak boleh tampil**:
  - Harga poin atau estimasi nilai rupiah warga (Driver tidak perlu/tidak berwenang melihat konversi rupiah warga demi isolasi privasi).
- **Navigasi masuk**: `DRV-001 (Login)` atau kembali dari `DRV-005 (Handover)`.
- **Navigasi keluar**: `PickupDetailScreen (DRV-003)` saat kartu di Tab 2 diklik, atau saat klik tombol *Terima Tugas* di Tab 1.
- **Data yang dibutuhkan**: Kueri `driver_api.php?action=get_tasks&id_driver=X&status=pending` dan `status=my_tasks`.
- **State**:
  - `Loading`: *Shimmer skeleton list* berstruktur kartu tebal.
  - `Empty`: Tab 1 Pending menampilkan *Empty Card* dengan ilustrasi truk istirahat: *"Belum ada order penjemputan baru di wilayah Anda saat ini."* Tab 2 menampilkan *"Belum ada tugas aktif yang sedang Anda tangani."*
  - `Error`: *Snackbar* kesalahan jaringan & tombol refresh manual.
  - `Success`: Kartu tugas dimuat akurat dan langsung memperbarui antrean secara *real-time*.
- **Business Rules**: Saat tombol **"Terima Tugas"** ditekan di Tab 1, sistem mengeksekusi `PUT orders_api.php` (`status = 'accepted'`, `id_driver = active_id`). Order tersebut **hilang seketika dari Tab Pending seluruh armada lain** dan berpindah ke Tab *Tugas Saya* milik driver pengklik.
- **Status yang digunakan**: Menangani status `pending`, `accepted`, dan `on_the_way`.
- **CTA utama**: Tombol **"Terima Tugas (`accepted`)"** (Tab 1) & Tombol **"Buka Detail & Navigasi (`DRV-003`)"** (Tab 2).
- **CTA sekunder**: Tombol *Toggle Switch Ketersediaan Armada*.
- **Design Notes**: Gunakan font hitam pekat `#0F172A` di atas kartu putih `#FFFFFF` berborder tebal `1.5px solid #CBD5E1` agar tulisan alamat rumah warga sangat jelas terbaca oleh supir truk saat mengemudi.
- **Accessibility**: Area klik tombol *Terima Tugas* berukuran minimal `height 48px` full-width di dalam kartu.
- **Animation**: Kartu yang diterima bergeser dengan animasi *slide-out to right* dan berpindah ke Tab 2 secara mulus (`300ms`).
- **Responsive Rules**: Mengikuti Mobile Grid `< 600px`. Pada tablet operasional yang terpasang di dasbor truk, kartu ditampilkan dalam 2 kolom grid.

```prompt
[STITCH AI MASTER PROMPT - DRV-002: Dashboard & Command Center Armada]
Design a rugged, high-contrast, highly functional Material Design 3 Mobile Driver Dashboard Command Center for the operational app ("Halaman-Driver") of "Bank Sampah Bersinar".

Style & Theme Requirements:
- High-contrast operational styling: Pure White surface #FFFFFF, Deep Emerald Green #1E7D32, Dark Slate #0F172A, and crisp borders.
- Plus Jakarta Sans Typography, Material Symbols Outlined Icons 24px.
- Built specifically for outdoor sunlight readability with large, bold text labels.

Layout Anatomy:
1. Operational Top Bar (Height 68px, white background #FFFFFF, border bottom 1.5px solid #E2E8F0, horizontal padding 16px):
   - Left: Truck badge icon 'local_shipping' (#1E7D32) next to column: "Armada Aktif" (12px #64748B) and "Plat: D 8821 XA (Truk Bak)" (15px Bold #0F172A).
   - Right Toggle Box: An active green M3 Switch toggle labeled "ONLINE / SIAP" (#1E7D32 SemiBold 12px, glowing green status dot).
2. Segmented Operational Tabs (Height 52px, white surface, border bottom 1.5px solid #CBD5E1):
   - 2 Equal Tabs: Tab 1 "Tugas Pending (3)" (ACTIVE: solid green bottom border 3px #1E7D32, text 15px Bold #1E7D32), Tab 2 "Tugas Saya (2)" (inactive slate text #64748B 15px Medium).
3. Task Cards ListView (Scrollable vertical, margin horizontal 16px, top 16px, bottom 24px, 16px gap between cards):
   - Pending Task Card 1 (Ready to Accept): High-contrast white card (#FFFFFF, BorderRadius 12px, border 2px solid #1E7D32, elevation-2 shadow, padding 16px).
     - Top row: Order ID "#ORD-1024" (16px Bold #0F172A) next to Orange Badge Pill "ORDER BARU" (#FFF3E0 background, text #E65100 12px Bold).
     - Address Area (Large outdoor typography): Icon 'location_on' (#D32F2F) with large bold text "Jl. Merpati No. 45, RT 03/RW 08, Sukajadi, Kota Bandung" (15px Bold #0F172A, line-height 22px, margin top 8px).
     - Waste Summary: "Plastik PET & Kertas Kardus (~3.5 Kg Estimasi)" (14px Medium #4CAF50, margin top 6px).
     - Schedule Pill: Icon 'schedule' with text "Sesi Pagi (08.00 - 11.00 WIB)" (13px #64748B).
     - Primary Action Button inside card: Full-width Filled Button "TERIMA TUGAS INI" (#1E7D32 background, white text 15px Bold, height 48px, BorderRadius 8px, margin top 14px).
   - Pending Task Card 2: Similar high-contrast card showing "#ORD-1025" at "Jl. Ciumbuleuit No. 112, Bandung" with "+ Terima Tugas" button.

Visual Vibe: Industrial-strength, ultra-clear, action-oriented, efficient, and rugged.
```

---

### DRV-003 : Pickup Detail & Google Maps Navigation Screen
- **Nama Screen**: `Pickup Detail Screen (Rincian Alamat & Navigasi Rute)`
- **Role**: Armada Driver Penjemput
- **Tujuan Screen**: Menyajikan rincian lengkap alamat rumah warga, kotak kontak telepon/WA langsung, daftar item estimasi sampah, serta menyediakan tombol pengalihan navigasi rute ke **Google Maps (`url_launcher`)** dan transisi status ke `on_the_way` $\rightarrow$ Tiba di Lokasi.
- **Business Goal**: Memastikan armada sampai di depan rumah warga dengan rute tercepat dan akurat, tanpa risiko tersesat.
- **Referensi dari Screen Catalog**: `DRV-003` (*Existing Screen - High Priority*).
- **Komponen yang harus tampil**:
  - *AppBar* dengan judul *"Detail Penugasan #ORD-XXXX"* dan tombol Back Arrow.
  - **High-Contrast Customer Contact Box**: Nama Warga (`Kevin Khayiss`), Nomor Telepon, dan 2 tombol besar sejajar: **"Telepon Warga (`phone`)"** & **"WhatsApp Warga (`chat`)"**.
  - **Address Card & Google Maps Launcher**: Alamat domisili lengkap berserta tombol utama **"Buka Navigasi Google Maps (`map`)"** (mengalihkan ke `google.navigation:q=lat,long`).
  - *Waste Items Reference List*: Daftar item sampah Tahap 1 (`estimasi_berat_kg`) sebagai referensi persiapan kapasitas truk.
  - **Dynamic Operational Action Bar (Bottom Sticky CTA)**:
    - Jika status == `accepted`: Tombol Biru Besar **"Mulai Menuju Lokasi (`on_the_way`)"**.
    - Jika status == `on_the_way`: Tombol Hijau Besar **"Tiba di Lokasi (Mulai Penimbangan Lapangan)"** $\rightarrow$ membuka `DRV-004`.
- **Komponen yang tidak boleh tampil**:
  - Harga poin atau konversi rupiah warga.
- **Navigasi masuk**: `DashboardScreen (DRV-002 - Tab Tugas Saya)` saat kartu diklik.
- **Navigasi keluar**: `PickupVerificationScreen (DRV-004)` saat tombol *"Tiba di Lokasi"* diklik, atau Google Maps eksternal via `url_launcher`.
- **Data yang dibutuhkan**: Rincian `orders` + `order_items`, `warga.nama_lengkap`, `warga.no_telepon`, `warga.lat_long`.
- **State**:
  - `Loading`: *Shimmer skeleton* pada box kontak dan alamat (`height 220px`).
  - `Empty`: *Not applicable*.
  - `Error`: Peringatan *"Koordinat GPS warga tidak valid. Hubungi warga via telepon/WA untuk ancer-ancer lokasi."*
  - `Success`: Detail lengkap dan siap dipandu.
- **Business Rules**: Saat driver menekan **"Mulai Menuju Lokasi"**, API mengubah status ke `on_the_way` dan sistem mulai memancarkan koordinat GPS live driver untuk diakses oleh layar tracking warga (`WRG-007`).
- **Status yang digunakan**: Menangani transisi `accepted` $\rightarrow$ `on_the_way`.
- **CTA utama**: Tombol Biru **"Mulai Menuju Lokasi (`on_the_way`)"** / Tombol Hijau **"Tiba di Lokasi (`DRV-004`)"**.
- **CTA sekunder**: Tombol Outlined **"Buka Navigasi Google Maps"**.
- **Design Notes**: Kontak warga dan alamat harus diletakkan paling atas (*Top Priority View*) dengan ukuran font `Title Medium / Large`.
- **Accessibility**: Seluruh tombol telepon dan navigasi berukuran `height 52px` agar mudah ditekan di dalam kendaraan.
- **Animation**: Perubahan tombol status bottom bar dari biru (*Mulai Jalan*) ke hijau (*Tiba di Lokasi*) menggunakan `AnimatedSwitcher` `300ms`.
- **Responsive Rules**: Mengikuti Mobile Grid `< 600px`.

```prompt
[STITCH AI MASTER PROMPT - DRV-003: Pickup Detail & Google Maps Navigation]
Design a high-contrast, highly legible Material Design 3 Mobile Operational Detail screen for the driver app ("Halaman-Driver") of "Bank Sampah Bersinar".

Style & Theme Requirements:
- Pure White surface #FFFFFF, Deep Green #1E7D32, Navigation Blue #1565C0, High-contrast text #0F172A.
- Plus Jakarta Sans Typography, Material Symbols Outlined Icons 24px.
- Built for fast, clear outdoor reading inside a delivery vehicle.

Layout Anatomy:
1. Top App Bar (Height 56px, white background, elevation-1):
   - Left Back arrow ('arrow_back', #0F172A).
   - Title Large: "Detail Tugas #ORD-1024" (18px Bold #0F172A).
   - Right Status Badge Pill: "Armada Menuju Lokasi" (Blue #E3F2FD background, text #1565C0 12px Bold).
2. Scrollable Operational Body (Margin horizontal 16px, top 16px, bottom 100px):
   - Customer Contact Card (Top Priority, White card #FFFFFF, border 2px solid #1E7D32, BorderRadius 12px, padding 16px, elevation-1):
     - Left: Circular avatar of citizen next to "Kevin Khayiss (Nasabah)" (16px Bold #0F172A) and "+62 812-3456-7890" (14px #64748B).
     - Bottom Action Row (Margin top 14px, 2 equal buttons side-by-side with 10px gap): Button 1 Green WhatsApp ("Chat WA", icon 'chat', #E8F5E9 background, text #1E7D32 14px Bold, height 44px), Button 2 Blue Call ("Telepon", icon 'phone', #E1F5FE background, text #0288D1 14px Bold, height 44px).
   - Address & Navigation Card (Margin top 16px, White card, BorderRadius 12px, border 1.5px solid #CBD5E1, padding 16px):
     - Title: "Alamat Jemput Nasabah" (14px SemiBold #64748B).
     - Large Address Text: "Jl. Merpati No. 45, RT 03/RW 08, Sukajadi, Kota Bandung, Jawa Barat 40162" (16px Bold #0F172A, line-height 24px, margin top 6px).
     - Patokan: "Patokan: Depan gapura hijau sebelah minimarket." (13px Italic #D32F2F, margin top 6px).
     - Outlined Navigation CTA below: Full-width Outlined Button "BUKA NAVIGASI GOOGLE MAPS" (border 2px solid #1565C0, text #1565C0 15px Bold, icon 'explore', height 48px, BorderRadius 8px, margin top 14px).
   - Waste Items Reference List (Margin top 16px, White card, padding 14px):
     - Title: "Persiapan Muatan (Tahap 1 Estimasi)" (14px Bold #0F172A).
     - Bullet list: "- Plastik PET Bersih (~3.5 Kg)" and "- Kertas Kardus (~5.0 Kg)".
3. Fixed Bottom Action Container (Height 84px, white surface, elevation-3 shadow, padding horizontal 16px, vertical 14px):
   - Primary Operational Button: Full width "TIBA DI LOKASI (MULAI TIMBANG) ->" (#1E7D32 background, white text 16px Bold, height 56px, BorderRadius 8px operational shape).

Visual Vibe: Ultra-clear, directional, industrial-grade, highly legible, and rapid.
```

---

### DRV-004 : Pickup Verification Screen (Form Timbang Tahap 2 `berat_driver_kg`)
- **Nama Screen**: `Pickup Verification Screen (Form Penimbangan Lapangan Tahap 2)`
- **Role**: Armada Driver Penjemput
- **Tujuan Screen**: Memfasilitasi driver mencatat bukti fisik penimbangan awal lapangan (**Tahap 2 `berat_driver_kg`** per item), mengambil foto bukti tumpukan sampah yang diangkut ke bak truk, dan mengonfirmasi transisi status menjadi **`picked_up`**.
- **Business Goal**: Menyediakan bukti serah terima lapangan (*Field Auditability*) yang sah dan akurat, mencegah selisih paham antara warga dan driver mengenai kondisi muatan awal.
- **Referensi dari Screen Catalog**: `DRV-004` (*Need Revision Screen - Critical Priority*).
- **Komponen yang harus tampil**:
  - *AppBar* dengan judul *"Timbang Lapangan #ORD-XXXX"* dan tombol Back.
  - **High-Contrast Dynamic Weighing Form Table (Tahap 2)**:
    - Menampilkan setiap baris item sampah (misal: *Plastik PET Bersih*).
    - Menampilkan angka referensi warga (`estimasi_berat_kg` Tahap 1) di sebelah kiri sebagai sandingan.
    - **Kolom Input Angka Besar `berat_driver_kg` (Tahap 2)** di sebelah kanan: *Number TextFormField* berborder tebal `2px solid #1E7D32`, ukuran font `18px Bold` rata kanan, bersatu dengan label suffix `"Kg"`.
  - **Camera Photo Proof Shutter Box**: Kotak kontainer bergaya *Dashed Green Border (`#1E7D32` 2px)* yang memuat tombol buka kamera (*Camera Shutter*) untuk mengambil foto bukti muatan sampah di depan rumah warga. Pasca-foto diambil, kotak menampilkan *thumbnail preview* foto bersertakan tombol *Retake (`camera_alt`)*.
  - *Field Notes TextFormField*: Kolom catatan lapangan (misal: *"Kardus basah terkena hujan"*).
  - Tombol submit utama di dasar layar: **"Konfirmasi Angkut Sampah (`picked_up`)"**.
- **Komponen yang tidak boleh tampil**:
  - Kolom `berat_aktual_kg` (Tahap 3) atau kalkulasi poin saldo (karena Tahap 2 dilarang memutasi saldo).
- **Navigasi masuk**: `PickupDetailScreen (DRV-003)` saat tombol *"Tiba di Lokasi"* diklik.
- **Navigasi keluar**: `WarehouseHandoverScreen (DRV-005)` pasca-konfirmasi angkut berhasil.
- **Data yang dibutuhkan**: Daftar `order_items` dari pesanan terkait, izin akses kamera (`camera` package).
- **State**:
  - `Loading`: Spinner dalam tombol submit saat mengunggah foto bukti dan array `berat_driver_kg` ke `orders_api.php`.
  - `Empty`: Form dimulai dengan angka input `0.0` kg atau kosong siap diisi.
  - `Error`: **Dialog Alert Merah `#D32F2F`** jika tombol angkut ditekan namun ada kolom `berat_driver_kg` yang bernilai `0` kg atau kosong: *"Mohon masukkan hasil penimbangan lapangan (`berat_driver_kg`) untuk semua item sebelum muatan diangkut ke kendaraan."*
  - `Success`: Muncul dialog singkat berhasil dan beralih ke `DRV-005`.
- **Business Rules**: **ATURAN MUTLAK TAHAP 2**: Angka `berat_driver_kg` yang diinput di sini **BELUM DAN TIDAK BOLEH MEMUTASI SALDO POIN WARGA**. Angka ini hanya dicatat ke database sebagai bukti serah terima lapangan dan mengubah status order menjadi **`picked_up`**.
- **Status yang digunakan**: Mengubah status menjadi **`picked_up`**.
- **CTA utama**: Tombol *High-Contrast Primary Button* **"Konfirmasi Angkut Sampah (`picked_up`)"** (`height 56px`).
- **CTA sekunder**: Tombol *"Ambil Ulang Foto Bukti"*.
- **Design Notes**: Kolom input `berat_driver_kg` harus berukuran besar (`height 56px`, font `18px Bold`) agar mudah diketik di bawah sinar matahari lapangan. Gunakan *keyboard numeric* dengan tombol *Done*.
- **Accessibility**: Kontras rasio ultra-tinggi $\ge 7.0:1$.
- **Animation**: Kotak foto bukti menampilkan animasi geser naik halus saat foto berhasil dijepret (`200ms`).
- **Responsive Rules**: Mengikuti Mobile Grid `< 600px`.

```prompt
[STITCH AI MASTER PROMPT - DRV-004: Pickup Verification Screen (Timbang Tahap 2)]
Design a rugged, high-contrast, high-legibility Material Design 3 Mobile Field Weighing & Verification screen for the operational driver app ("Halaman-Driver") of "Bank Sampah Bersinar".

Style & Theme Requirements:
- Pure White surface #FFFFFF, High-contrast Forest Green #1E7D32, Dark Slate text #0F172A, and distinct borders.
- Plus Jakarta Sans Typography, Material Symbols Outlined Icons 24px.
- Built specifically for fast, accurate numeric entry outdoors in direct sunlight.

Layout Anatomy:
1. Top App Bar (Height 56px, white background, elevation-1):
   - Left Back arrow ('arrow_back', #0F172A).
   - Title Large: "Timbang Lapangan #ORD-1024" (18px Bold #0F172A).
2. Scrollable Verification Form Body (Margin horizontal 16px, top 16px, bottom 100px):
   - Section Header: "Input Penimbangan Lapangan (Tahap 2)" (16px Bold #0F172A).
   - Weighing Item Card 1 (Plastik PET): White card (#FFFFFF, BorderRadius 12px, border 2px solid #CBD5E1, padding 16px, elevation-1).
     - Top row: Item name "Plastik PET Bersih" (16px Bold #0F172A) next to reference pill "Estimasi Warga: ~3.5 Kg" (13px SemiBold #64748B).
     - Bottom Input Row (Margin top 12px, side-by-side layout): Label "Berat Driver (Actual Lapangan):" (14px Bold #0F172A, width 50%) next to a large High-Contrast Number TextField (height 56px, width 45%, border 2.5px solid #1E7D32, BorderRadius 8px, right-aligned large text "3.2" 18px Bold #0F172A with suffix "Kg" #1E7D32).
   - Weighing Item Card 2 (Kertas Kardus): Similar high-contrast card with Estimasi "~5.0 Kg" and input box showing "4.8" Kg.
   - Section 2: Foto Bukti Angkut Sampah (Margin top 20px, Header 15px Bold #0F172A).
     - Photo Proof Box: A prominent container with thick dashed green border (`2px dashed #1E7D32`, background #E8F5E9, BorderRadius 12px, padding 20px, text-align center). Features camera icon 'camera_alt' (36px #1E7D32), large text "Ambil Foto Bukti Sampah Diangkut" (15px Bold #1E7D32), and small text "Wajib menyertakan foto tumpukan sampah di depan rumah warga" (12px #64748B).
   - Section 3: Catatan Lapangan (Margin top 16px):
     - Outlined TextField with label "Catatan Tambahan (Opsional)" showing "Kardus sedikit basah terkena hujan." (14px Regular).
3. Fixed Bottom Action Container (Height 88px, white surface, elevation-3 shadow, padding horizontal 16px, vertical 14px):
   - Primary Operational CTA: Full width "KONFIRMASI ANGKUT SAMPAH (PICKED UP)" (#1E7D32 background, white text 16px Bold, height 56px, BorderRadius 8px operational shape).

Visual Vibe: Audited, industrial-strength, ultra-accurate, fool-proof, and rapid.
```

---

### DRV-005 : Warehouse Handover Screen (Serah Terima Gudang $\rightarrow$ `validating` - New Screen)
- **Nama Screen**: `Warehouse Handover Screen (Serah Terima Gudang Bank Sampah)`
- **Role**: Armada Driver Penjemput
- **Tujuan Screen**: Memvalidasi proses penurunan muatan fisik dari bak truk ke area gudang Bank Sampah, mencatat serah terima kepada petugas verifikator gudang, dan memicu perubahan status menjadi **`validating`**.
- **Business Goal**: Memastikan batas akhir tanggung jawab lapangan armada driver terdefinisi dengan tegas (*Clean Handover Boundary*), sehingga pesanan siap diinspeksi akhir oleh petugas Web Admin tanpa tumpang tindih otorisasi.
- **Referensi dari Screen Catalog**: `DRV-005` (*New Screen - Critical Priority*).
- **Komponen yang harus tampil**:
  - *AppBar* dengan judul *"Serah Terima Gudang #ORD-XXXX"*.
  - **Handover Summary Card**: Ringkasan total muatan yang dibawa di atas truk berdasarkan penimbangan lapangan Tahap 2 (`Total Berat Driver: 8.0 Kg` yang terdiri dari `Plastik PET 3.2 Kg` dan `Kardus 4.8 Kg`).
  - *Warehouse & Officer Info Box*: Nama Gudang Tujuan (`Gudang Pusat Bank Sampah Bersinar - Bandung`) dan kolom nama petugas penerima di gudang.
  - **Confirmation Checkbox Box (High-Contrast Touch Target)**: Kotak centang berukuran besar (`48px`) disertai pernyataan hukum: *"Saya menyatakan bahwa seluruh muatan sampah dari pesanan #ORD-XXXX telah diturunkan dan diserahkan secara utuh kepada petugas gudang Bank Sampah."*
  - Tombol submit utama di dasar layar: **"Serahkan Muatan ke Gudang (`validating`)"**.
- **Komponen yang tidak boleh tampil**:
  - Input `berat_aktual_kg` (Tahap 3) atau tombol penyaluran poin (karena Tahap 3 adalah hak eksklusif Web Admin di `ADM-004`).
- **Navigasi masuk**: `PickupVerificationScreen (DRV-004)` pasca konfirmasi angkut `picked_up`.
- **Navigasi keluar**: `DashboardScreen (DRV-002)` setelah serah terima berhasil (*Push Replacement / Clear Stack*).
- **Data yang dibutuhkan**: Ringkasan `order_items` dengan nilai `berat_driver_kg` yang baru saja diinput di Tahap 2.
- **State**:
  - `Loading`: Spinner circular dalam tombol submit saat API `orders_api.php` memproses status `validating`.
  - `Empty`: *Not applicable*.
  - `Error`: Peringatan jika *Checkbox Konfirmasi* belum dicentang oleh driver saat menekan tombol submit.
  - `Success`: Muncul **Dialog Sukses Serah Terima**: *"Muatan Berhasil Diserahkan! Tugas Anda untuk pesanan #ORD-XXXX telah tuntas."* $\rightarrow$ kembali ke Dasbor `DRV-002`.
- **Business Rules**: **ATURAN MUTLAK PELEPASAN TANGGUNG JAWAB**: Sesaat setelah driver menekan tombol *"Serahkan Muatan ke Gudang"*, API mengubah status menjadi **`validating`**. Pesanan tersebut **HILANG SEKETIKA dari daftar tugas aktif driver (`DRV-002`)** dan beralih sepenuhnya ke antrean penimbangan akhir petugas Web Admin (`ADM-003`). Driver tidak dapat lagi memodifikasi pesanan tersebut.
- **Status yang digunakan**: Mengubah status dari `picked_up` $\rightarrow$ **`validating`**.
- **CTA utama**: Tombol *Filled Primary Button* **"Serahkan Muatan ke Gudang (`validating`)"** (`#1E7D32`, `height 56px`).
- **CTA sekunder**: *Checkbox Konfirmasi Serah Terima Muatan*.
- **Design Notes**: Kotak konfirmasi serah terima diberi border ungu/hijau tebal agar menarik perhatian driver bahwa ini adalah langkah terakhir penugasan.
- **Accessibility**: Checkbox dan label pernyataan memiliki area klik bersama (*Combined Touch Target*) seluas `100% width card`.
- **Animation**: Tombol submit baru aktif (*Fade-in / Color transition*) setelah checkbox dicentang (`200ms`).
- **Responsive Rules**: Mengikuti Mobile Grid `< 600px`.

```prompt
[STITCH AI MASTER PROMPT - DRV-005: Warehouse Handover Screen (Serah Gudang)]
Design a definitive, highly professional Material Design 3 Mobile Warehouse Handover & Transfer screen for the operational driver app ("Halaman-Driver") of "Bank Sampah Bersinar".

Style & Theme Requirements:
- Pure White surface #FFFFFF, Forest Green #1E7D32, Indigo Accent #EDE7F6, Dark Slate #0F172A.
- Plus Jakarta Sans Typography, Material Symbols Outlined Icons 24px.
- Built specifically for clean operational handover at the warehouse reception area.

Layout Anatomy:
1. Top App Bar (Height 56px, white background, elevation-1):
   - Left Back arrow ('arrow_back', #0F172A).
   - Title Large: "Serah Terima Gudang #ORD-1024" (18px Bold #0F172A).
   - Right Badge Pill: "Muatan Siap Serah" (Indigo #EDE7F6 background, text #4527A0 12px Bold).
2. Scrollable Handover Body (Margin horizontal 16px, top 16px, bottom 100px):
   - Handover Summary Card (Top Priority, White card #FFFFFF, border 2px solid #1E7D32, BorderRadius 12px, padding 16px, elevation-1):
     - Title: "Ringkasan Muatan Lapangan (Tahap 2)" (15px Bold #0F172A).
     - Total Weight Display: Large highlighted pill "Total Berat Driver: 8.0 Kg" (#E8F5E9 background, text #1E7D32 16px Bold, padding 8px 14px, margin top 8px).
     - Item Breakdown: "- Plastik PET Bersih: 3.2 Kg" and "- Kertas Kardus: 4.8 Kg" (14px Medium #0F172A).
   - Warehouse & Officer Info Box (Margin top 16px, White card, BorderRadius 12px, border 1.5px solid #CBD5E1, padding 16px):
     - Icon 'warehouse' next to "Gudang Tujuan Serah Terima" (15px Bold #0F172A).
     - Address: "Gudang Pusat Bank Sampah Bersinar - Jl. Soekarno-Hatta No. 220, Bandung" (13px #64748B, margin top 4px).
     - Officer verification prompt: "Status: Menunggu penerimaan petugas verifikator gudang." (13px SemiBold #4527A0, margin top 8px).
   - Confirmation Checkbox Card (Margin top 20px, light green container #E8F5E9, border 2px solid #1E7D32, BorderRadius 12px, padding 16px):
     - A large, prominent M3 Checkbox checked in green (#1E7D32, 28px x 28px) placed right next to bold declaration text: "Saya menyatakan bahwa seluruh muatan sampah dari pesanan #ORD-1024 telah diturunkan dan diserahkan secara utuh kepada petugas gudang Bank Sampah." (14px Bold #0F172A, line-height 20px).
3. Fixed Bottom Action Container (Height 88px, white surface, elevation-3 shadow, padding horizontal 16px, vertical 14px):
   - Primary Handover CTA: Full width "SERAHKAN MUATAN KE GUDANG (VALIDATING)" (#1E7D32 background, white text 16px Bold, height 56px, BorderRadius 8px operational shape).

Visual Vibe: Definitive, industrial-grade, legally sound, clean, and authoritative.
```

---

### DRV-006 : Schedule & History Screen
- **Nama Screen**: `Schedule & History Screen (Jadwal & Riwayat Tugas Armada)`
- **Role**: Armada Driver Penjemput
- **Tujuan Screen**: Menyajikan jadwal penugasan jemputan mendatang (*Upcoming Schedule*) serta merekapitulasi seluruh riwayat pesanan yang telah selesai diangkut oleh armada (`validating` / `completed`).
- **Business Goal**: Memudahkan armada memonitor kinerja penjemputan harian/mingguan mereka dan merencanakan rute penugasan esok hari.
- **Referensi dari Screen Catalog**: `DRV-006` (*Existing Screen - Medium Priority*).
- **Komponen yang harus tampil**:
  - *AppBar* dengan judul *"Jadwal & Riwayat Tugas"*.
  - **Top Segmented Tabs**: Tab 1 **"Jadwal Mendatang (`schedule`)"** vs Tab 2 **"Riwayat Selesai (`history`)"**.
  - *Tab 1 ListView*: Kartu-kartu pesanan berstatus `accepted` untuk sesi besok/mendatang, dilengkapi tanggal, sesi waktu, dan alamat warga.
  - *Tab 2 ListView (History Read-Only)*:
    - Kartu-kartu tugas berstatus `validating` (sedang di gudang) dan `completed` (selesai tuntas).
    - Menampilkan Nomor Order, Tanggal Selesai, Alamat Warga, dan Total Berat Driver Tahap 2 (`Total: 8.0 Kg`).
    - Lencana Status Hijau/Ungu (`completed` / `validating`).
- **Komponen yang tidak boleh tampil**:
  - Rincian poin atau konversi rupiah warga (karena driver tidak perlu melihat penghasilan poin warga demi isolasi privasi).
- **Navigasi masuk**: Menu samping atau tab bar navigasi di `DRV-002`.
- **Navigasi keluar**: `PickupDetailScreen (DRV-003)` (dalam mode *Read-Only*) saat kartu riwayat diklik.
- **Data yang dibutuhkan**: Daftar `orders WHERE id_driver = X AND status IN ('validating','completed')`.
- **State**:
  - `Loading`: *Shimmer skeleton list* (`4 kartu kerangka`).
  - `Empty`: **Empty State Card** ilustrasi kalender bersih dengan pesan *"Belum ada jadwal penjemputan atau riwayat tugas selesai."*
  - `Error`: *Snackbar* kesalahan kueri jaringan.
  - `Success`: Daftar riwayat terurut akurat berdasarkan tanggal (*DESC*).
- **Business Rules**: Kartu pada Tab Riwayat Selesai bersifat *Read-Only* dan tidak dapat diubah lagi status maupun angkanya oleh driver.
- **Status yang digunakan**: Menampilkan `validating` dan `completed`.
- **CTA utama**: *Read-Only Clickable Card* untuk melihat jejak rute di `DRV-003`.
- **CTA sekunder**: Filter bulan/tanggal pada pojok kanan atas.
- **Design Notes**: Gunakan desain kartu bershadow lembut `elevation-1` berlatar `#FFFFFF`.
- **Accessibility**: Teks tanggal dan berat muatan berukuran `14px Bold`.
- **Animation**: Pergeseran antar tab menggunakan `TabBarView` `250ms`.
- **Responsive Rules**: Mengikuti Mobile Grid `< 600px`.

```prompt
[STITCH AI MASTER PROMPT - DRV-006: Schedule & History Screen Driver]
Design an organized, high-legibility Material Design 3 Mobile Schedule & Task History screen for the operational driver app ("Halaman-Driver") of "Bank Sampah Bersinar".

Style & Theme Requirements:
- Pure White surface #FFFFFF, Forest Green #1E7D32, Dark Slate #0F172A.
- Plus Jakarta Sans Typography, Material Symbols Outlined Icons 24px.
- Built for clean operational review inside the vehicle.

Layout Anatomy:
1. Top App Bar (Height 56px, white surface, elevation-1):
   - Center Title: "Jadwal & Riwayat Tugas" (18px Bold #0F172A).
   - Right icon button: 'calendar_month' (#1E7D32).
2. Segmented Top Tab Bar (Height 48px, white background, border bottom 1.5px solid #CBD5E1):
   - 2 Equal Tabs: Tab 1 "Jadwal Mendatang (1)" (inactive slate text #64748B), Tab 2 "Riwayat Selesai (14)" (ACTIVE with solid green bottom border 3px #1E7D32 and text 15px Bold #1E7D32).
3. Scrollable History ListView (Margin horizontal 16px, top 16px, bottom 24px, 14px gap between cards):
   - Completed History Card 1 (Status: completed): White card (#FFFFFF, BorderRadius 12px, border 1px solid #CBD5E1, padding 16px, elevation-1). Top row: Order ID "#ORD-1018" (15px Bold #0F172A) next to Green Badge Pill "Selesai (Completed)" (#E8F5E9 background, text #1B5E20 12px Bold, icon 'check_circle'). Middle row: Icon 'location_on' with address "Jl. Merpati No. 45, Bandung" (14px Bold #0F172A, margin top 6px). Bottom row: "Total Diangkut (Tahap 2): 8.0 Kg" (14px SemiBold #1E7D32) and timestamp "05 Jul 2026, 14:15 WIB" (12px #64748B).
   - Validating History Card 2 (Status: validating): White card with Purple Badge Pill "Sedang Divalidasi Gudang" (#EDE7F6 background, text #4527A0 12px Bold, icon 'verified'). Address "Jl. Ciumbuleuit No. 112, Bandung" with Total Diangkut "12.5 Kg".

Visual Vibe: Professional, rugged, highly readable, structured, and clear.
```

---

### DRV-007 : Alerts & Driver Profile Screen
- **Nama Screen**: `Alerts & Profile Screen (Profil Armada & Spesifikasi Truk)`
- **Role**: Armada Driver Penjemput
- **Tujuan Screen**: Menampilkan daftar notifikasi penugasan baru dari admin serta menyajikan spesifikasi kendaraan armada yang sedang digunakan (Plat Nomor Truk, Kapasitas Muatan KG, Tipe Bak), berserta tombol *Logout* dari sesi armada.
- **Business Goal**: Memastikan setiap armada terdaftar dengan nomor kendaraan yang sesuai demi aspek keselamatan jalan (*Vehicle Safety Compliance*) dan ketepatan identifikasi oleh warga.
- **Referensi dari Screen Catalog**: `DRV-007` (*Existing Screen - Low Priority*).
- **Komponen yang harus tampil**:
  - *AppBar* dengan judul *"Profil Armada & Truk"*.
  - **Header Driver Operational Profile**: Foto Driver, Nama Petugas (`Budi Santoso`), ID Armada (`DRV-0012`), dan status aktif.
  - **Vehicle Specification Card (High-Contrast Border)**:
    - Plat Nomor Kendaraan (`D 8821 XA` - Font *Display Medium* dalam bingkai hitam kuning ala plat nomor).
    - Tipe Kendaraan (`Truk Bak Terbuka / Engkel`).
    - Kapasitas Maksimal Muatan (`Maksimal 800 Kg / Hari`).
  - *Operational Menu List*:
    - Menu 1: *"Riwayat Pemeliharaan & Cek Kendaraan (`build`)"*.
    - Menu 2: *"Bantuan darurat & Kendala Kendaraan (`warning`)"*.
  - **Logout Action Button**: Tombol Outlined Merah `#D32F2F` di dasar halaman dengan label **"Keluar dari Sesi Armada (Logout)"**.
- **Komponen yang tidak boleh tampil**:
  - Pengaturan saldo poin warga atau menu master data jenis sampah.
- **Navigasi masuk**: Menu samping di `DRV-002`.
- **Navigasi keluar**: `DriverLoginScreen (DRV-001)` pasca-logout berhasil.
- **Data yang dibutuhkan**: Tabel `driver WHERE id_driver = X` (spesifikasi truk dan plat nomor).
- **State**:
  - `Loading`: *Shimmer skeleton* pada spesifikasi kendaraan.
  - `Empty`: *Not applicable*.
  - `Error`: *Snackbar Error* jika gagal memuat spesifikasi truk.
  - `Success`: Data spesifikasi truk dimuat jelas dan akurat.
- **Business Rules**: Saat *Logout* dikonfirmasi, seluruh sesi driver di `SharedPreferences` dihapus dan status ketersediaan armada di database otomatis diubah menjadi `Offline`.
- **Status yang digunakan**: *None*.
- **CTA utama**: Tombol Outlined Merah **"Keluar dari Sesi Armada (Logout)"** (`#D32F2F`, `height 52px`).
- **CTA sekunder**: Tombol *"Laporkan Kendala Kendaraan"*.
- **Design Notes**: Bingkai plat nomor dibuat menonjol dengan latar hitam/putih kontras tinggi khas kendaraan operasional.
- **Accessibility**: Tombol logout merah mudah dijangkau namun memerlukan konfirmasi dialog.
- **Animation**: Dialog konfirmasi logout `200ms`.
- **Responsive Rules**: Mengikuti Mobile Grid `< 600px`.

```prompt
[STITCH AI MASTER PROMPT - DRV-007: Alerts & Driver Profile Screen]
Design a rugged, industrial-grade Material Design 3 Mobile Profile & Vehicle Specification screen for the operational driver app ("Halaman-Driver") of "Bank Sampah Bersinar".

Style & Theme Requirements:
- Pure White surface #FFFFFF, High-contrast Forest Green #1E7D32, Industrial Slate #0F172A, Danger Red #D32F2F.
- Plus Jakarta Sans Typography, Material Symbols Outlined Icons 24px.
- Built specifically for clean vehicle identification and operational profile management.

Layout Anatomy:
1. Top App Bar (Height 56px, white background, elevation-1):
   - Center Title: "Profil Armada & Kendaraan" (18px Bold #0F172A).
2. Header Driver Profile Section (Margin top 16px, horizontal 16px, light green container #E8F5E9, BorderRadius 12px, padding 16px, border 1.5px solid #1E7D32):
   - Left: Driver photo (`64px x 64px`, border 2px solid #1E7D32).
   - Right Column: "Budi Santoso" (18px Bold #0F172A), "ID Armada: DRV-0012" (13px SemiBold #1E7D32), and status pill "Status: ONLINE / SIAP JEMPUT" (green pill, white text 11px Bold).
3. Vehicle Specification Card (Top Priority, Margin top 16px, horizontal 16px, White card #FFFFFF, BorderRadius 12px, border 2px solid #0F172A, padding 16px, elevation-1):
   - Title: "Spesifikasi Kendaraan Operasional" (15px Bold #0F172A).
   - License Plate Display Box (Margin top 12px, black border container `#0F172A`, background #FFFFFF, padding 12px, text-align center, BorderRadius 8px):
     - License Plate Text: "D 8821 XA" (24px Bold #0F172A, letter-spacing 3px, industrial typography).
   - Specs Grid (Margin top 12px):
     - "Tipe Kendaraan: Truk Bak Terbuka / Engkel" (14px Medium #0F172A).
     - "Kapasitas Angkut: Maksimal 800 Kg / Hari" (14px Medium #1E7D32 Bold).
4. Operational Menu ListView (Margin top 16px, horizontal 16px, white container, BorderRadius 12px, border 1px solid #CBD5E1):
   - Menu 1: Icon 'build' (#1E7D32), Title "Riwayat Cek & Pemeliharaan Kendaraan", Right chevron. Divider below.
   - Menu 2: Icon 'warning' (#D32F2F), Title "Laporkan Kendala / Darurat Kendaraan", Right chevron.
5. Logout Action Button (Margin horizontal 16px, top 24px, bottom 32px):
   - Full-width Outlined Danger Button: Border 2px solid #D32F2F, white background, red text "KELUAR DARI SESI ARMADA (LOGOUT)" (15px Bold, height 52px, BorderRadius 8px operational shape, icon 'logout' in red).

Visual Vibe: Rugged, official, industrial-strength, highly structured, and clear.
```

---

## 3. KATALOG PROMPT PORTAL WEB ADMIN (`ADM-001` – `ADM-007`)

---

### ADM-001 : Admin Authentication Gate
- **Nama Screen**: `Admin Login Page (auth/login.php)`
- **Role**: Web Admin & Petugas Gudang Bank Sampah
- **Tujuan Screen**: Mengotentikasi kredensial petugas dan pengelola sistem sebelum memberikan akses ke dasbor eksekutif dan manajemen pesanan.
- **Business Goal**: Menjamin keamanan akses level *Enterprise Admin (`level IN ('admin','petugas')`)* agar tidak terjadi pelanggaran data atau manipulasi transaksi penimbangan akhir di gudang.
- **Referensi dari Screen Catalog**: `ADM-001` (*Existing Module - High Priority*).
- **Komponen yang harus tampil**:
  - *Centered Login Card (`Bootstrap 5 Card elevation-3`)* di tengah layar peramban web desktop.
  - Emblem logo resmi Bank Sampah Bersinar dan judul **"Portal Manajemen Web Admin"**.
  - Form Input Username / Email (dengan ikon `person`).
  - Form Input Password (dengan ikon `lock` dan toggle `visibility`).
  - Checkbox *"Ingat sesi saya di browser ini (Remember Me)"*.
  - Tombol *Filled Primary Green Button* **"Masuk ke Portal Admin"** (`height 48px`).
  - Footer copyright legalitas Tugas Akhir (*"© 2026 Bank Sampah Bersinar - Tugas Akhir Kevin Khayiss"*).
- **Komponen yang tidak boleh tampil**:
  - *Sidebar* atau *Navbar* dasbor (karena belum login).
- **Navigasi masuk**: URL `index.php` saat sesi `$_SESSION['user']` tidak ditemukan (*Router Check*).
- **Navigasi keluar**: `ExecutiveDashboard (index.php?page=dashboard - ADM-002)` saat otentikasi sukses.
- **Data yang dibutuhkan**: Kredensial POST `username` & `password` ke controller `auth/process_login.php`.
- **State**:
  - `Loading`: Spinner circular di dalam tombol utama saat memvalidasi kueri MySQL.
  - `Empty`: Form kosong siap diisi.
  - `Error`: **Bootstrap Alert Red (`alert-danger`)** melayang di atas form: *"Kredensial tidak valid atau akun Anda tidak memiliki hak akses sebagai Admin/Petugas."*
  - `Success`: Pengalihan HTTP langsung ke dasbor `ADM-002`.
- **Business Rules**: Akun warga biasa atau driver dilarang login ke portal web admin.
- **Status yang digunakan**: *None*.
- **CTA utama**: Tombol **"Masuk ke Portal Admin"** (`#1E7D32`, `radiusSM 8px`).
- **CTA sekunder**: Link *"Bantuan Akses Petugas Gudang"*.
- **Design Notes**: Latar belakang halaman peramban menggunakan gradasi halus `#F1F5F9` $\rightarrow$ `#E2E8F0` dengan kartu login putih `#FFFFFF` berlebar `44px` di tepat tengah layar (*Vertical & Horizontal Centered*).
- **Accessibility**: Dukungan penuh navigasi keyboard (`Tab` & `Enter`).
- **Animation**: *Fade-in card* `300ms`.
- **Responsive Rules**: Web Grid `> 1024px`. Pada layar ponsel/tablet kecil, kartu login menyesuaikan lebar menjadi `92% width`.

```prompt
[STITCH AI MASTER PROMPT - ADM-001: Admin Authentication Gate]
Design a sleek, high-end, professional Enterprise Web Admin Login Page (`auth/login.php`) for the back-office management portal of "Bank Sampah Bersinar".

Style & Theme Requirements:
- Desktop Web responsive layout (`1920x1080` viewport representation).
- Subtle slate gradient background (#F8FAFC to #E2E8F0) with a pristine white centered login card (#FFFFFF).
- Color Palette: Emerald Green #1E7D32, Dark Slate #0F172A, Border Slate #CBD5E1.
- Plus Jakarta Sans Typography, Material Symbols Outlined Icons 24px.
- Clean 8pt grid with Bootstrap 5 card elevation styling.

Layout Anatomy:
1. Centered Web Login Card (Width 460px, vertically and horizontally centered in viewport, white background #FFFFFF, BorderRadius 16px, elevation-3 shadow `0px 12px 24px rgba(15,23,42,0.12)`, padding 40px):
   - Top Header: A crisp green vector emblem (`64px x 64px`, #E8F5E9 circle with green recycling icon 'recycling' #1E7D32).
   - Headline Large: "Portal Web Admin & Gudang" (24px Bold #0F172A, margin top 16px, centered).
   - Subtitle: "Sistem Informasi Manajemen Bank Sampah Bersinar" (14px Regular #64748B, margin top 4px, centered).
   - Form Fields Container (Margin top 32px):
     - Username Field: Bootstrap 5 style Outlined Input (height 48px, BorderRadius 8px, border 1.5px solid #CBD5E1, padding horizontal 14px). Prefix icon 'person' (#1E7D32), floating label "Username / Email Petugas" (#0F172A Bold).
     - Password Field (Margin top 16px): Outlined Input with prefix icon 'lock', masked dots (••••••••), and right toggle 'visibility_off'.
     - Remember Me Checkbox Row (Margin top 16px): Checkbox checked in green next to text "Ingat sesi saya di browser ini" (13px #64748B).
   - Primary Submit Button (Margin top 24px): Full-width Filled Green Button (#1E7D32 background, white text "Masuk ke Portal Admin ->", 16px SemiBold, height 48px, BorderRadius 8px, elevation-1).
2. Bottom Copyright Footer (Absolute bottom centered outside card, margin bottom 24px):
   - Text: "© 2026 Bank Sampah Bersinar — Tugas Akhir Kevin Khayiss. All rights reserved." (13px Regular #64748B).

Visual Vibe: Executive, secure, pristine, modern, enterprise-grade, and trustworthy.
```

---

### ADM-002 : Executive Dashboard & Statistics Command Center
- **Nama Screen**: `Executive Dashboard (index.php?page=dashboard)`
- **Role**: Web Admin & Petugas Gudang Bank Sampah
- **Tujuan Screen**: Menyajikan ikhtisar kinerja operasional secara *real-time* melalui 4 kotak statistik utama (*Stat Cards*), grafik tren penjemputan bulanan (*Chart.js / ApexCharts*), serta tabel ringkas 5 pesanan terbaru yang siap diproses.
- **Business Goal**: Memberikan keterlihatan penuh (*Executive Visibility*) kepada pimpinan maupun petugas mengenai laju pengumpulan sampah dan penyaluran reward poin harian.
- **Referensi dari Screen Catalog**: `ADM-002` (*Existing Module - Medium Priority*).
- **Komponen yang harus tampil**:
  - **Fixed Left Sidebar Navigation (`width 260px`, latar `#0F172A` Dark Slate)** dengan menu: `Dasbor (aktif)`, `Data Penjemputan (`orders/data`)`, `Katalog Jenis Sampah`, `Data Warga & Driver`, `Edukasi & Laporan`, `Logout`.
  - **Top Navbar Bar (`height 64px`, latar `#FFFFFF`)** dengan judul *"Dasbor Eksekutif"*, *Breadcrumb*, ikon lonceng, dan Profil Admin (`Admin Gudang Pusat`).
  - **4 Stat Cards Row (Grid 4 Kolom `col-md-3`)**:
    - Card 1: **Total Nasabah Warga** (`1,240 Warga` - ikon `people` Biru).
    - Card 2: **Total Armada Driver** (`18 Armada` - ikon `local_shipping` Orange).
    - Card 3: **Order Jemputan Aktif** (`14 Pesanan` - ikon `schedule` Kuning).
    - Card 4: **Total Poin Sah Disalurkan** (`450.000 Poin` - ikon `monetization_on` Hijau Tajam `#1E7D32`).
  - *Monthly Trend Chart Card (`Chart.js Canvas`)*: Grafik batang/garis yang menunjukkan peningkatan volume sampah (KG) dan poin selama 6 bulan terakhir.
  - *Recent Orders Table Section*: Tabel ringkas 5 pesanan terbaru berstatus `pending` atau `validating` dengan tombol cepat *"Lihat Tabel Lengkap (`ADM-003`) ->"*.
- **Komponen yang tidak boleh tampil**:
  - Form timbang driver lapangan (Tahap 2) atau tampilan mobile warga.
- **Navigasi masuk**: `ADM-001 (Login)` atau klik menu Dasbor di Sidebar.
- **Navigasi keluar**: `Orders Management Table (ADM-003)` saat klik *Lihat Semua Jemputan*.
- **Data yang dibutuhkan**: Kueri agregasi SQL `SELECT COUNT(*) FROM...` untuk warga, driver, order aktif, dan total `pengguna.saldo`.
- **State**:
  - `Loading`: *Shimmer placeholder* pada 4 Stat Cards dan area grafik Chart.js.
  - `Empty`: Stat Cards menunjukkan angka `0`. Grafik kosong dengan keterangan *"Belum ada transaksi bulan ini"*.
  - `Error`: *Bootstrap Alert Red* jika kueri agregasi database mengalami gangguan.
  - `Success`: Dasbor dimuat lengkap dan interaktif.
- **Business Rules**: Angka pada Stat Card **"Total Poin Sah Disalurkan"** wajib bersumber murni dari akumulasi `orders.poin_final` pada pesanan berstatus `completed`.
- **Status yang digunakan**: Menyoroti order aktif (`pending` hingga `validating`).
- **CTA utama**: Link *"Lihat Semua Jemputan (`ADM-003`)"*.
- **CTA sekunder**: Filter periode grafik (Bulan Ini vs Tahun Ini).
- **Design Notes**: Sidebar kiri berlatar `#0F172A` (Dark) memberikan kontras eksekutif yang tegas dengan area konten utama berlatar `#F8FAFC` (Light).
- **Accessibility**: Tabel ringkas mendukung navigasi keyboard dan *screen reader*.
- **Animation**: Grafik Chart.js merender batang dengan animasi naik halus (`800ms`).
- **Responsive Rules**: Web Grid `> 1024px`. Pada layar `< 1024px`, 4 Stat Cards beralih menjadi 2 kolom (`col-sm-6`).

```prompt
[STITCH AI MASTER PROMPT - ADM-002: Executive Dashboard Web Admin]
Design an expansive, high-end Material Design 3 / Bootstrap 5 Enterprise Web Executive Dashboard (`index.php?page=dashboard`) for the back-office management portal of "Bank Sampah Bersinar".

Style & Theme Requirements:
- Desktop Web layout (`1920x1080` viewport representation) with 12-column grid.
- Fixed Left Sidebar (#0F172A Dark Slate), Top Navbar (#FFFFFF), and Fluid Content Area (#F8FAFC).
- Color Palette: Emerald Green #1E7D32, Success #2E7D32, Info Blue #0288D1, Warning Orange #ED6C02.
- Plus Jakarta Sans Typography, Material Symbols Outlined Icons 24px.

Layout Anatomy:
1. Fixed Left Sidebar (`width 260px`, height 100vh, background #0F172A, padding 20px):
   - Top Brand Header: Emblem icon 'recycling' (#4CAF50) with text "Bank Sampah Bersinar" (18px Bold #FFFFFF).
   - Navigation Links (Vertical list, margin top 32px):
     - Menu 1: "Dasbor Eksekutif" (ACTIVE state: background #1E293B, left border 4px #1E7D32, text #FFFFFF Bold, icon 'dashboard' #4CAF50).
     - Menu 2: "Data Penjemputan" (icon 'local_shipping', slate text #94A3B8).
     - Menu 3: "Katalog Jenis Sampah" (icon 'delete_outline', slate text).
     - Menu 4: "Data Warga & Driver" (icon 'people', slate text).
     - Menu 5: "Edukasi & Laporan" (icon 'assessment', slate text).
   - Bottom Profile & Logout (Bottom absolute): "Admin Gudang Pusat" with red link "Keluar (Logout)".
2. Top Navbar (`height 64px`, white background #FFFFFF, border bottom 1px solid #E2E8F0, padding horizontal 28px):
   - Left: Breadcrumb "Beranda / Dasbor Eksekutif" (14px #64748B).
   - Right: Notification bell icon with dot, next to admin profile badge ("Kevin Khayiss - Head Verifier").
3. Main Fluid Content Area (Margin left 260px, padding 28px):
   - 4 Stat Cards Row (Grid 4 columns `col-md-3`, 20px gap):
     - Card 1 (Total Warga): White card (#FFFFFF, BorderRadius 12px, padding 20px, elevation-1 border 1px solid #E2E8F0). Top: label "Total Nasabah Warga" (13px #64748B) and blue icon 'people' (#0288D1). Large number: "1.240 Warga" (26px Bold #0F172A).
     - Card 2 (Total Driver): White card showing "18 Armada Driver" with orange icon 'local_shipping' (#ED6C02).
     - Card 3 (Order Aktif): White card showing "14 Pesanan Berjalan" with yellow icon 'schedule'.
     - Card 4 (Total Poin Sah): Green highlight card (#E8F5E9 background, border 1.5px solid #1E7D32). Label "Total Poin Sah Disalurkan" (#1E7D32 Bold), Large number "450.000 Poin" (26px Bold #1E7D32), icon 'monetization_on'.
   - Middle Chart & Recent Orders Split Section (Grid 2 columns: 7 col Chart, 5 col Table):
     - Left Chart Card: White card showing "Grafik Tren Penjemputan & Poin Bulanan (6 Bulan Terakhir)" (16px Bold #0F172A) with a clean green/blue bar chart (`Chart.js` rendering).
     - Right Recent Table Card: White card showing "5 Jemputan Terbaru Siap Validasi" with a compact table displaying "#ORD-1024", "Kevin Khayiss", and status badge "Sedang Divalidasi" (#EDE7F6 purple pill). Top right button "Lihat Semua ->" (#1E7D32).

Visual Vibe: Executive, highly data-dense, pristine, comprehensive, and powerful.
```

---

### ADM-003 : Orders Management Table (`orders/data` with 6-Status Filter Tabs)
- **Nama Screen**: `Orders Management Table (orders/data)`
- **Role**: Web Admin & Petugas Gudang Bank Sampah
- **Tujuan Screen**: Menjadi pusat kendali operasional penjemputan (*Central Dispatch & Verification Table*) yang menampung seluruh transaksi dalam tabel interaktif (*DataTables jQuery*), dikelompokkan oleh **6 Tab Filter Status Berurutan** (`pending`, `accepted`, `on_the_way`, `picked_up`, `validating`, `completed`).
- **Business Goal**: Memungkinkan petugas melakukan penugasan armada secara manual (*Manual Driver Assignment*) untuk order `pending`, serta membuka gerbang eksekusi **Validasi Timbang Akhir Gudang (`ADM-004`)** untuk order berstatus `validating`.
- **Referensi dari Screen Catalog**: `ADM-003` (*Need Revision Module - Critical Priority*).
- **Komponen yang harus tampil**:
  - **Top Status Filter Tabs Bar (6 Status + Semua)**: `Semua (28)`, `Menunggu Driver/pending (3)`, `Driver Ditugaskan/accepted (4)`, `Armada Menuju Lokasi/on_the_way (2)`, `Sampah Diangkut/picked_up (3)`, `Validasi Gudang/validating (2 - Highlight Ungu/Hijau)`, `Selesai/completed (14)`.
  - *Search & Filter Bar*: Kotak pencarian ID Order (`#ORD-XXXX`) atau Nama Warga, dan filter rentang tanggal.
  - **High-Density DataTables Grid**:
    - Kolom 1: ID Order (`#ORD-XXXX`) & Waktu (`10 Jul 2026`).
    - Kolom 2: Nama Warga & Alamat Jemput.
    - Kolom 3: Nama & Plat Armada Driver (`Budi Santoso - D 8821 XA` / atau *Dropdown Assign Driver* jika `pending`).
    - Kolom 4: Rincian Muatan Singkat (`Plastik PET 3.5 Kg...`).
    - Kolom 5: **Status Badge Pill** warna-warni sesuai Bab 13.
    - Kolom 6: **Tombol Aksi Bersyarat (*Conditional Action CTA*)**:
      - Jika status == `pending`: Dropdown pilih driver & tombol *"Assign Driver (`accepted`)"*.
      - Jika status == `validating` (atau `picked_up`): **Tombol Hijau Tajam Bersinar "Validasi Timbang Akhir (`ADM-004`)"**.
      - Jika status == `completed` / `cancelled`: Tombol *Text* *"Lihat Detail Read-Only"*.
- **Komponen yang tidak boleh tampil**:
  - Tombol validasi akhir pada baris berstatus `pending`, `accepted`, atau `on_the_way` (karena barang belum tiba di gudang).
- **Navigasi masuk**: Sidebar menu *"Data Penjemputan"* atau link dasbor `ADM-002`.
- **Navigasi keluar**: **Warehouse Final Weighing Modal (`verify_modal.php - ADM-004`)** saat tombol hijau *Validasi Timbang Akhir* diklik.
- **Data yang dibutuhkan**: Kueri SQL `SELECT * FROM orders JOIN pengguna JOIN driver...` dari `orders/data.php`.
- **State**:
  - `Loading`: *DataTables Shimmer Skeleton Table (`6 baris kerangka abu-abu`)*.
  - `Empty`: Baris kosong bertuliskan *"Tidak ada data penjemputan untuk tab status ini."*
  - `Error`: *Bootstrap Alert Red* jika koneksi database terputus.
  - `Success`: Tabel dimuat lengkap dengan fitur pagination (`10/25/50 baris per halaman`).
- **Business Rules**: **ATURAN MUTLAK TOMBOL VALIDASI**: Tombol hijau **"Validasi Timbang Akhir (`verify_modal.php`)"** hanya boleh diaktifkan/dimunculkan pada baris pesanan yang telah berstatus `validating` (atau `picked_up`).
- **Status yang digunakan**: Menangani seluruh 6 status order berurutan (`pending` hingga `completed`).
- **CTA utama**: Tombol Hijau Tajam **"Validasi Timbang Akhir (`ADM-004`)"** (Khusus `validating`).
- **CTA sekunder**: Tombol *Dropdown Assign Driver* (Khusus `pending`).
- **Design Notes**: Tabel dibungkus dalam kontainer putih berborder `1px solid #CBD5E1` dengan *hover effect* (`#F8FAFC`) pada baris tabel saat kursor melintas.
- **Accessibility**: Tabel mendukung *DataTables Screen Reader ARIA labels* dan *sticky table header*.
- **Animation**: Transisi antar tab filter memuat ulang tabel secara *smooth fade* `200ms`.
- **Responsive Rules**: Web Grid `> 1024px`. Tabel dibungkus `div.table-responsive` dengan *horizontal scrollbar* otomatis.

```prompt
[STITCH AI MASTER PROMPT - ADM-003: Orders Management Table Web Admin]
Design an authoritative, data-dense, highly functional Material Design 3 / Bootstrap 5 Enterprise Web Orders Management Table (`orders/data.php`) for the back-office portal of "Bank Sampah Bersinar".

Style & Theme Requirements:
- Desktop Web 12-column layout (`1920x1080` representation) with Fixed Left Sidebar (#0F172A) and main content area (#F8FAFC).
- Color Palette: Emerald Green #1E7D32, Indigo Accent #EDE7F6, Dark Slate text #0F172A, crisp border #CBD5E1.
- Plus Jakarta Sans Typography, Material Symbols Outlined Icons 24px.

Layout Anatomy:
1. Top Page Header (Margin bottom 20px):
   - Left: Headline Large "Manajemen Data Penjemputan" (24px Bold #0F172A) with subtitle "Pantau dan validasi seluruh antrean penjemputan sampah" (14px #64748B).
   - Right: Search box input (width 280px, placeholder "Cari ID Order / Nama Warga...", prefix icon 'search') next to "Export Excel" button.
2. 6-Status Filter Tabs Bar (Height 52px, white surface #FFFFFF, border 1.5px solid #CBD5E1, BorderRadius 10px, padding horizontal 16px, margin bottom 20px):
   - Horizontal pill tabs: Tab 1 "Semua (28)" (inactive), Tab 2 "Menunggu Driver / pending (3)" (Orange text), Tab 3 "Driver Ditugaskan / accepted (4)", Tab 4 "Menuju Lokasi / on_the_way (2)", Tab 5 "Diangkut / picked_up (3)", Tab 6 "Validasi Gudang / validating (2)" (ACTIVE STATE: solid green/indigo background #EDE7F6, text #4527A0 14px Bold, border 2px solid #512DA8), Tab 7 "Selesai / completed (14)".
3. Main DataTables Grid Container (White card #FFFFFF, BorderRadius 12px, border 1.5px solid #CBD5E1, elevation-1 shadow, overflow hidden):
   - Sticky Table Header (`thead`, background #F1F5F9, border bottom 2px solid #CBD5E1, text 13px Bold #0F172A):
     - Columns: `ID & WAKTU` | `NASABAH WARGA` | `ARMADA DRIVER` | `MUATAN (ESTIMASI vs DRIVER)` | `STATUS` | `AKSI PETUGAS GUDANG`.
   - Table Body Rows (`tbody`, 14px text #0F172A):
     - Row 1 (Status: validating - READY FOR FINAL WEIGHING):
       - Col 1: "#ORD-1024" (Bold #0F172A) & "10 Jul 2026, 09:30".
       - Col 2: "Kevin Khayiss" & "Jl. Merpati No. 45, Bandung".
       - Col 3: "Driver Budi Santoso (D 8821 XA)".
       - Col 4: "Plastik PET & Kardus (Est: 8.5 Kg | Driver: 8.0 Kg)".
       - Col 5: Purple Badge Pill "Validasi Gudang" (#EDE7F6 background, text #4527A0 12px Bold, icon 'verified').
       - Col 6 (PRIMARY ACTION): Glowing Green Filled Button "VALIDASI TIMBANG AKHIR ->" (#1E7D32 background, white text 13px Bold, height 38px, BorderRadius 6px, box-shadow `0px 4px 8px rgba(30,125,50,0.25)`).
     - Row 2 (Status: pending - NEED DRIVER ASSIGNMENT):
       - Col 1: "#ORD-1026" | Col 2: "Siti Aminah" | Col 3: Outlined Dropdown "Pilih Armada Driver..." next to mini green button "Assign".
       - Col 5: Orange Pill "Menunggu Driver" | Col 6: Text button "Lihat Detail".
     - Row 3 (Status: completed):
       - Col 1: "#ORD-1018" | Col 5: Green Pill "Selesai (Poin Sah)" | Col 6: Green text "Reward Sah: +14.500 Poin" (Bold #2E7D32).

Visual Vibe: High-capacity, authoritative, meticulously organized, transparent, and actionable.
```

---

### ADM-004 : Warehouse Final Weighing Modal (`verify_modal.php` & Atomic ACID Execution)
- **Nama Screen**: `Warehouse Final Weighing Modal (orders/verify_modal.php)`
- **Role**: Petugas Gudang Bank Sampah & Web Admin
- **Tujuan Screen**: Menyajikan **Modal Timbang Akhir Gudang (*Large Bootstrap Modal*)** yang memuat **Tabel Audit Sanding 3 Kolom (`Estimasi Warga` vs `Timbang Driver` vs `Input Aktual Gudang Tahap 3`)**, menghitung total Poin Sah secara *real-time* via JavaScript, dan mengeksekusi **Transaksi Atomic Database MySQL (`mysqli_begin_transaction` / `COMMIT` / `ROLLBACK`)** untuk menyuntikkan saldo poin sah ke akun warga dan mengunci status ke **`completed`**.
- **Business Goal**: Menjadi **Satu-Satunya Acuan Mutlak Poin Sah (*Single Source of Truth for Reward & Final Authority*)** yang menjamin akurasi 100% tanpa risiko cacat data atau penggandaan poin.
- **Referensi dari Screen Catalog**: `ADM-004` (*New Critical Module - Top Priority*).
- **Komponen yang harus tampil**:
  - *Large Bootstrap Modal (`modal-lg width 860px`, latar `#FFFFFF`, shadow `elevation-4`)* melayang di tengah layar web admin dengan latar belakang tabel `ADM-003` memudar gelap (`Overlay Dimming 60%`).
  - *Modal Header*: Judul **"Validasi Timbang Akhir Gudang — #ORD-XXXX"**, Lencana Status Ungu `validating`, dan tombol tutup `[X]`.
  - *Officer & Customer Audit Box*: Nama Warga (`Kevin Khayiss`), Nama Driver Pengangkut (`Budi Santoso - D 8821 XA`), dan Nama Petugas Verifikator (`Admin Gudang Pusat`).
  - **Tabel Audit Sanding 3 Kolom Penimbangan Muatan (*Side-by-Side Comparison Table*)**:
    - Kolom 1: Nama Item Sampah & Harga Poin/KG (`Plastik PET Bersih - Rp 2.500/Kg`).
    - Kolom 2: **Estimasi Warga (`estimasi_berat_kg` Tahap 1)** (`3.5 Kg`).
    - Kolom 3: **Timbang Driver (`berat_driver_kg` Tahap 2)** (`3.2 Kg`).
    - Kolom 4: **Input Berat Aktual Gudang (`berat_aktual_kg` Tahap 3) — ACUAN MUTLAK**: *Number Input Box* berborder hijau zamrud tebal `2px solid #1E7D32`, ukuran font `16px Bold` rata kanan, bersatu dengan satuan `"Kg"`.
  - **JS Real-Time Points Calculator Display Box**: Kotak ringkasan hijau bersinar (`#E8F5E9`, border `2px solid #1E7D32`) di bawah tabel yang memuat:
    - Total Berat Aktual Gudang (`Total Tahap 3: 7.6 Kg`).
    - **Total Reward Poin Sah (`poin_final = berat_aktual_kg * harga_poin`)**: Angka *Display Large* **`14.500 Poin`** (`#1E7D32 Bold`) yang diperbarui seketika oleh JavaScript saat angka di kotak input Tahap 3 diketik.
  - *Officer Inspection Notes Box*: *Textarea* catatan resmi petugas gudang (misal: *"Kardus dipotong 0.3 Kg karena basah terkena air hujan"*).
  - *Modal Footer & Primary ACID Action CTA*: Tombol **"Selesaikan Order & Salurkan Poin (`completed`)"** dan tombol batal *"Tutup Modal"*.
- **Komponen yang tidak boleh tampil**:
  - Tombol edit untuk mengubah angka `estimasi_berat_kg` Tahap 1 atau `berat_driver_kg` Tahap 2 (kedua tahap awal tersebut harus dikunci *Read-Only* demi keaslian rekam jejak audit).
- **Navigasi masuk**: Tabel `ADM-003 (orders/data)` saat tombol hijau *Validasi Timbang Akhir* diklik.
- **Navigasi keluar**: Kembali ke tabel `ADM-003` setelah eksekusi ACID sukses (baris tabel langsung berubah menjadi hijau `completed`).
- **Data yang dibutuhkan**: Rincian `orders` + `order_items` (angka Tahap 1 dan Tahap 2), katalog `jenis_sampah` (harga poin/kg), kueri eksekusi POST `modules/orders/index.php?action=verify_final`.
- **State**:
  - `Loading`: Spinner dalam tombol submit saat backend PHP menjalankan blok `mysqli_begin_transaction()`.
  - `Empty`: *Not applicable*.
  - `Error (ACID Rollback / Invalid Input)`: **Bootstrap Alert Red (`alert-danger`)** muncul di dalam modal jika angka `berat_aktual_kg` diisi `0` atau negatif, ATAU jika kueri MySQL mengalami *rollback*: *"Transaksi Gagal Disimpan (Rollback). Saldo warga tidak diubah demi keamanan. Silakan coba kembali."*
  - `Success`: Modal tertutup otomatis dan memunculkan *Toast Notification Sukses* di pojok kanan atas layar Admin: *"Reward +14.500 Poin Sah berhasil disuntikkan ke akun Kevin Khayiss."*
- **Business Rules**: **ATURAN HUKUM TERTINGGI REWARD & ACID**: Angka **`berat_aktual_kg` (Tahap 3)** yang diketik di dalam modal ini adalah **Satu-Satunya Acuan Mutlak Poin Sah**. Sesaat setelah tombol *Selesaikan Order* ditekan, PHP mengeksekusi 4 kueri atomik (`UPDATE order_items`, `UPDATE orders completed`, `UPDATE pengguna.saldo + poin_final`, `INSERT INTO notifikasi`) di dalam blok `begin_transaction()` $\rightarrow$ `COMMIT`. Jika ada 1 saja yang gagal, `ROLLBACK` membatalkan seluruh mutasi.
- **Status yang digunakan**: Mengubah status dari `validating` $\rightarrow$ **`completed`**.
- **CTA utama**: Tombol *Filled Green Button* **"Selesaikan Order & Salurkan Poin (`completed`)"** (`#1E7D32`, `height 48px`, `16px Bold`).
- **CTA sekunder**: Tombol *Secondary Outlined* *"Tutup / Batal"*.
- **Design Notes**: Tabel sanding 3 kolom harus memiliki warna latar yang berbeda untuk setiap tahap (Kolom 1 abu-abu muda, Kolom 2 biru muda, Kolom 3 hijau terang berborder tebal) agar petugas tidak salah memasukkan angka.
- **Accessibility**: Kotak input angka Tahap 3 mendukung *stepper up/down arrow* dan navigasi `Tab`.
- **Animation**: Kalkulator poin memperbarui angka secara elastis `200ms` saat diketik.
- **Responsive Rules**: Web Grid `> 1024px`. Modal berlebar `860px` di tengah layar (`modal-lg`).

```prompt
[STITCH AI MASTER PROMPT - ADM-004: Warehouse Final Weighing Modal (verify_modal)]
Design a high-precision, authoritative, and definitive Material Design 3 / Bootstrap 5 Enterprise Web Large Modal (`modal-lg verify_modal.php`) for the final warehouse verification in "Bank Sampah Bersinar".

Style & Theme Requirements:
- Large Modal Container (`width 860px`, centered in desktop browser viewport over a 60% darkened table backdrop `#0F172A opacity 0.6`).
- Pure White modal surface #FFFFFF, Emerald Green #1E7D32, Indigo #EDE7F6, Dark Slate #0F172A, crisp borders.
- Plus Jakarta Sans Typography, Material Symbols Outlined Icons 24px.
- Built specifically for side-by-side 3-tier weighing audit and atomic transaction execution.

Layout Anatomy:
1. Modal Header (Height 64px, background #F8FAFC, border bottom 1.5px solid #CBD5E1, padding horizontal 24px):
   - Left: Icon 'verified' (#1E7D32) with Headline Large "Validasi Timbang Akhir Gudang — #ORD-1024" (20px Bold #0F172A).
   - Right: Purple Badge Pill "Sedang Divalidasi Gudang" (#EDE7F6 background, text #4527A0 12px Bold) and a crisp close button `[X]`.
2. Modal Body (Padding 24px, scrollable if needed):
   - Officer & Customer Audit Box (Light gray container #F8FAFC, border 1px solid #CBD5E1, BorderRadius 8px, padding 14px, margin bottom 20px):
     - Grid 3 columns: Col 1 "Nasabah Warga: Kevin Khayiss (+62 812-3456...)", Col 2 "Armada Driver: Budi Santoso (D 8821 XA)", Col 3 "Petugas Verifikator: Admin Gudang Pusat".
   - 3-Tier Weighing Comparison Table (Side-by-Side Audit Grid, border 2px solid #CBD5E1, BorderRadius 8px, overflow hidden):
     - Table Header (`thead`, background #1E293B, text white 13px Bold): `ITEM SAMPAH & HARGA/KG` | `TAHAP 1: ESTIMASI WARGA` | `TAHAP 2: TIMBANG DRIVER` | `TAHAP 3: TIMBANG AKTUAL GUDANG (FINAL AUTHORITY)`.
     - Table Row 1 (Plastik PET Bersih - Rp 2.500/Kg):
       - Col 1: "Plastik PET Bersih" (14px Bold #0F172A) & "Rp 2.500 / Poin per Kg".
       - Col 2 (Read-Only): Pill "3.5 Kg" (Gray text #64748B).
       - Col 3 (Read-Only): Pill "3.2 Kg (Diangkut)" (Blue text #0288D1).
       - Col 4 (PRIMARY FINAL INPUT): High-contrast Number Input Box (`height 44px`, border 2.5px solid #1E7D32, BorderRadius 6px, right-aligned bold text "3.1" 16px Bold #0F172A with suffix "Kg" #1E7D32).
     - Table Row 2 (Kertas Kardus - Rp 1.500/Kg):
       - Col 1: "Kertas Kardus" | Col 2: "5.0 Kg" | Col 3: "4.8 Kg" | Col 4 Input Box showing "4.5" Kg.
   - JS Real-time Points Calculator Display Box (Margin top 20px, glowing green container #E8F5E9, border 2px solid #1E7D32, BorderRadius 12px, padding 20px):
     - Left Column: Icon 'monetization_on' (36px #1E7D32) next to label "TOTAL REWARD POIN SAH (FINAL AUTHORITY):" (13px Bold #1E7D32) and large typography display "14.500 Poin Sah" (28px Bold #1E7D32).
     - Right Column: "Total Berat Aktual Gudang (Tahap 3): 7.6 Kg" (14px Bold #0F172A) and "Status Mutasi Saldo: Akan disuntikkan via Transaksi Atomic ACID MySQL." (12px Italic #2E7D32).
   - Officer Notes Box (Margin top 16px): Textarea label "Catatan Resmi Inspeksi Gudang" showing "Kardus dipotong 0.3 Kg karena basah terkena air hujan." (13px Regular).
3. Modal Footer (Height 76px, background #F8FAFC, border top 1.5px solid #CBD5E1, padding horizontal 24px, right-aligned buttons):
   - Secondary Button: Outlined Button "Tutup / Batal" (border #CBD5E1, text #64748B 14px Bold, height 46px, margin right 12px).
   - Primary ACID Execution Button: Glowing Green Filled Button "SELESAIKAN ORDER & SALURKAN POIN (COMPLETED) ->" (#1E7D32 background, white text 15px Bold, height 48px, BorderRadius 8px, box-shadow `0px 4px 12px rgba(30,125,50,0.3)`).

Visual Vibe: Definitive, legally binding, ultra-precise, authoritative, transparent, and foolproof.
```

---

### ADM-005 : Waste Catalog Management (`jenis_sampah/data` CRUD Harga Poin)
- **Nama Screen**: `Waste Catalog Management (jenis_sampah/data.php)`
- **Role**: Web Admin & Petugas Gudang Bank Sampah
- **Tujuan Screen**: Mengelola katalog master jenis sampah daur ulang, menetapkan satuan (`Kg`), dan menentukan harga konversi poin per kilogram (`Rp / Poin per Kg`) yang menjadi referensi kalkulator di form warga (`WRG-004`) dan modal verifikasi gudang (`ADM-004`).
- **Business Goal**: Memastikan harga poin selalu akurat dan ter-update sesuai harga pasar daur ulang terkini, menjaga keseimbangan finansial Bank Sampah.
- **Referensi dari Screen Catalog**: `ADM-005` (*Existing Module - High Priority*).
- **Komponen yang harus tampil**:
  - *Page Header*: Judul *"Katalog Jenis Sampah Daur Ulang"* dan tombol hijau kanan atas **"+ Tambah Jenis Sampah Baru"**.
  - **Waste Catalog Table (*DataTables jQuery*)**:
    - Kolom `ID` | `NAMA JENIS SAMPAH` (`Plastik PET Bersih`) | `SATUAN` (`Kilogram / Kg`) | `HARGA POIN PER KG` (`Rp 2.500 / Poin`) | `STATUS` (`Aktif` / `Non-Aktif`) | `AKSI (Edit / Hapus)`.
  - **Modal Form CRUD Tambah / Edit Jenis Sampah (*Bootstrap Modal*)**:
    - Form Input `Nama Jenis Sampah`.
    - Form Input `Satuan` (Default `Kg`).
    - *Number Input Box* `Harga Poin per Kg` (berformat angka rupiah/poin).
    - Dropdown `Status` (`Aktif` vs `Non-Aktif`).
    - Tombol **"Simpan Katalog"**.
- **Komponen yang tidak boleh tampil**:
  - Rincian penjemputan warga atau tracking armada.
- **Navigasi masuk**: Sidebar menu *"Katalog Jenis Sampah"*.
- **Navigasi keluar**: Modal CRUD atau kembali ke Dasbor `ADM-002`.
- **Data yang dibutuhkan**: Kueri `SELECT * FROM jenis_sampah` dari `jenis_sampah/data.php`.
- **State**:
  - `Loading`: *Shimmer table skeleton*.
  - `Empty`: *"Belum ada katalog jenis sampah yang ditambahkan."*
  - `Error`: *Validation Alert* jika harga poin diisi `0` atau negatif.
  - `Success`: Tabel ter-update dan siap dipakai oleh kalkulator warga & modal verifikasi gudang.
- **Business Rules**: Jenis sampah berstatus `Non-Aktif` otomatis disembunyikan dari dropdown form warga (`WRG-004`), namun tetap tersimpan untuk keperluan audit riwayat pesanan lama.
- **Status yang digunakan**: *None* (`Aktif` vs `Non-Aktif`).
- **CTA utama**: Tombol Hijau **"+ Tambah Jenis Sampah Baru"** / Tombol *"Simpan Katalog"*.
- **CTA sekunder**: Tombol ikon *Edit (`edit`)* & *Hapus (`delete`)* pada setiap baris.
- **Design Notes**: Gunakan font *SemiBold* pada kolom `Harga Poin per Kg` agar mudah dipindai.
- **Accessibility**: Dukungan navigasi keyboard pada modal form.
- **Animation**: Modal muncul dengan efek *Bootstrap fade* `200ms`.
- **Responsive Rules**: Web Grid `> 1024px`.

```prompt
[STITCH AI MASTER PROMPT - ADM-005: Waste Catalog Management Web Admin]
Design a clean, structured Material Design 3 / Bootstrap 5 Enterprise Web Waste Catalog Management Table & CRUD Modal (`jenis_sampah/data.php`) for the back-office portal of "Bank Sampah Bersinar".

Style & Theme Requirements:
- Desktop Web 12-column layout (`1920x1080` representation) with Fixed Left Sidebar (#0F172A) and main content area (#F8FAFC).
- Color Palette: Emerald Green #1E7D32, Dark Slate #0F172A, Border Slate #CBD5E1.
- Plus Jakarta Sans Typography, Material Symbols Outlined Icons 24px.

Layout Anatomy:
1. Top Page Header (Margin bottom 20px):
   - Left: Headline Large "Katalog Jenis Sampah Daur Ulang" (24px Bold #0F172A) with subtitle "Kelola harga konversi poin per kilogram untuk referensi kalkulator sistem" (14px #64748B).
   - Right: Glowing Green Filled Button "+ Tambah Jenis Sampah Baru" (#1E7D32 background, white text 14px Bold, height 44px, BorderRadius 8px, icon 'add').
2. Main Catalog Table Card (White card #FFFFFF, BorderRadius 12px, border 1.5px solid #CBD5E1, elevation-1 shadow):
   - Table Header (`thead`, background #F1F5F9, text 13px Bold #0F172A): `ID KODE` | `NAMA JENIS SAMPAH` | `SATUAN` | `HARGA POIN / KG` | `STATUS KATALOG` | `AKSI PETUGAS`.
   - Table Row 1: Col 1 "#JS-001" | Col 2 "Plastik PET Bersih (Botol Minuman)" (Bold #0F172A) | Col 3 "Kilogram (Kg)" | Col 4 "Rp 2.500 / Poin" (15px Bold #1E7D32) | Col 5 Green Pill "Aktif" (#E8F5E9 text #1B5E20) | Col 6 Two action icons: blue 'edit' and red 'delete'.
   - Table Row 2: Col 1 "#JS-002" | Col 2 "Kertas Kardus Bekas" | Col 4 "Rp 1.500 / Poin" | Col 5 Green Pill "Aktif".
3. Overlaid CRUD Modal Form (Displayed on right/center as a pop-up representation, width 500px, white surface #FFFFFF, BorderRadius 12px, elevation-3 border 1.5px solid #1E7D32):
   - Header: "Tambah / Edit Jenis Sampah" (18px Bold #0F172A) with close `[X]`.
   - Form Fields: Outlined Input "Nama Jenis Sampah" (e.g., "Plastik PET Bersih"), Outlined Input "Satuan" ("Kilogram / Kg"), Outlined Number Input "Harga Poin per Kg (Rp/Poin)" ("2500"), and Dropdown "Status" ("Aktif").
   - Modal Footer: Filled Green Button "Simpan Katalog ->" (#1E7D32, height 44px, full width).

Visual Vibe: Organized, precise, highly scannable, administrative, and clean.
```

---

### ADM-006 : Users & Drivers Data Management (`warga/data` & `driver/data`)
- **Nama Screen**: `Users & Drivers Data Management (warga/data & driver/data)`
- **Role**: Web Admin Bank Sampah
- **Tujuan Screen**: Mengelola data akun nasabah warga beserta **Saldo Poin Aktual (`pengguna.saldo`)** mereka, serta meregistrasikan dan mengelola akun resmi armada driver beserta **Spesifikasi Kendaraan Truk (`driver.plat_nomor`, `driver.kapasitas_kg`)**.
- **Business Goal**: Memelihara integritas data pengguna dan armada penjemput resmi di dalam database `pengguna` dan `driver`.
- **Referensi dari Screen Catalog**: `ADM-006` (*Existing Module - Medium Priority*).
- **Komponen yang harus tampil**:
  - *Page Header*: Judul *"Manajemen Data Nasabah & Armada Driver"*.
  - **Top Segmented 2 Tabs Bar**:
    - Tab 1: **"Data Nasabah Warga (`warga/data` - 1,240 Nasabah)"**.
    - Tab 2: **"Data Armada Driver & Truk (`driver/data` - 18 Armada)"**.
  - *Tab 1 Warga Table*:
    - Kolom `ID WARGA` | `NAMA LENGKAP` | `NO. TELEPON / EMAIL` | `ALAMAT DOMISILI DEFAULT` | `SALDO POIN AKTUAL` (`14.500 Poin` Hijau Bold) | `AKSI (Detail Riwayat / Edit)`.
  - *Tab 2 Driver Table (Armada & Truk Spec)*:
    - Kolom `ID ARMADA` | `NAMA DRIVER` | `USERNAME / TELEPON` | **`PLAT NOMOR KENDARAAN (`D 8821 XA` - Font Plat Nomor)`** | `TIPE TRUK & KAPASITAS` (`Truk Bak - 800 Kg/Hari`) | `STATUS KETERSEDIAAN` (`Online` / `Offline`) | `AKSI`.
  - **Modal Form Registrasi Armada Driver Baru (*Bootstrap Modal*)**: Form input Nama Driver, Username, Password Armada, Plat Nomor Kendaraan (`D XXXX XX`), Tipe Truk, dan Kapasitas Maksimal KG.
- **Komponen yang tidak boleh tampil**:
  - Tombol edit saldo poin warga secara sembarangan (karena saldo poin hanya boleh berubah secara sah melalui eksekusi transaksi ACID di modal `verify_modal.php - ADM-004`).
- **Navigasi masuk**: Sidebar menu *"Data Warga & Driver"*.
- **Navigasi keluar**: Modal registrasi driver baru atau kembali ke Dasbor `ADM-002`.
- **Data yang dibutuhkan**: Kueri `SELECT * FROM pengguna WHERE level = 'warga'` dan `SELECT * FROM driver JOIN pengguna...`.
- **State**:
  - `Loading`: *Shimmer table skeleton*.
  - `Empty`: *"Belum ada data warga/driver yang terdaftar."*
  - `Error`: *Alert Error* jika duplikasi nomor telepon/plat kendaraan saat registrasi driver.
  - `Success`: Tabel ter-update lengkap.
- **Business Rules**: Registrasi akun khusus armada (`level = 'driver'`) **hanya dapat dilakukan oleh Web Admin melalui tab ini (`ADM-006`)** demi menjaga keamanan operasional. Warga biasa tidak bisa mendaftarkan diri sebagai driver.
- **Status yang digunakan**: *None* (`Online` / `Offline` untuk driver).
- **CTA utama**: Tombol Hijau **"+ Registrasi Armada Driver Baru"** (di Tab 2 Driver).
- **CTA sekunder**: Tombol ikon *Detail Riwayat (`history`)* pada setiap baris warga.
- **Design Notes**: Kolom Plat Nomor Truk diberi bingkai hitam kecil bergaya plat kendaraan agar menonjol.
- **Accessibility**: Tabel mendukung navigasi pencarian cepat.
- **Animation**: Pergeseran antar Tab 1 dan Tab 2 `200ms`.
- **Responsive Rules**: Web Grid `> 1024px`.

```prompt
[STITCH AI MASTER PROMPT - ADM-006: Users & Drivers Data Management Web Admin]
Design a comprehensive, highly detailed Material Design 3 / Bootstrap 5 Enterprise Web Users & Drivers Data Management Table (`warga/data & driver/data`) for the back-office portal of "Bank Sampah Bersinar".

Style & Theme Requirements:
- Desktop Web 12-column layout (`1920x1080` representation) with Fixed Left Sidebar (#0F172A) and main content area (#F8FAFC).
- Color Palette: Emerald Green #1E7D32, Dark Slate #0F172A, Border Slate #CBD5E1.
- Plus Jakarta Sans Typography, Material Symbols Outlined Icons 24px.

Layout Anatomy:
1. Top Page Header & Tab Controls (Margin bottom 20px):
   - Left: Headline Large "Manajemen Data Nasabah & Armada Driver" (24px Bold #0F172A).
   - Segmented Top Tabs Bar (Height 48px, white surface, border bottom 2px solid #CBD5E1, margin top 16px):
     - Tab 1: "Data Nasabah Warga (1.240 Nasabah)" (inactive slate text).
     - Tab 2: "Data Armada Driver & Truk (18 Armada)" (ACTIVE STATE: solid green bottom border 3px #1E7D32, text 15px Bold #1E7D32).
   - Right (Top of Table): Glowing Green Button "+ Registrasi Armada Driver Baru" (#1E7D32, height 44px, Bold white text).
2. Driver & Vehicle Specification Table Grid (Tab 2 Active, White card #FFFFFF, BorderRadius 12px, border 1.5px solid #CBD5E1, elevation-1):
   - Table Header (`thead`, background #F1F5F9, text 13px Bold #0F172A): `ID ARMADA` | `NAMA PETUGAS DRIVER` | `NO. TELEPON / USERNAME` | `PLAT NOMOR KENDARAAN` | `TIPE TRUK & KAPASITAS` | `STATUS KETERSEDIAAN` | `AKSI`.
   - Table Row 1 (Online Driver):
     - Col 1: "#DRV-0012" | Col 2: "Budi Santoso" (14px Bold #0F172A) | Col 3: "0812-9988-7766 (budisantoso)".
     - Col 4: Black License Plate Box (`background #0F172A`, text white `D 8821 XA` 14px Bold, padding 4px 10px, BorderRadius 4px).
     - Col 5: "Truk Bak Terbuka (Maks 800 Kg/Hari)" (Bold green #1E7D32).
     - Col 6: Green Pill "ONLINE / SIAP" (#E8F5E9 text #1B5E20).
     - Col 7: Action icons: blue 'edit' and gray 'history'.
   - Table Row 2 (Offline Driver): "#DRV-0015" | "Asep Saepudin" | License Plate "D 9012 YB" | Gray Pill "OFFLINE".
3. Overlaid Registration Modal (Right/Center pop-up representation, width 520px, white surface #FFFFFF, border 1.5px solid #1E7D32):
   - Header: "Registrasi Armada Driver Baru" (18px Bold #0F172A).
   - Fields: Input "Nama Lengkap Driver", Input "Username Armada", Input "Password Khusus", Input "Plat Nomor Kendaraan (e.g., D 8821 XA)", Dropdown "Tipe Kendaraan" ("Truk Bak Terbuka / Engkel"), Number Input "Kapasitas Maksimal (Kg/Hari)" ("800").
   - Footer: Button "Daftarkan Armada Resmi ->" (#1E7D32, full width).

Visual Vibe: Authoritative, administrative, meticulous, secure, and clean.
```

---

### ADM-007 : Education & Operational Reports Management (`edukasi/data` & `laporan/data`)
- **Nama Screen**: `Education & Operational Reports (edukasi/data & laporan/data)`
- **Role**: Web Admin Bank Sampah
- **Tujuan Screen**: Menyediakan dua modul penunjang akhir: **Modul Manajemen Edukasi (`edukasi/data`)** untuk CRUD artikel daur ulang yang tampil di aplikasi Warga (`WRG-008`), serta **Modul Rekapitulasi Laporan Operasional (`laporan/data`)** untuk memfilter rentang tanggal penjemputan dan mencetak dokumen resmi (*PDF / Excel*) sebagai lampiran Laporan Tugas Akhir.
- **Business Goal**: Memenuhi standar kelengkapan administrasi *Enterprise Software* dan menghasilkan keluaran laporan berformat resmi (*Print-Ready Export*) untuk keperluan audit tugas akhir maupun pelaporan manajemen Bank Sampah.
- **Referensi dari Screen Catalog**: `ADM-007` (*Existing Module - Medium Priority*).
- **Komponen yang harus tampil**:
  - *Page Header*: Judul *"Edukasi & Laporan Operasional"*.
  - **Top Segmented 2 Tabs Bar**:
    - Tab 1: **"Manajemen Artikel Edukasi (`edukasi/data`)"**.
    - Tab 2: **"Rekapitulasi Laporan Penjemputan (`laporan/data` - ACTIVE)"**.
  - *Tab 2 Operational Reports Layout*:
    - **Filter Date Range Box**: Input `Dari Tanggal (`Date Picker`)` hingga `Sampai Tanggal (`Date Picker`)`, Dropdown `Filter Status` (`completed` / Semua), dan tombol Biru *"Filter Laporan (`search`)"*.
    - **Export Action Buttons Bar**: Tombol Merah **"Cetak Laporan Resmi (PDF - `picture_as_pdf`)"** & Tombol Hijau **"Unduh Rekapitulasi (Excel - `table_view`)"**.
    - **Report Summary Preview Table (*DataTables*)**:
      - Kolom `NO` | `ID & TANGGAL` | `NAMA WARGA` | `DRIVER PENGANGKUT` | **`TOTAL BERAT AKTUAL GUDANG (`berat_aktual_kg`)`** | **`TOTAL POIN SAH DISALURKAN (`poin_final`)`** | `STATUS`.
      - *Table Footer Totals Row (`tfoot`)*: Menampilkan sum/total keseluruhan `Total Volume Sampah Daur Ulang: 1.250,5 Kg` dan `Total Poin Sah Disalurkan: 2.450.000 Poin` pada rentang tanggal yang dipilih.
- **Komponen yang tidak boleh tampil**:
  - Tombol pengubahan status pesanan (karena modul laporan bersifat *Read-Only Audit*).
- **Navigasi masuk**: Sidebar menu *"Edukasi & Laporan"*.
- **Navigasi keluar**: Kembali ke Dasbor `ADM-002` atau *Print Preview Browser Window*.
- **Data yang dibutuhkan**: Kueri SQL `SELECT * FROM orders WHERE created_at BETWEEN ? AND ? AND status = 'completed'` dari `laporan/data.php`.
- **State**:
  - `Loading`: Spinner pada tombol export saat menghasilkan PDF/Excel.
  - `Empty`: *"Tidak ada transaksi penjemputan selesai pada rentang tanggal yang dipilih."*
  - `Error`: *Alert Error* jika tanggal akhir lebih kecil dari tanggal awal.
  - `Success`: Tabel rekap dimuat dengan baris total di bagian bawah (*tfoot*).
- **Business Rules**: Angka volume sampah (Kg) dan total poin pada laporan resmi **wajib bersumber dari `berat_aktual_kg` (Tahap 3)** pada pesanan `completed`.
- **Status yang digunakan**: Khusus menyoroti pesanan berstatus **`completed`**.
- **CTA utama**: Tombol Merah **"Cetak Laporan Resmi (PDF)"** (`height 46px`).
- **CTA sekunder**: Tombol Biru *"Filter Laporan"*.
- **Design Notes**: Tampilan laporan harus dirancang rapi dengan kop header Bank Sampah Bersinar agar siap dicetak langsung (*Print-Ready layout*).
- **Accessibility**: Tabel rekap mendukung ekspor data tabular.
- **Animation**: *Fade-in table* `300ms`.
- **Responsive Rules**: Web Grid `> 1024px`.

```prompt
[STITCH AI MASTER PROMPT - ADM-007: Education & Operational Reports Web Admin]
Design a pristine, executive-grade Material Design 3 / Bootstrap 5 Enterprise Web Operational Reports Management & PDF Export screen (`laporan/data.php`) for the back-office portal of "Bank Sampah Bersinar".

Style & Theme Requirements:
- Desktop Web 12-column layout (`1920x1080` representation) with Fixed Left Sidebar (#0F172A) and main content area (#F8FAFC).
- Color Palette: Emerald Green #1E7D32, Danger Red #D32F2F (PDF Export), Info Blue #0288D1, Dark Slate #0F172A.
- Plus Jakarta Sans Typography, Material Symbols Outlined Icons 24px.

Layout Anatomy:
1. Top Page Header & Tab Controls (Margin bottom 20px):
   - Left: Headline Large "Edukasi & Laporan Operasional" (24px Bold #0F172A).
   - Segmented Top Tabs Bar (Height 48px, white surface, border bottom 2px solid #CBD5E1, margin top 16px):
     - Tab 1: "Manajemen Artikel Edukasi (edukasi/data)" (inactive slate text).
     - Tab 2: "Rekapitulasi Laporan Penjemputan (laporan/data)" (ACTIVE STATE: solid green bottom border 3px #1E7D32, text 15px Bold #1E7D32).
2. Filter Date Range & Export Action Bar (White card #FFFFFF, BorderRadius 12px, border 1.5px solid #CBD5E1, padding 18px, margin bottom 20px, flex layout):
   - Left Filter Box: Outlined Date Picker "Dari Tanggal" ("01 Juli 2026") next to Outlined Date Picker "Sampai Tanggal" ("31 Juli 2026") next to Blue Button "Filter Laporan ->" (#0288D1, height 42px, icon 'search').
   - Right Export Buttons Box: Button 1 Red "Cetak Laporan Resmi (PDF)" (#D32F2F background, white text 14px Bold, height 42px, icon 'picture_as_pdf', BorderRadius 6px) next to Button 2 Green "Unduh Rekap (Excel)" (#1E7D32 background, white text, height 42px, icon 'table_view').
3. Report Summary Preview Table Grid (White card #FFFFFF, BorderRadius 12px, border 1.5px solid #CBD5E1, elevation-1 shadow, overflow hidden):
   - Table Header (`thead`, background #1E293B, text white 13px Bold): `NO` | `ID & TANGGAL` | `NASABAH WARGA` | `ARMADA PENGANGKUT` | `TOTAL BERAT AKTUAL (TAHAP 3 FINAL)` | `TOTAL REWARD POIN SAH` | `STATUS`.
   - Table Rows (`tbody`, 14px text #0F172A):
     - Row 1: Col 1 "1." | Col 2 "#ORD-1018 (05 Jul 2026)" | Col 3 "Kevin Khayiss" | Col 4 "Driver Budi Santoso (D 8821 XA)" | Col 5 "4.2 Kg (Plastik PET)" (Bold #0F172A) | Col 6 "+10.500 Poin" (Bold green #1E7D32) | Col 7 Green Pill "Selesai (completed)".
     - Row 2: Col 1 "2." | Col 2 "#ORD-1015 (03 Jul 2026)" | Col 3 "Siti Aminah" | Col 4 "Driver Asep Saepudin (D 9012 YB)" | Col 5 "8.0 Kg (Kardus & PET)" | Col 6 "+16.000 Poin" | Col 7 Green Pill "Selesai".
   - Table Footer Totals Row (`tfoot`, background #E8F5E9, border top 2.5px solid #1E7D32, text 15px Bold #1E7D32):
     - `TOTAL REKAPITULASI PERIODE INI:` across Col 1-4 | Col 5: `1.250,5 Kg Total Volume` | Col 6: `+2.450.000 Poin Sah Disalurkan` | Col 7: `100% Verified`.

Visual Vibe: Executive, print-ready, officially certified, highly auditable, and pristine.
```

---

## 4. TABEL RINGKASAN MASTER PROMPT STITCH AI (*Master Summary Matrix*)

Berikut adalah tabel ringkasan verifikasi kesiapan seluruh 24 spesifikasi layar dan prompt generatif di dalam dokumen ini:

| Screen ID | Nama Screen / Modul | Peran Aktor (*Role*) | Prioritas Implementasi | Status Kesiapan | Prompt Ready |
| :---: | :--- | :---: | :---: | :---: | :---: |
| **`WRG-001`** | Splash & Onboarding Intro Screen | Warga | **High Priority** | Existing / Verified | **[✓ READY TO COPY]** |
| **`WRG-002`** | Authentication Gate (Login & Register)| Warga | **Critical Priority** | Existing / Verified | **[✓ READY TO COPY]** |
| **`WRG-003`** | Home Screen (Dasbor Warga & Hero Card) | Warga | **High Priority** | Existing / Verified | **[✓ READY TO COPY]** |
| **`WRG-004`** | Pickup Request Screen (Form Tahap 1) | Warga | **Critical Priority** | Existing / Verified | **[✓ READY TO COPY]** |
| **`WRG-005`** | Orders Screen (Tab 2 Daftar Pesanan) | Warga | **High Priority** | Need Revision / Verified| **[✓ READY TO COPY]** |
| **`WRG-006`** | Order Detail Screen (Audit 3 Tahap) | Warga | **Critical Priority** | Need Revision / Verified| **[✓ READY TO COPY]** |
| **`WRG-007`** | Driver Tracking Screen (Peta Live & ETA) | Warga | **Medium Priority** | New Screen / Verified | **[✓ READY TO COPY]** |
| **`WRG-008`** | AI Scan & Education Module | Warga | **Low Priority** | Existing / Verified | **[✓ READY TO COPY]** |
| **`WRG-009`** | Alerts & Reward History Screen | Warga | **High Priority** | Need Revision / Verified| **[✓ READY TO COPY]** |
| **`WRG-010`** | Profile & Settings Screen | Warga | **Medium Priority** | Existing / Verified | **[✓ READY TO COPY]** |
| **`DRV-001`** | Driver Authentication Gate | Armada Driver | **High Priority** | Existing / Verified | **[✓ READY TO COPY]** |
| **`DRV-002`** | Dashboard & Command Center Armada | Armada Driver | **Critical Priority** | Existing / Verified | **[✓ READY TO COPY]** |
| **`DRV-003`** | Pickup Detail & Google Maps Navigation | Armada Driver | **High Priority** | Existing / Verified | **[✓ READY TO COPY]** |
| **`DRV-004`** | Pickup Verification (Timbang Tahap 2) | Armada Driver | **Critical Priority** | Need Revision / Verified| **[✓ READY TO COPY]** |
| **`DRV-005`** | Warehouse Handover (Serah Gudang) | Armada Driver | **Critical Priority** | New Screen / Verified | **[✓ READY TO COPY]** |
| **`DRV-006`** | Schedule & History Screen Driver | Armada Driver | **Medium Priority** | Existing / Verified | **[✓ READY TO COPY]** |
| **`DRV-007`** | Alerts & Driver Profile Screen | Armada Driver | **Low Priority** | Existing / Verified | **[✓ READY TO COPY]** |
| **`ADM-001`** | Admin Authentication Gate (`login.php`) | Web Admin | **High Priority** | Existing / Verified | **[✓ READY TO COPY]** |
| **`ADM-002`** | Executive Dashboard (`dashboard`) | Web Admin | **Medium Priority** | Existing / Verified | **[✓ READY TO COPY]** |
| **`ADM-003`** | Orders Management Table (`orders/data`) | Web Admin | **Critical Priority** | Need Revision / Verified| **[✓ READY TO COPY]** |
| **`ADM-004`** | Warehouse Final Weighing Modal (`verify_modal`) | Web Admin | **Critical Priority** | New Module / Verified | **[✓ READY TO COPY]** |
| **`ADM-005`** | Waste Catalog Management (`jenis_sampah`) | Web Admin | **High Priority** | Existing / Verified | **[✓ READY TO COPY]** |
| **`ADM-006`** | Users & Drivers Data (`warga & driver`) | Web Admin | **Medium Priority** | Existing / Verified | **[✓ READY TO COPY]** |
| **`ADM-007`** | Education & Operational Reports (`laporan`) | Web Admin | **Medium Priority** | Existing / Verified | **[✓ READY TO COPY]** |

---
*Dokumen STITCH_PROMPTS.md ini mengacu penuh pada MASTER_PROJECT_PLAN.md, FEATURE_INVENTORY.md, CONTENT_INVENTORY.md, INFORMATION_ARCHITECTURE.md, SCREEN_CATALOG.md, SITEMAP.md, USER_FLOW.md, dan UI_REQUIREMENTS.md sebagai Single Source of Truth (SSOT).*
