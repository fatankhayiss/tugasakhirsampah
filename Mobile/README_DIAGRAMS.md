# Cara Menggunakan Diagram Mermaid di Draw.io

File-file diagram Mermaid ini dapat diimport ke Draw.io (diagrams.net) dengan langkah berikut:

## Langkah-langkah Import ke Draw.io:

1. Buka [Draw.io](https://app.diagrams.net/) atau [diagrams.net](https://www.diagrams.net/)

2. Pilih **File > New** untuk membuat diagram baru

3. Pilih menu **Insert > Advanced > Mermaid**

4. Copy-paste kode Mermaid dari file:
   - `class_diagram.mmd` untuk Class Diagram
   - `erd_diagram.mmd` untuk ERD

5. Klik **Insert** untuk menambahkan diagram

6. Diagram akan otomatis dirender di canvas Draw.io

## File yang Tersedia:

- **`class_diagram.mmd`** - Class Diagram untuk struktur kelas aplikasi Flutter
- **`erd_diagram.mmd`** - ERD (Entity Relationship Diagram) untuk struktur database (disederhanakan untuk TA)

## Struktur ERD:

ERD ini telah disederhanakan untuk keperluan TA dengan fokus pada entitas bisnis utama:

### Entitas Utama:
- **USER** - Data pengguna aplikasi
- **PROFILE** - Profil pengguna (total waste & points)
- **WASTE_ITEM** - Jenis-jenis sampah yang tersedia
- **SCAN_DETECTION** - Hasil scan yang mengidentifikasi waste item
- **ORDER** - Pesanan penjemputan sampah
- **ORDER_WASTE_ITEM** - Relasi many-to-many antara order dan waste item
- **NOTIFICATION** - Notifikasi untuk pengguna

### Catatan Penting:
- **SCAN_DETECTION** terkait dengan **WASTE_ITEM** karena scan menghasilkan prediksi jenis sampah
- Struktur database menggunakan snake_case (sesuai konvensi PHP/database)
- Entitas yang tidak penting untuk TA (seperti EVENT, konten UI) telah dihapus

## Alternatif:

Jika Draw.io tidak mendukung import langsung, Anda bisa:
1. Copy kode dari file `.mmd`
2. Gunakan [Mermaid Live Editor](https://mermaid.live/) untuk melihat preview
3. Export sebagai gambar (PNG/SVG) dari Mermaid Live Editor
4. Import gambar ke Draw.io

## Catatan:

- Pastikan Draw.io versi terbaru untuk dukungan Mermaid terbaik
- Jika ada masalah rendering, coba gunakan Mermaid Live Editor terlebih dahulu
- Diagram dapat diedit lebih lanjut di Draw.io setelah diimport
- ERD menggunakan struktur database standar dengan primary key (PK) dan foreign key (FK)

