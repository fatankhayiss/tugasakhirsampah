# UI/UX ARCHITECTURE & DESIGN SYSTEM REQUIREMENTS (`UI_REQUIREMENTS.md`)
**Sistem Informasi Bank Sampah Bersinar — Modul Penjemputan Sampah Berbasis Mobile**
*Master Spesifikasi Visual, Design Tokens, Anatomi Komponen, Pemetaan Layar, dan Panduan Implementasi Antarmuka (Phase 6–9 Unified Spec)*

---

## 1. EXECUTIVE SUMMARY (*Ringkasan Eksekutif*)

Dokumen **UI/UX Requirements (`UI_REQUIREMENTS.md`)** ini disusun dalam kapasitas rekayasa arsitektur perangkat lunak (*Enterprise Software Architecture*) sebagai **Master Spesifikasi Antarmuka Terpadu** yang menggabungkan seluruh persyaratan rancangan visual dan pengalaman pengguna untuk ketiga platform: **Aplikasi Mobile Warga (`/Mobile`)**, **Aplikasi Mobile Driver (`/Halaman-Driver`)**, dan **Portal Web Admin (`/bank_sampah`)**.

Dalam rangka mempercepat peta jalan pengembangan (*Roadmap Acceleration*) tanpa mengurangi ketajaman spesifikasi akademis maupun teknis, dokumen ini menyatukan parameter-parameter esensial yang sebelumnya tersebar di 4 fase rancangan UI/UX:
1. **Phase 6: Wireframe & Low-Fidelity Layout Guidelines** (Struktur tata letak layar dan hierarki informasi visual).
2. **Phase 7: Design System & UI Components** (*Design Tokens*, palet warna, tipografi, grid, dan 16 komponen standar Material 3).
3. **Phase 8: High-Fidelity UI Design & Stitch Guidelines** (Pedoman penataan visual presisi tinggi untuk pembuatan antarmuka).
4. **Phase 9: Interactive Prototype & Verification Specs** (Mapping perilaku layar dan kondisi state per skenario pengguna).

Dokumen ini adalah **Single Source of Truth (SSOT)** mutlak untuk seluruh aspek visual antarmuka yang dijamin 100% konsisten terhadap **`USER_FLOW.md`**, **`SITEMAP.md`**, **`SCREEN_CATALOG.md`**, **`INFORMATION_ARCHITECTURE.md`**, dan **`MASTER_PROJECT_PLAN.md`**. Seluruh spesifikasi ini wajib menjadi acuan bagi *Software Engineer*, *Frontend Developer Flutter*, serta *Web Developer PHP Native* dalam mengimplementasikan antarmuka yang indah, responsif, tahan terhadap kesalahan, serta mematuhi **Aturan Mutlak 6 Status Pesanan** dan **3 Tahap Penimbangan Muatan**.

---

## 2. DESIGN GOALS (*Tujuan & Filosofi Perancangan Antarmuka*)

Perancangan antarmuka Bank Sampah Bersinar dilandasi oleh 8 (delapan) pilar filosofi desain yang menjamin kualitas aplikasi sekelas *Enterprise Software*:

1. **Modern & Clean Aesthetic**: Mengadopsi prinsip tata letak bersih bebas ketidakteraturan (*Clutter-Free*), memanfaatkan ruang putih (*White Space / Negative Space*) secara optimal agar fokus pengguna tertuju pada informasi kritis (seperti status pesanan dan perolehan poin).
2. **Mobile-First Paradigm**: Seluruh tata letak antarmuka mobile (`/Mobile` & `/Halaman-Driver`) dirancang dengan mengutamakan pengoperasian satu tangan (*One-Handed Operation*), menempatkan tombol aksi utama (*Primary Call-to-Action / CTA*) pada *Thumb Zone* (area bawah layar yang mudah dijangkau ibu jari).
3. **Material 3 (M3) Android Standard**: Mengacu penuh pada pedoman *Material Design 3* resmi dari Google, menggunakan komponen yang memanfaatkan elevasi adaptif, sudut melengkung dinamis (*Rounded Corners*), serta sistem pewarnaan yang harmonis (*Tonal Color Palette*).
4. **Eco-Friendly Green Theme**: Memancarkan identitas hijau lingkungan (*Green Ecology Identity*) melalui palet warna zamrud (*Emerald Green*) dan dedaunan (*Leaf Green*) yang memberi kesan sejuk, tepercaya, teratur, dan peduli kebersihan lingkungan.
5. **Professional Enterprise Grade**: Menyajikan antarmuka yang terstruktur rapi, tepercaya, dan akademis. Hindari penggunaan elemen dekoratif yang tidak relevan, animasi berlebihan, atau warna-warna neon yang mengurangi keserosan sistem pelayanan publik.
6. **High Contrast & Outdoor Readability**: Khusus untuk aplikasi **Mobile Driver (`/Halaman-Driver`)**, kontras rasio antar teks dan latar belakang ditingkatkan secara maksimal agar layar tetap mudah dibaca oleh armada saat berada di lapangan terbuka di bawah terik matahari (*Sunlight Readability*).
7. **Role-Tailored Information Density**:
   - *Warga (`WRG-***`)*: Kepadatan informasi sedang (*Moderate Density*), penuh dengan panduan visual dan kartu ilustratif yang ramah pengguna awam.
   - *Driver (`DRV-***`)*: Kepadatan informasi operasional (*Task-Centric Density*), menonjolkan alamat, tombol navigasi cepat, dan input angka yang besar.
   - *Web Admin (`ADM-***`)*: Kepadatan informasi tinggi (*High Density Data Grid*), memanfaatkan tabel kolom ganda untuk pemantauan ratusan transaksi jemputan secara simultan.
8. **Tamper-Proof Visual Clarity (Transparansi Saldo Poin)**: Desain antarmuka secara tegas membedakan antara angka **Estimasi Poin** (Tahap 1 yang diberi label abu-abu/kuning dan keterangan *"Perkiraan"*) dengan angka **Poin Sah / Reward Final** (Tahap 3 yang diberi label hijau terang, ikon centang, dan langsung memutasi saldo hero card).

---

## 3. VISUAL STYLE (*Gaya & Karakter Visual*)

Gaya visual antarmuka dibangun di atas harmoni tata letak kartu (*Card-Based Layout*) dengan aksen kedalaman visual yang halus:
- **Hero Card Container**: Menggunakan efek gradasi halus *Forest Green to Emerald* (`#1E7D32` $\rightarrow$ `#2E7D32`) dengan sudut melengkung 16px (`BorderRadius.circular(16)`) untuk menampilkan kartu saldo utama di dasbor Warga (`WRG-003`).
- **Surface Elevation**: Menggunakan bayangan lembut (*Soft Shading*) dengan opasitas rendah (5% - 8%) pada kartu pesanan agar komponen terasa terangkat (*Elevated*) tanpa terkesan berat atau kaku.
- **Glassmorphism Accent (Subtle)**: Digunakan secara terbatas pada panel pop-up informasi (*Floating Info Badge*) atau *Bottom Sheet Header* untuk memberikan sentuhan transparan modern (*Acrylic Effect*) yang elegan.
- **Visual Hierarchy (Hierarki Visual yang Tegas)**: Ukuran, ketebalan, dan warna font disusun secara ketat untuk memandu mata pengguna dari **Nomor Pesanan (`#ORD-XXXX`)** $\rightarrow$ **Lencana Status Warna-Warni** $\rightarrow$ **Rincian Berat Muatan** $\rightarrow$ **Tombol Aksi**.

---

## 4. COLOR PALETTE (*Design Tokens — Sistem Pewarnaan*)

