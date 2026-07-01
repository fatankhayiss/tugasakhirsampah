Struktur Aset Gambar

Tujuan: Menyusun aset gambar agar rapi dan mudah ditemukan sebelum membuat tampilan.

Rekomendasi struktur:

assets/
  images/
    logos/           # Logo perusahaan/brand (SVG preferensi), contoh: logo_company.svg, logo_company_reverse.png
    ui/              # Gambar khusus UI (banners, hero, cards), contoh: ui_banner_login.png
    backgrounds/     # Backgrounds untuk layar (besar), contoh: bg_auth.png
    onboarding/      # Ilustrasi onboarding, contoh: onboard_step1.png
    illustrations/   # Ilustrasi vektor untuk tampilan, contoh: ill_product.svg
    avatars/         # Avatar pengguna placeholder, contoh: avatar_placeholder.png
  icons/
    svg/             # Ikon vektor (SVG)
    png/             # Ikon raster (png) untuk fallback
  splash/            # Gambar splash / launch screens
  placeholders/      # Placeholder images (empty states, errors)

Konvensi penamaan singkat:
- Gunakan huruf kecil, pisahkan dengan underscore: `logo_brand_primary.svg`
- Tambahkan varian: `_dark`, `_light`, atau `_small`, `_large` jika perlu
- Untuk raster images sediakan varian resolusi jika diperlukan menggunakan folder `2.0x/` dan `3.0x/` di samping file dasar (contoh: `assets/images/logo.png` dan `assets/images/2.0x/logo.png`).
- Prefer SVG untuk logo dan ikon agar skalabel.

Contoh pemetaan "tampilan" vs "logo":
- Logo: semua file di `assets/images/logos/` dan `assets/icons/svg/`
- Tampilan (UI): `assets/images/ui/`, `assets/images/backgrounds/`, `assets/images/onboarding/`, `assets/images/illustrations/`

Cara pakai di Flutter (`pubspec.yaml`):
Tambahkan path folder di bawah `flutter.assets:`. Contoh:

flutter:
  assets:
    - assets/images/
    - assets/icons/
    - assets/splash/

Catatan:
- Simpan file .svg untuk logo dan ikon bila memungkinkan.
- Masukkan file contoh atau placeholder agar folder ter-commit (saya sudah menambahkan .gitkeep di folder kosong).

Jika mau, saya bisa:
- Menyalin atau memindahkan file gambar yang sudah ada ke struktur ini.
- Menambahkan contoh penggunaan di kode (`Image.asset` / `SvgPicture.asset`).

