Daftar file asset yang digunakan untuk Splash / Loading screen

Simpan file-file ini di dalam folder `assets/splash/`:

- logo.png            -> `assets/splash/logo.png` (logo putih/outline; gunakan PNG transparan)
- illustration.png    -> `assets/splash/illustration.png` (ilustrasi bawah layar, PNG)

Simpan file banner dashboard di folder `assets/images/banners/`:

- banner_recycle.png  -> `assets/images/banners/banner_recycle.png` (dashboard promo banner)

Catatan: ilustrasi sudah menggabungkan elemen "orang" dan "awan" menjadi satu gambar (`illustration.png`). Tidak perlu file `clouds.png` terpisah.

Aturan singkat:
- PNG transparan cocok untuk `logo.png` jika logo sudah final.
- Gunakan alpha/transparent background untuk ilustrasi agar mudah overlay.
- Jika Anda punya varian warna, tambahkan `logo_dark.svg` atau `illustration@2x.png` di folder yang sama.

Contoh penggunaan di Flutter: `Image.asset('assets/splash/logo.png')` dan `Image.asset('assets/splash/illustration.png')`.