Seluruh warna dalam aplikasi dikatalogkan sebagai *Design Tokens* berformat Hexadecimal, RGB, dan pemetaan semantik mutlak:

| Token Name | Hex Code | RGB Value | Penggunaan Semantik / Komponen Tujuan |
| :--- | :---: | :---: | :--- |
| **`primary`** | `#1E7D32` | `rgb(30, 125, 50)` | Warna merek utama Bank Sampah Bersinar, *AppBar background*, tombol *Filled Button* utama, ikon aktif *Bottom Navigation Bar*. |
| **`primaryVariant`**| `#166534` | `rgb(22, 101, 52)` | Gradasi gelap hero card, *Active state* pada tombol primary, hover state pada Web Admin. |
| **`secondary`** | `#4CAF50` | `rgb(76, 175, 80)` | Aksen interaktif, ikon sekunder, sorotan progress bar, label poin aktif. |
| **`secondaryContainer`**| `#E8F5E9` | `rgb(232, 245, 233)`| Latar belakang kartu pesanan sukses, chip kategori aktif, latar belakang ikon status `completed`. |
| **`success`** | `#2E7D32` | `rgb(46, 125, 50)` | Lencana status `completed`, teks penambahan saldo poin (`+12,500 Poin`), pesan *Snackbar sukses*. |
| **`warning`** | `#ED6C02` | `rgb(237, 108, 2)` | Lencana status `pending` dan `accepted`, ikon peringatan GPS lemah, *Dialog Confirmation*. |
| **`warningContainer`**| `#FFF3E0` | `rgb(255, 243, 224)`| Latar belakang lencana status `pending`, banner info estimasi berat. |
| **`error`** | `#D32F2F` | `rgb(211, 47, 47)` | Lencana status `cancelled`, tombol hapus, border kolom *TextFormField error*, *Snackbar error*. |
| **`errorContainer`**| `#FFEBEE` | `rgb(255, 235, 238)`| Latar belakang *Error State Card* dan pesan kesalahan validasi input. |
| **`info`** | `#0288D1` | `rgb(2, 136, 209)` | Lencana status `on_the_way` (Tracking Peta), informasi petunjuk penjemputan. |
| **`infoContainer`**| `#E1F5FE` | `rgb(225, 245, 254)`| Latar belakang lencana `on_the_way` dan panel panduan rute. |
| **`backgroundLight`**| `#F8FAFC` | `rgb(248, 250, 252)`| Latar belakang utama halaman (*Scaffold background*) pada kondisi *Light Mode*. |
| **`surfaceLight`**| `#FFFFFF` | `rgb(255, 255, 255)`| Latar belakang kartu (*Card surface*), modal dialog, *Bottom Sheet*, dan form kontainer. |
| **`borderLight`** | `#E2E8F0` | `rgb(226, 232, 240)`| Garis pembatas (*Divider*), pinggiran *Outlined Button*, dan border kolom input yang belum fokus. |
| **`textPrimary`** | `#0F172A` | `rgb(15, 23, 42)` | Teks judul utama (*Headings*), nama nasabah, nomor pesanan, teks input aktif (*High Contrast*). |
| **`textSecondary`**| `#64748B` | `rgb(100, 116, 139)`| Teks keterangan (*Subtitle/Caption*), waktu pesanan, spesifikasi alamat, label form. |
| **`textDisabled`** | `#94A3B8` | `rgb(148, 163, 184)`| Teks pada tombol yang dinonaktifkan (*Disabled Button*) dan placeholder *TextField*. |
| **`textInverse`** | `#FFFFFF` | `rgb(255, 255, 255)`| Teks di atas latar belakang hijau (*Primary/Hero Card/Button Teks*). |
| **`backgroundDark`** *(Optional)*| `#0F172A` | `rgb(15, 23, 42)` | Latar belakang *Scaffold* pada mode gelap (*Dark Mode*). |
| **`surfaceDark`** *(Optional)*| `#1E293B` | `rgb(30, 41, 59)` | Latar belakang kartu (*Card surface*) pada mode gelap (*Dark Mode*). |

---

## 5. TYPOGRAPHY (*Sistem Tipografi & Skala Font*)

Sistem tipografi mengadopsi font *sans-serif* modern bergaya geometris humanis yang sangat tajam dan mudah dibaca pada layar resolusi tinggi maupun rendah: **Plus Jakarta Sans** (atau alternatif **Inter** / **Outfit** dari Google Fonts).

Skala font ditetapkan berdasarkan standar penamaan *Material 3 Typography Role*:

| Typography Role | Font Size | Line Height | Font Weight | Letter Spacing | Penggunaan Spesifik dalam Aplikasi |
| :--- | :---: | :---: | :---: | :---: | :--- |
| **`Display Large`** | `32px` | `40px` | `Bold (700)` | `-0.5px` | Angka Saldo Poin pada Hero Card (`HomeScreen`), Poin Besar pada pop-up sukses. |
| **`Headline Large`**| `24px` | `32px` | `Bold (700)` | `-0.25px`| Judul halaman utama (*Screen Title*), Judul *Modal Timbang Akhir (`ADM-004`)*. |
| **`Title Large`** | `20px` | `28px` | `SemiBold (600)`| `0px` | Judul *AppBar*, judul sesi panduan Intro (*Splash Intro `WRG-001`*). |
| **`Title Medium`** | `16px` | `24px` | `SemiBold (600)`| `0.15px` | Judul kartu pesanan (`#ORD-XXXX`), nama nasabah di tabel Admin, label *Section Header*. |
| **`Body Large`** | `16px` | `24px` | `Regular (400)`| `0.5px` | Teks paragraf artikel edukasi (`WRG-008`), rincian alamat lengkap warga. |
| **`Body Medium`** | `14px` | `20px` | `Regular (400)`| `0.25px` | Teks deskripsi item sampah, catatan lapangan driver, keterangan form input. |
| **`Body Small`** | `12px` | `16px` | `Regular (400)`| `0.4px` | Keterangan waktu pesanan (`10 Jul 2026, 09:30`), teks legalitas bawah halaman. |
| **`Label Large`** | `14px` | `20px` | `SemiBold (600)`| `0.1px` | Teks pada tombol utama (*Primary Button CTA*), label tab filter status pesanan. |
| **`Label Medium`** | `12px` | `16px` | `SemiBold (600)`| `0.5px` | Teks pada Lencana Status (*Status Badge Pill*), label *Bottom Navigation Bar*. |
| **`Label Small`** | `11px` | `14px` | `Medium (500)` | `0.5px` | Tag kategori kecil, indikator langkah pada *Timeline Stepper*. |

---

## 6. SPACING SYSTEM (*Grid Spacing 8pt & Micro Spacing 4pt*)

Untuk menjaga keselarasan proporsi visual (*Visual Rhythm*), seluruh jarak margin, padding, dan celah antar komponen (*gap*) dikunci dalam kelipatan grid **8pt** dengan dukungan micro-spacing **4pt**:

```text
[Scale: 4px]  -> xs  : Celah halus antar ikon kecil dengan label teks di sekitarnya.
[Scale: 8px]  -> sm  : Padding internal lencana status (*Badge Pill*) & jarak antar chip kategori.
[Scale: 12px] -> md-sm: Padding internal komponen kartu compact atau *ListTile item*.
[Scale: 16px] -> md  : STANDARD MARGIN: Padding horizontal layar utama & jarak antar kartu pesanan.
[Scale: 24px] -> lg  : Jarak pemisah antar-sekresi besar (*Section Gap*) & padding form modal dialog.
[Scale: 32px] -> xl  : Jarak dari batas bawah form input menuju tombol submit utama di layar mobile.
[Scale: 48px] -> xxl : Padding atas/bawah pada halaman kosong (*Empty State*) & ilustrasi utama.
```

---

## 7. BORDER RADIUS (*Shape Tokens — Sudut Melengkung*)

Kelengkungan sudut antarmuka (*Shape Geometry*) diatur dalam 6 (enam) token presisi untuk memberikan karakter visual yang bersahabat namun tetap berwibawa:

| Shape Token | Radius Spec | Komponen Target Penerapan |
| :--- | :---: | :--- |
| **`radiusXS`** | `4px` | Lencana status mini (*Mini Badge Pill*), tooltip keterangan, kotak centang (*Checkbox*). |
| **`radiusSM`** | `8px` | Tombol kecil (*Mini Button*), input form (*TextFormField border*), kartu item tabel rincian. |
| **`radiusMD`** | `12px` | **STANDARD CARD RADIUS**: Kartu riwayat pesanan (`WRG-005`), kartu tugas driver (`DRV-002`). |
| **`radiusLG`** | `16px` | **HERO CONTAINER & SHEET**: Hero card saldo poin (`HomeScreen`), sudut atas *Bottom Sheet*. |
| **`radiusXL`** | `24px` | Tombol utama full-width (`ElevatedButton`), *Floating Action Button (FAB)*, Chip filter status. |
| **`radiusFull`**| `999px` | Foto profil avatar (*Circular Avatar*), lingkaran indikator *Timeline Stepper*, ikon indikator. |

---

## 8. ELEVATION & SHADOW SYSTEM (*Material 3 Shadow Tokens*)

Bayangan kartu dihitung untuk memberikan persepsi kedalaman (*Z-Axis Depth*) yang lembut, tidak kotor, dan presisi sesuai spesifikasi Material 3:

```css
/* Level 0: Flat / Surface (Background Scaffold, Divider, Outlined Card) */
--elevation-0: none;

/* Level 1: Subtle Shadow (Standard Order Cards, List Items, Table Rows) */
--elevation-1: 0px 2px 4px rgba(15, 23, 42, 0.05);

/* Level 2: Medium Shadow (Hero Card, Hovered Card, Bottom Navigation Bar) */
--elevation-2: 0px 4px 8px rgba(15, 23, 42, 0.08), 0px 1px 3px rgba(15, 23, 42, 0.04);

/* Level 3: High Shadow (Modal Dialog, Bottom Sheet Container, Floating Action Button) */
--elevation-3: 0px 8px 16px rgba(15, 23, 42, 0.12), 0px 2px 4px rgba(15, 23, 42, 0.06);

/* Level 4: Focus / Alert Overlay (Warehouse Final Weighing Modal ADM-004) */
--elevation-4: 0px 16px 32px rgba(15, 23, 42, 0.18), 0px 4px 8px rgba(15, 23, 42, 0.08);
```

---

## 9. ICON STYLE (*Panduan & Pemetaan Ikon*)

Sistem ikon menggunakan standar resmi **Material Symbols Outlined / Rounded (24px)** dengan ketebalan garis (*Stroke Width*) konsisten **2.0px**. Ikon harus ramah, mudah dikenali sekilas, dan konsisten di seluruh aplikasi:

- `recycling` / `delete_outline` : Jenis Sampah / Katalog Daur Ulang (`ADM-005` & `WRG-004`).
- `local_shipping` / `directions_car` : Armada Driver / Pemantauan Peta Rute (`WRG-007` & `DRV-002`).
- `scale` : Penimbangan Lapangan Driver (`DRV-004`) & Timbang Akhir Gudang (`ADM-004`).
- `qr_code_scanner` / `camera_alt` : Pemindaian AI Kamera (`WRG-008`) & Foto Bukti Angkut Driver (`DRV-004`).
- `payments` / `monetization_on` : Saldo Poin / Reward Sah Masuk (`WRG-003` & `WRG-009`).
- `location_on` / `map` : Titik Koordinat Alamat Penjemputan (`WRG-004` & `DRV-003`).
- `check_circle` : Status Selesai (`completed`) & Indikator ACID Sukses.
- `schedule` / `access_time` : Status Menunggu (`pending`) & Sesi Jadwal Waktu.

---

## 10. ILLUSTRATION STYLE (*Gaya Ilustrasi Vektor*)

Ilustrasi yang digunakan di dalam aplikasi bertipe **Flat Vector Illustrations with Subtle Green Gradients**. Ilustrasi ini tidak boleh mendominasi layar, melainkan menjadi penjelas yang menyenangkan dan menenangkan:
- **Slide Onboarding (`WRG-001`)**: 3 Ilustrasi vektor yang menggambarkan warga memilah sampah di rumah, armada truk hijau datang menjemput, dan penimbangan akurat di Bank Sampah menghasilkan saldo poin.
- **Empty State Order (`WRG-005` / `DRV-002`)**: Ilustrasi tong sampah bersih dengan dedaunan hijau melayang, disertai pesan bahwa belum ada tugas atau riwayat jemputan.
- **Success State Dialog (`WRG-004` / `ADM-004`)**: Ilustrasi lencana emas atau pohon hijau bertumbuh yang menandakan pesanan berhasil dikirim atau poin sukses ditambahkan.

---

## 11. ANIMATION GUIDELINES (*Micro-interactions & Transitions*)

Seluruh transisi visual harus cepat, mulus, dan tidak mengganggu performa perangkat (60 FPS minimum pada Flutter mobile):

| Jenis Animasi / Transisi | Durasi (*Duration*) | Kurva (*Animation Curve*) | Deskripsi Perilaku Visual |
| :--- | :---: | :---: | :--- |
| **Button Tap / Chip Toggle** | `150ms - 200ms` | `Curves.easeInOut` | Efek *Ripple* Material 3 berpadu dengan perubahan skala kecil (`scale: 0.98` $\rightarrow$ `1.0`). |
| **Page Push Route (Forward)** | `300ms` | `Curves.fastOutSlowIn` | Halaman baru bergeser dari kanan ke kiri (*Slide Right-to-Left*) disertai *subtle fade-in*. |
| **Modal / Dialog Popup** | `250ms` | `Curves.easeOutBack` | Dialog muncul di tengah layar dengan efek *slight zoom-in* (`scale: 0.85` $\rightarrow$ `1.0`) & latar belakang memudar gelap (*dim 50%*). |
| **Bottom Sheet Slide-Up** | `350ms` | `Curves.easeOutCubic` | Panel melayang meluncur dari dasar layar ke atas secara halus tanpa patahan (*Jank-free*). |
| **Shimmer Skeleton Loading** | `1200ms (Loop)` | `Curves.linear` | Gelombang kilau perak/krem bergeser secara horizontal dari kiri ke kanan pada kerangka penampung kartu (*Loading Placeholder*). |

---

## 12. STANDARD UI COMPONENTS (*Anatomi, State & Spesifikasi 16 Komponen*)

Berikut adalah spesifikasi teknis dan anatomi untuk 16 komponen antarmuka standar yang harus dibangun secara konsisten:

### 1. Button (Tombol Aksi)
- **Filled Primary Button**: Latar `#1E7D32`, teks `#FFFFFF` (`Label Large`), tinggi `48px`, `radiusSM (8px)` atau `radiusXL (24px)`. Digunakan untuk aksi utama seperti *"Ajukan Penjemputan"*, *"Konfirmasi Angkut"*, *"Selesaikan Order"*.
  - *Disabled State*: Latar `#E2E8F0`, teks `#94A3B8`, tanpa shadow (`elevation-0`).
- **Outlined Secondary Button**: Border `1.5px solid #1E7D32`, latar `transparent`, teks `#1E7D32`. Digunakan untuk aksi pendukung seperti *"Batalkan Jemputan"*, *"Buka Google Maps"*.
- **Text Button**: Tanpa border dan latar, teks `#1E7D32`. Digunakan untuk *"Lihat Semua"*, *"Lewati"*.

### 2. Card (Kartu Kontainer)
- **Hero Card Saldo (`HomeScreen`)**: Gradasi `#1E7D32` $\rightarrow$ `#2E7D32`, padding internal `20px`, `radiusLG (16px)`, shadow `elevation-2`. Menampilkan teks putih *Display Large*.
- **Order Summary Card (`OrdersScreen`)**: Latar `#FFFFFF`, border `1px solid #E2E8F0`, padding `16px`, `radiusMD (12px)`, shadow `elevation-1`. Terdiri dari Header (ID & Status Badge), Body (Alamat & Item), dan Footer (Waktu & CTA).

### 3. Bottom Navigation Bar (4 Tabs Mobile Shell)
- Tinggi `68px`, latar `#FFFFFF`, border atas `1px solid #E2E8F0`, shadow `elevation-2`.
- 4 Tab Warga (`WRG-003` Shell): `Beranda (home)`, `Pesanan (local_shipping)`, `Notifikasi (notifications)`, `Profil (person)`.
- *Active Tab State*: Ikon diberi pil latar `#E8F5E9` (tinggi `32px`, lebar `64px`) dengan ikon berwarna `#1E7D32`. *Inactive Tab*: Ikon abu-abu `#64748B`.

### 4. AppBar (Top Navigation Bar)
- Tinggi `56px`, latar `#FFFFFF` (atau `#1E7D32` khusus pada layar tracking/hero), teks judul *Title Large* `#0F172A`. Dilengkapi tombol Back Arrow (`Navigator.pop`) di sebelah kiri dan tombol aksi pendukung (seperti Telepon/WA atau Refresh) di sebelah kanan.

### 5. Search Bar & Filter Chips
- **Search Bar**: Tinggi `44px`, latar `#F8FAFC`, border `1px solid #E2E8F0`, `radiusXL (24px)`, ikon kaca pembesar di kiri, teks placeholder `#94A3B8`.
- **Filter Chips (Status Tabs)**: Chip berderet horizontal yang dapat digeser (*Horizontal Scrollable*). *Active Chip*: Latar `#1E7D32`, teks `#FFFFFF`. *Inactive Chip*: Latar `#F8FAFC`, border `#E2E8F0`, teks `#64748B`.

### 6. Timeline Stepper (6 Status Progression)
- Komponen vertikal/horizontal di layar `WRG-006` yang memvisualisasikan perjalanan pesanan melalui 6 lingkaran status.
- *Completed Step*: Lingkaran hijau `#2E7D32` dengan ikon centang putih, dihubungkan oleh garis hijau solid `2px`.
- *Active/Current Step*: Lingkaran kuning/biru bercahaya (*Pulse effect*) dengan ikon status aktif.
- *Future/Pending Step*: Lingkaran abu-abu `#E2E8F0` dengan angka urutan, dihubungkan oleh garis putus-putus (*dashed line*) `#CBD5E1`.

### 7. Status Badge (Lencana Status Pill)
- Komponen *Badge Pill* berukuran ringkas (`height: 24px`, `padding: 2px 10px`, `radiusXL`). Pewarnaan mengikuti secara ketat **Status Color Mapping pada Bab 13**.

### 8. Dialog (Alert & Confirmation Modal)
- Lebar maksimal `340px` (Mobile) / `480px` (Web), latar `#FFFFFF`, `radiusLG (16px)`, padding internal `24px`, shadow `elevation-3`.
- Terdiri dari Ikon Ilustratif di atas tengah (`48px`), Judul *Title Large*, Deskripsi *Body Medium*, serta 2 tombol aksi sejajar di bagian bawah (*Batal* vs *Konfirmasi Action*).

### 9. Bottom Sheet (Modal Slide-Up)
- Panel melayang dari bawah dengan sudut atas melengkung `radiusLG (16px)` di kedua sisi, disertai indikator pegangan (*Drag Handle Pill* `lebar 40px`, `tinggi 4px`, `#CBD5E1`) di tengah atas.

### 10. TextField / TextFormField (Input Form)
- Tinggi kontainer `52px`, latar `#FFFFFF`, border `1px solid #E2E8F0`, `radiusSM (8px)`, padding horizontal `14px`. Dilengkapi *Prefix Icon* hijau/abu-abu di kiri.
- *Focus State*: Border berubah menjadi `2px solid #1E7D32`. *Error State*: Border merah `2px solid #D32F2F`, disertai teks pesan kesalahan merah di bawah kotak input (`Label Small`).

### 11. Dropdown / Form Select
- Mengadopsi struktur tampilan *TextField* standar namun dilengkapi ikon anak panah ke bawah (*Keyboard Arrow Down*) di sebelah kanan. Menampilkan *Bottom Sheet* saat ditekan pada mobile untuk kemudahan pemilihan item.

### 12. Date Picker & Time Session Selector
- **Session Selector Grid**: Pilihan jadwal ditampilkan dalam bentuk grid kartu tombol (`Pagi: 08.00–11.00`, `Siang: 13.00–16.00`). Kartu yang dipilih berubah warna berborder hijau tebal dengan sudut `radiusSM`.

### 13. Loading Indicator (Spinner & Shimmer Skeleton)
- **Shimmer Skeleton**: Digunakan untuk memuat daftar kartu pesanan (`OrdersScreen`) dan tabel Web Admin.
- **Spinner**: *CircularProgressIndicator* berwarna hijau `#1E7D32` dengan ketebalan garis `3.0px` pada saat mengirim data form (*Submit Loading State*).

### 14. Empty State Card
- Kontainer rata tengah (`CrossAxisAlignment.center`) dengan padding vertikal `48px`. Menampung ilustrasi vektor `160px x 160px`, judul pesan *Title Medium* (`#0F172A`), subjudul *Body Medium* (`#64748B`), dan tombol CTA primary (misal: *"Buat Jemputan Sekarang"*).

### 15. Error State Card (Network & API Error)
- Kontainer berlatar `#FFEBEE` dengan border `1px solid #EF5350`, `radiusMD`. Menampilkan ikon peringatan merah `error_outline (32px)`, pesan kegagalan koneksi/API, dan tombol CTA kecil *"Coba Lagi (Retry)"*.

### 16. Snackbar / Toast Notification
- Balikan cepat yang muncul melayang di dasar layar selama `3000ms`.
- *Success Snackbar*: Latar `#2E7D32`, teks `#FFFFFF`, ikon centang.
- *Error Snackbar*: Latar `#D32F2F`, teks `#FFFFFF`, ikon peringatan.

---

## 13. STATUS COLOR MAPPING (*Lencana 6 Status & Logika Pewarnaan Mutlak*)

Matriks di bawah ini adalah acuan baku pewarnaan lencana status (*Status Badge*) untuk seluruh kartu, tabel, dan lini masa di ketiga aplikasi:

| Status Code | Label Bahasa Indonesia Resmi | Warna Teks (`Color`) | Latar Kontainer (`Bg`) | Ikon Pendamping | Logika & Kondisi Berlaku pada Antarmuka |
| :---: | :--- | :---: | :---: | :---: | :--- |
| **`pending`** | **Menunggu Driver** | `#E65100` (*Dark Orange*) | `#FFF3E0` (*Orange Light*) | `schedule` | Pesanan baru diajukan oleh Warga (`WRG-004`). Angka `estimasi_berat_kg` Tahap 1 berlaku. Belum ada driver yang mengikat tugas. |
| **`accepted`** | **Driver Ditugaskan** | `#0277BD` (*Dark Blue*) | `#E1F5FE` (*Blue Light*) | `assignment_ind` | Driver menekan *"Terima Tugas"* di `DRV-002` (atau di-assign Admin). Driver bersiap menuju rumah warga. |
| **`on_the_way`**| **Armada Menuju Lokasi** | `#1565C0` (*Primary Blue*)| `#E3F2FD` (*Blue Light*) | `local_shipping` | Driver menekan *"Mulai Menuju Lokasi"*. **Peta Live Tracking (`WRG-007`) AKTIF & TERBUKA bagi Warga**. |
| **`picked_up`** | **Sampah Diangkut** | `#6A1B9A` (*Deep Purple*)| `#F3E5F5` (*Purple Light*)| `scale` | Driver selesai menimbang di depan rumah, menginput `berat_driver_kg` Tahap 2, & mengangkut sampah ke truk (`DRV-004`). |
| **`validating`**| **Validasi Gudang** | `#4527A0` (*Indigo Violet*)| `#EDE7F6` (*Indigo Light*)| `verified` | Driver menyerahkan muatan di `DRV-005`. Tugas armada tuntas & hilang dari `DRV-002`. Menunggu inspeksi gudang Web Admin (`ADM-003`). |
| **`completed`** | **Selesai (Poin Sah)** | `#1B5E20` (*Deep Green*) | `#E8F5E9` (*Green Light*) | `check_circle` | Petugas gudang menginput `berat_aktual_kg` Tahap 3 di `ADM-004` & mengeksekusi transaksi ACID. **Saldo Poin Sah RESMI BERTAMBAH di antarmuka Warga**. |
| **`cancelled`** | **Dibatalkan** | `#C62828` (*Dark Red*) | `#FFEBEE` (*Red Light*) | `cancel` | Pesanan dibatalkan oleh Warga atau Admin sebelum status mencapai `on_the_way`. |

---

## 14. SCREEN STYLE MAPPING (*Spesifikasi Visual untuk 17 Layar/Modul*)

Berikut adalah pemetaan tata letak visual, penekanan CTA, dan penanganan state untuk ke-17 modul/layar sistem sesuai `SCREEN_CATALOG.md`:

### A. Aplikasi Mobile Warga (`WRG-001` hingga `WRG-010`)

| Screen ID | Screen Name | Struktur Tata Letak (*Layout Structure*) | Komponen Visual Utama & Warna Dominan | Penekanan Tombol Aksi CTA (*Primary Action*) | Penanganan Empty / Loading / Error State |
| :---: | :--- | :--- | :--- | :--- | :--- |
| **`WRG-001`** | Splash & Intro Screen | Fullscreen ilustrasi vektor dengan latar putih bersih `#FFFFFF` & logo hijau di tengah. | *PageView Slide Carousel*, ilustrasi flat eco-friendly, indikator dot hijau `#1E7D32`. | Tombol *Filled Primary* **"Mulai Sekarang"** & Tombol *Text* **"Lewati"**. | *Loading State*: Spinner hijau halus di bawah logo saat mengecek `api_token`. |
| **`WRG-002`** | Login & Register Screen | *Single Column Form* rata tengah dengan logo Bank Sampah di header atas. | *TextFormField* berborder `#E2E8F0` dengan prefix ikon abu-abu, judul *Headline Large*. | Tombol *Filled Primary* full-width `radiusXL` **"Masuk ke Akun"** / **"Daftar Sekarang"**. | *Error State*: Teks pesan validasi merah `#D32F2F` di bawah kolom & *Snackbar Error*. |
| **`WRG-003`** | Home Screen (Dasbor Utama)| *Scrollable Vertical Layout* dengan Hero Card hijau di atas, diikuti Grid Aksi & Banner. | **Hero Card Saldo Poin** (`#1E7D32` $\rightarrow$ `#2E7D32`), *Quick Action Grid Cards*, *Timeline Preview*. | Kartu aksi cepat **"Buat Jemputan (`WRG-004`)"** berwarna hijau tajam & ikon besar. | *Loading State*: *Shimmer Skeleton* pada area Hero Card & daftar riwayat pesanan. |
| **`WRG-004`** | Pickup Request Screen| *Form Section List*: 1. Alamat, 2. Jadwal Sesi, 3. Dynamic Item Table, 4. Kalkulator Poin. | *Card Containers*, Dropdown Kategori, *Number TextField* `estimasi_berat_kg`, *Info Banner* kuning. | Tombol *Filled Primary* di dasar layar **"Ajukan Penjemputan Sekarang"**. | *Error State*: Peringatan form jika berat $0$ kg. *Dialog Konfirmasi* sebelum submit API. |
| **`WRG-005`** | Orders Screen (Tab Berjalan)| *Top Filter Chips Bar* (Semua/Berjalan/Selesai) di atas *Vertical Card ListView*. | *Horizontal Scrollable Filter Chips*, *Order Summary Cards* dengan *Status Badge Pill*. | Klik seluruh area kartu untuk membuka detail **`OrderDetailScreen (WRG-006)`**. | *Empty State*: Ilustrasi tong sampah bersih dengan pesan *"Belum Ada Jemputan"*. |
| **`WRG-006`** | Order Detail Screen | *Sectioned Card Layout*: Header Status, *Timeline Stepper*, Tabel Audit 3 Tahap, & Kontak. | **Timeline Stepper 6 Status**, Tabel Audit (*Estimasi vs Driver vs Aktual*), *Driver Contact Box*. | Tombol Biru Bersinar **"Lihat Peta Realtime & ETA"** (Aktif HANYA saat `on_the_way`). | *Loading State*: *Shimmer loading* saat memuat rincian item & timeline dari server. |
| **`WRG-007`** | Driver Tracking Screen| *Fullscreen Map View (`flutter_map`)* dengan *Draggable Bottom Sheet* di bagian bawah. | Peta interaktif dengan polyline rute hijau, penanda ikon truk bergerak, *Info Bottom Sheet*. | Tombol Hijau WhatsApp **"Hubungi Driver via WA"** di dalam panel *Bottom Sheet*. | *Error State*: Banner peringatan kuning jika sinyal GPS armada terputus $> 3$ menit. |
| **`WRG-008`** | AI Scan & Education Screen| *Camera Viewfinder Fullscreen* dengan tombol shutter circular besar & panel edukasi di bawah. | *Viewfinder Frame border hijau*, tombol shutter `radiusFull`, *BottomSheet Hasil Klasifikasi AI*. | Tombol utama *"Ambil Foto Sampah"* & Tombol *"Simpan Estimasi ke Form Jemputan"*. | *Error State*: Pesan *"Kamera Tidak Terdeteksi"* atau *"Sampah Tidak Dikenali ML"*. |
| **`WRG-009`** | Alerts & Reward Screen | *Tabbed ListView*: Tab 1 Daftar Notifikasi, Tab 2 Riwayat Peminjaman & Poin Sah Masuk. | *Notification Card Items* dengan ikon lonceng/poin dan *timestamp* `Body Small`. | Klik item notifikasi mengarahkan langsung ke detail pesanan (`WRG-006`). | *Empty State*: Ilustrasi lonceng hening *"Belum Ada Notifikasi Masuk"*. |
| **`WRG-010`** | Profile Screen | *Header Avatar Column* di atas daftar menu pengaturan (*ListTile with Chevron Arrow*). | *Circular Avatar photo*, nama warga *Title Large*, *Outlined Card* data alamat default. | Tombol Outlined Merah `#D32F2F` **"Keluar dari Akun (Logout)"** & *Dialog Konfirmasi*. | *Loading State*: *Shimmer avatar* & teks saat memuat data profil dari `warga_api.php`. |

---

### B. Aplikasi Mobile Driver (`DRV-001` hingga `DRV-007`)

| Screen ID | Screen Name | Struktur Tata Letak (*Layout Structure*) | Komponen Visual Utama & Warna Dominan | Penekanan Tombol Aksi CTA (*Primary Action*) | Penanganan Empty / Loading / Error State |
| :---: | :--- | :--- | :--- | :--- | :--- |
| **`DRV-001`** | Driver Auth Screens | *High-Contrast Single Column Form* dengan aksen warna hijau gelap & kuning operasional. | *TextFormField* tebal, label jelas, judul **"Portal Armada Penjemput Resmi"**. | Tombol *Filled Primary* hijau gelap **"Masuk sebagai Armada"**. | *Error State*: *Snackbar Merah* jika akun yang login bukan `level = 'driver'`. |
| **`DRV-002`** | Dashboard Screen | *Header Vehicle Toggle Bar* (Online/Ready) di atas 2 Tab Utama: *Tugas Pending* & *Tugas Saya*. | *Status Toggle Switch*, *Task Card Items* berborder tebal dengan alamat warga *High Contrast*. | Tombol **"Terima Tugas (`accepted`)"** berwarna hijau tajam pada setiap kartu Tab Pending. | *Empty State*: Pesan *"Belum Ada Order Baru di Wilayah Anda"* dengan ilustrasi truk istirahat. |
| **`DRV-003`** | Pickup Detail Screen| *Structured Operational Layout*: Box Kontak Nasabah, Peta Alamat, & Rincian Item Estimasi. | Tombol Call & WA langsung (`url_launcher`), rincian alamat besar, tombol navigasi Maps. | Tombol Biru **"Mulai Menuju Lokasi (`on_the_way`)"** $\rightarrow$ Tombol Hijau **"Tiba di Lokasi"**. | *Error State*: Peringatan jika GPS driver mati saat menekan tombol *"Mulai Menuju Lokasi"*. |
| **`DRV-004`** | Pickup Verification | *Field Weighing Form*: Tabel item dengan kolom input **`berat_driver_kg` (Tahap 2)** yang besar. | *High-Contrast Number Input Box*, tombol kamera pengambilan foto bukti, kolom catatan lapangan. | Tombol Utama Hijau Besar **"Konfirmasi Angkut Sampah (`picked_up`)"**. | *Error State*: *Dialog Alert Merah* jika tombol angkut ditekan namun angka berat masih `0` kg. |
| **`DRV-005`** | Warehouse Handover | *Summary Box Layout*: Ringkasan total muatan lapangan & spesifikasi gudang tujuan serah terima. | *Handover Summary Card*, *Checkbox Konfirmasi* dengan ukuran *touch target* besar (`48px`). | Tombol Utama Ungu/Hijau **"Serahkan Muatan ke Gudang (`validating`)"**. | Sesaat setelah submit sukses, order **hilang seketika** dari dasbor driver (`DRV-002`). |
| **`DRV-006`** | Schedule & History | *Filterable Date ListView*: Daftar jadwal tugas mendatang & riwayat penjemputan selesai. | *History Card* dengan label status `completed` (tanpa rincian poin warga demi isolasi privasi). | *Read-Only View*: Klik kartu hanya untuk melihat rekam jejak rute dan waktu angkut lapangan. | *Empty State*: *"Belum Ada Riwayat Penjemputan Selesai pada Periode Ini"*. |
| **`DRV-007`** | Alerts & Profile | *Driver & Truck Info Sheet*: Spesifikasi armada (Plat Nomor, Kapasitas KG, Tipe Kendaraan). | *Vehicle Specification Card*, *ListTile pengaturan*, tombol informasi darurat armada. | Tombol Merah Outlined **"Keluar dari Sesi Armada (Logout)"**. | *Loading State*: *Shimmer card* saat mengambil spesifikasi truk dari server. |

---

### C. Portal Web Admin (`ADM-001` hingga `ADM-007`)

| Screen ID | Screen Name | Struktur Tata Letak (*Layout Structure*) | Komponen Visual Utama & Warna Dominan | Penekanan Tombol Aksi CTA (*Primary Action*) | Penanganan Empty / Loading / Error State |
| :---: | :--- | :--- | :--- | :--- | :--- |
| **`ADM-001`** | Admin Login Page | *Centred Login Card* pada layar web peramban dengan latar belakang gradasi hijau/abu-abu. | *Form Card Elevation-3*, kolom input Username & Password, logo Bank Sampah Bersinar. | Tombol *Filled Primary* hijau zamrud **"Masuk ke Portal Admin"**. | *Error State*: *Alert Box Bootstrap Red (`alert-danger`)* di atas form jika kredensial salah. |
| **`ADM-002`** | Executive Dashboard | *12-Column Grid Web Layout*: Sidebar Kiri (`260px`), Navbar Atas, 4 Stat Boxes, & Grafik Tren. | *4 Stat Cards* (Warga, Driver, Order Aktif, Poin Sah), *Chart.js Canvas*, *Recent Orders Table*. | Link *"Lihat Semua Jemputan"* yang mengarah ke tabel `ADM-003 (orders/data)`. | *Loading State*: *Shimmer placeholder* pada area grafik dan kotak statistik saat kueri SQL berjalan. |
| **`ADM-003`** | Orders Management Table| *High Density Data Grid*: *Top Filter Status Tabs* (6 Status) di atas tabel *DataTables jQuery*. | *DataTables* bergaris horizontal dengan *Status Badge Pill*, Dropdown *Assign Driver* manual. | Tombol Hijau Tajam **"Validasi Timbang Akhir"** HANYA pada baris berstatus `validating` / `picked_up`.| *Empty State*: Baris kosong bertuliskan *"Tidak ada data penjemputan dengan status ini"*. |
| **`ADM-004`** | Warehouse Final Modal| *Large Bootstrap Modal (`verify_modal.php`)* melayang di tengah layar dengan tabel perbandingan. | **Tabel Audit 3 Kolom Sanding** (*Estimasi vs Driver vs Aktual*), **Kalkulator Real-time JS Poin Sah**. | Tombol Eksekusi ACID Hijau **"Selesaikan Order & Salurkan Poin (`completed`)"**. | *Error State (ACID Rollback)*: *Alert Merah* muncul di dalam modal jika transaksi MySQL gagal/dirollback. |
| **`ADM-005`** | Waste Catalog Management| *Table + Modal CRUD Layout*: Tabel katalog jenis sampah (`jenis_sampah/data`) bersertakan harga/kg. | Tabel kolom `Nama, Satuan, Harga Poin/KG`, tombol *Action Icons (Edit / Hapus)*. | Tombol Hijau *"+ Tambah Jenis Sampah Baru"* di kanan atas tabel. | *Validation Error*: Peringatan form modal jika harga poin/kg diisi angka negatif atau `0`. |
| **`ADM-006`** | Users & Drivers Data| *Tabbed Table View*: Tab 1 Manajemen Nasabah Warga, Tab 2 Manajemen Armada Driver & Truk. | Tabel data nasabah beserta saldo poin aktual, tabel data armada beserta spesifikasi kendaraan. | Tombol *"+ Registrasi Driver / Armada Baru"* & tombol verifikasi akun nasabah. | *Empty State*: *"Belum ada data warga/driver yang terdaftar di dalam sistem"*. |
| **`ADM-007`** | Education & Reports | *Split Layout*: 1. CRUD Artikel Edukasi (`edukasi/data`), 2. Filter Laporan Penjemputan (`laporan/data`). | Form filter tanggal (*Date Range Picker*), tabel rekapitulasi, tombol cetak dokumen resmi. | Tombol Export **"Cetak Laporan Resmi (PDF)"** & **"Unduh Rekap (Excel)"**. | *Loading State*: Spinner pada tombol export saat memanaskan generator dokumen PDF/Excel. |

---

## 15. RESPONSIVE RULES (*Aturan Responsivitas Grid & Tata Letak*)

Untuk memastikan kesesuaian tampilan di berbagai ukuran layar dan perangkat (*Multi-Screen Adaptability*), sistem menerapkan 3 (tiga) *Breakpoint Grid Rules* mutlak:

```text
[Mobile Grid : < 600px]  -> 4 Columns  | Margin: 16px | Gutter: 12px | Full-Width Cards & Forms
[Tablet Grid : 600-1024px]-> 8 Columns  | Margin: 24px | Gutter: 16px | 2-Column Card Grid (Orders / Dashboard)
[Web Grid    : > 1024px] -> 12 Columns | Sidebar: 260px Fixed | Fluid Content Area | Horizontal Scrolling Tables
```

1. **Aplikasi Mobile Warga & Driver (`< 600px`)**:
   - Seluruh form input, tombol CTA, dan kartu pesanan membentang penuh `100% width` dari batas margin kiri ke kanan (`16px padding`).
   - Pada layar lipat atau tablet mini (`600px - 1024px`), menu dasbor dan kartu riwayat pesanan otomatis beralih menjadi grid 2 kolom (`GridView.builder` dengan `crossAxisCount: 2`) untuk memanfaatkan ruang layar yang lebih lebar.
2. **Portal Web Admin (`> 1024px`)**:
   - Tata letak menggunakan *Sidebar Kiri Tetap (`width: 260px`)* yang tidak ikut bergeser saat konten tengah digulir ke bawah.
   - Tabel *DataTables (`ADM-003`)* dibungkus dalam kontainer `overflow-x: auto` sehingga jika kolom tabel bertambah lebar pada layar kecil, tabel dapat digeser secara horizontal tanpa merusak tata letak keseluruhan (*No Layout Breakage*).

---

## 16. ACCESSIBILITY (*Standar Aksesibilitas & a11y Inclusive Design*)

Sistem Informasi Bank Sampah Bersinar dirancang agar dapat diakses oleh seluruh lapisan masyarakat, termasuk pengguna lanjut usia maupun yang memiliki keterbatasan penglihatan (*Inclusive Design*):

1. **Contrast Ratio (Standar WCAG 2.1 AA & AAA)**:
   - Teks biasa (*Body Text*) di atas latar belakang putih/gelap memiliki rasio kontras minimal **`4.5:1`**.
   - Teks judul besar (*Headline*) dan ikon pada tombol utama memiliki rasio kontras minimal **`3.0:1`**.
   - Khusus pada aplikasi **Mobile Driver (`DRV-***`)**, kombinasi warna latar kartu `#FFFFFF` dengan teks hitam `#0F172A` dan tombol hijau gelap `#1E7D32` mencapai rasio kontras **`7.2:1 (AAA)`**, menjamin keterbacaan sempurna di bawah terik matahari (*Sunlight Readability*).
2. **Minimum Touch Target Size**:
   - Seluruh tombol interaktif, ikon *AppBar*, *Checkbox*, dan item *Bottom Navigation Bar* memiliki area sentuh minimal **`48px x 48px`** (sesuai pedoman *Material 3 & iOS Human Interface Guidelines*) untuk mencegah kesalahan tekan oleh jari pengguna.
3. **Dynamic Type & Text Scaling Resilience**:
   - Seluruh widget teks pada Flutter mematuhi faktor pembesaran teks sistem operasi (`MediaQuery.textScaleFactorOf(context)`). Desain tata letak melarang penggunaan *Fixed Height Container* yang kaku pada kartu teks, digantikan oleh *Flexible / Expanded / Wrap widgets* untuk mencegah terjadinya *UI Overflow Error (`A RenderFlex overflowed by xxx pixels`)* saat ukuran font diperbesar oleh pengguna.
4. **Semantic Labels for Screen Readers**:
   - Seluruh ikon yang tidak memiliki label teks pendamping wajib dibungkus dengan properti `Semantics(label: '...', child: Icon(...))` atau `Tooltip(message: '...')` agar dapat dibacakan dengan jelas oleh fitur *TalkBack* (Android) maupun *VoiceOver* (iOS).

---

## 17. FLUTTER WIDGET RECOMMENDATION (*Panduan Teknis untuk Tim Developer `/Mobile` & `/Halaman-Driver`*)

Untuk menjamin kelancaran implementasi kode tanpa menyimpang dari rancangan visual dokumen ini, berikut adalah rekomendasi pemetaan widget resmi Flutter Material 3 yang wajib dipatuhi:

| Komponen / Fitur UI | Rekomendasi Widget Flutter Resmi | Parameter & Konfig Kritis yang Wajib Applied |
| :--- | :--- | :--- |
| **Theme & Color System** | `MaterialApp(theme: ThemeData(useMaterial3: true))` | Gunakan `ColorScheme.fromSeed(seedColor: Color(0xFF1E7D32))` untuk menghasilkan *Tonal Palette* yang konsisten. |
| **Top Navigation & Title** | `AppBar(centerTitle: false, elevation: 0)` | Latar putih `#FFFFFF` (atau warna primary pada hero screen), judul *Title Large*, tombol *Back arrow* otomatis. |
| **Bottom Navigation Shell** | `NavigationBar(destinations: [...])` | Gunakan widget Material 3 `NavigationBar` (bukan `BottomNavigationBar` lama) agar mendapatkan indikator pil aktif `radiusXL`. |
| **Cards & Containers** | `Card(elevation: 1, shape: RoundedRectangleBorder(...))` | Gunakan `BorderRadius.circular(12)` untuk kartu standar dan `BorderRadius.circular(16)` untuk Hero Card `HomeScreen`. |
| **Primary CTA Button** | `ElevatedButton(style: ElevatedButton.styleFrom(...))` | Atur `minimumSize: Size(double.infinity, 48)` (full width) dan `shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8/24))`. |
| **Form Inputs** | `TextFormField(decoration: InputDecoration(...))` | Atur `border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))` dengan `prefixIcon` dan `errorText` otomatis. |
| **Scrollable Lists** | `ListView.separated` / `GridView.builder` | Wajib gunakan `.separated` untuk memberikan *divider* / margin `SizedBox(height: 12)` yang konsisten antar kartu pesanan. |
| **Pull-to-Refresh** | `RefreshIndicator(color: Color(0xFF1E7D32), ...)` | Bungkus *ListView* dasbor dan pesanan dengan `RefreshIndicator` untuk mengambil data terbaru dari REST API secara manual. |
| **Driver Tracking Map** | `FlutterMap(options: MapOptions(...), children: [...])`| Gunakan paket `flutter_map` dengan lapisan `TileLayer (OpenStreetMap)` dan `PolylineLayer` rute hijau, disertai `MarkerLayer` truk. |
| **Shimmer Loading State** | `Shimmer.fromColors(baseColor: ..., highlightColor: ...)`| Gunakan `baseColor: Colors.grey[300]!` dan `highlightColor: Colors.grey[100]!` pada *skeleton box* saat memuat API. |
| **Bottom Sheet Info/Form** | `showModalBottomSheet(isScrollControlled: true, ...)` | Atur `shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16)))` dengan *Drag Handle pill*. |

---

## 18. PACKAGE RECOMMENDATION (*Daftar Dependensi Resmi Flutter & PHP Web Admin*)

Berikut adalah katalog paket resmi dan dependensi eksternal yang disetujui untuk mendukung implementasi visual antarmuka:

### A. Dependensi Aplikasi Flutter (`pubspec.yaml` untuk `/Mobile` & `/Halaman-Driver`)
```yaml
dependencies:
  flutter:
    sdk: flutter
  # Networking & State Management
  http: ^1.2.0                    # Komunikasi HTTP REST API ke backend PHP Native
  shared_preferences: ^2.2.3      # Penyimpanan lokal token sesi (api_token) & data user
  provider: ^6.1.2                # State management untuk keranjang jemputan & pemantauan status
  
  # UI Components & Typography
  google_fonts: ^6.2.1            # Memuat font Plus Jakarta Sans / Inter secara dinamis
  shimmer: ^3.0.0                 # Animasi skeleton loading pada daftar pesanan & dasbor
  intl: ^0.19.0                   # Pemformatan mata uang (Rp) & format tanggal WIB
  
  # Maps, Navigation & Camera Hardware
  flutter_map: ^6.1.0             # Widget peta interaktif OpenStreetMap untuk tracking (WRG-007)
  latlong2: ^0.9.1                # Kalkulasi koordinat & jarak (Distance/ETA calculator)
  url_launcher: ^6.3.0            # External launcher untuk Google Maps Navigation & WhatsApp/Telepon
  camera: ^0.11.0                 # Akses kamera perangkat untuk scan AI (WRG-008) & foto bukti (DRV-004)
```

### B. Dependensi Portal Web Admin (`/bank_sampah` — PHP Native Prosedural)
- **Bootstrap 5.3.x (CDN/Local CSS & JS)**: Kerangka kerja responsif utama untuk tata letak 12 kolom, *Navbar*, *Sidebar*, serta **Modal Timbang Akhir (`verify_modal.php - ADM-004`)**.
- **DataTables 1.13.x (jQuery Plugin)**: Plugin tabel interaktif berkemampuan tinggi untuk penelusuran (*Search*), pengurutan (*Sort*), dan navigasi halaman (*Pagination*) pada ratusan data pesanan di `ADM-003`.
- **Chart.js 4.4.x / ApexCharts**: Pustaka grafik JavaScript responsif untuk merender tren penjemputan bulanan dan komposisi jenis sampah pada dasbor eksekutif (`ADM-002`).
- **FontAwesome 6.x / Bootstrap Icons**: Pustaka ikon konsisten untuk mendampingi lencana status 6 warna pada tabel portal admin.

---

## 19. DESIGN RULES (*Aturan Visual Mutlak & Anti-Penyimpangan*)

Agar antarmuka yang dibangun tidak menyimpang dari hukum bisnis yang telah disepakati pada **`USER_FLOW.md`** dan **`SCREEN_CATALOG.md`**, berikut adalah 3 (tiga) aturan visual mutlak yang tidak boleh dilanggar oleh tim desain maupun developer:

```text
+---------------------------------------------------------------------------------------------------+
|                            ATURAN VISUAL MUTLAK ANTI-PENYIMPANGAN                                 |
+---------------------------------------------------------------------------------------------------+
| 1. LARANGAN TAMPILAN SALDO POIN SEBELUM COMPLETED:                                                |
|    Pada layar Order Detail (WRG-006) maupun kartu pesanan (WRG-005), angka saldo/poin sah DILARANG|
|    DITAMPILKAN selama status masih pending, accepted, on_the_way, picked_up, atau validating.     |
|    Antarmuka HANYA BOLEH menampilkan label: "Estimasi Poin: XX (Perkiraan)" dan teks keterangan   |
|    "Poin final sedang dihitung & divalidasi oleh gudang Bank Sampah."                             |
|                                                                                                   |
| 2. KEPADATAN & KONTRAS FORM TIMBANG LAPANGAN DRIVER (DRV-004):                                    |
|    Kolom input berat_driver_kg (Tahap 2) pada antarmuka Driver WAJIB dirancang berukuran besar    |
|    (minimal tinggi 56px, font ukuran 18px Bold), berborder hitam/hijau tebal, agar mudah diketik  |
|    oleh jemari armada saat berada di lapangan terbuka di bawah terik matahari.                    |
|                                                                                                   |
| 3. TABEL COMPARISON SIDE-BY-SIDE PADA MODAL TIMBANG GUDANG (ADM-004):                             |
|    Modal verifikasi akhir di Web Admin (verify_modal.php) WAJIB menyajikan 3 kolom angka berat    |
|    secara berdampingan lurus: [Kolom Estimasi Warga] vs [Kolom Timbang Driver] vs [Kolom Input    |
|    Berat Aktual Gudang]. Hal ini mutlak untuk menjamin transparansi audit sebelum petugas menekan |
|    tombol eksekusi Transaksi Atomic ACID.                                                         |
+---------------------------------------------------------------------------------------------------+
```

---

## 20. UI CONSISTENCY RULES (*Pedoman Konsistensi Antar-Platform & Modul*)

Untuk menjaga citra profesional dan mencegah kebingungan pengguna saat beralih antar aplikasi (*Cross-Platform Continuity*), seluruh penamaan istilah, format angka, dan penataan komponen tunduk pada pedoman konsistensi berikut:

1. **Keseragaman Nomenclature (Penamaan Istilah Resmi)**:
   - Gunakan selalu istilah **"Warga"** (bukan "Customer", "User", atau "Client") pada seluruh label dan pesan di antarmuka publik.
   - Gunakan selalu istilah **"Armada Driver"** (bukan "Kurir" atau "Supir") untuk aktor penjemput lapangan.
   - Gunakan selalu istilah **"Petugas Bank Sampah"** untuk aktor pengelola verifikasi gudang.
   - Gunakan selalu istilah **"Estimasi Berat (Kg)"** untuk Tahap 1, **"Berat Driver (Kg)"** untuk Tahap 2, dan **"Berat Aktual Gudang (Kg)"** untuk Tahap 3.
2. **Keseragaman Format Angka, Mata Uang, dan Poin**:
   - Seluruh angka nominal rupiah ditulis dengan format titik sebagai pemisah ribuan dan tanda desimal koma jika ada (contoh: `Rp 12.500` atau `Rp 2.500/Kg`).
   - Seluruh angka poin reward ditulis dengan format tanda plus di depan angka saat penambahan dan tanda titik ribuan (contoh: `+14.500 Poin`).
   - Seluruh angka penimbangan berat ditulis dengan akurasi 1 angka di belakang koma (contoh: `3,5 Kg` atau `12,0 Kg`).
3. **Keseragaman Format Tanggal & Waktu**:
   - Penulisan waktu pesanan di seluruh kartu dan tabel wajib menggunakan standar waktu Indonesia Barat dengan nama bulan disingkat atau penuh (contoh: `10 Jul 2026, 09:30 WIB` atau `10 Juli 2026`).

---
*Dokumen UI_REQUIREMENTS.md ini mengacu penuh pada MASTER_PROJECT_PLAN.md, FEATURE_INVENTORY.md, CONTENT_INVENTORY.md, INFORMATION_ARCHITECTURE.md, SCREEN_CATALOG.md, SITEMAP.md, dan USER_FLOW.md sebagai Single Source of Truth (SSOT).*
