CARA MENGGANTI GAMBAR:

1. Masukkan gambar ke folder sesuai kategori.

2. Gunakan nama file yang sama 
ATAU ubah path di:

lib/core/constants/app_images.dart

3. Contoh:

Login banner: 
assets/images/auth/login_banner.png

Profile user: 
assets/images/home/profile_user.png

Transfer icon: 
assets/icons/gopay.png

4. Setelah mengganti gambar:
flutter pub get

5. Restart aplikasi.

=====================================================
PANDUAN LOKASI GAMBAR & HALAMAN (ASSET ROUTING)
=====================================================

1. FOLDER: assets/images/auth/
   Digunakan di halaman: Login, Register, Forgot Password, OTP Verification.
   Contoh: banner login, banner register.

2. FOLDER: assets/images/home/
   Digunakan di halaman: Home (Dashboard).
   Contoh: banner home, foto profil user, gambar-gambar artikel/video edukasi.

3. FOLDER: assets/images/transfer/
   Digunakan di halaman: Transfer Point.
   Contoh: banner halaman transfer.

4. FOLDER: assets/images/common/
   Digunakan di berbagai halaman secara umum.
   Contoh: gambar ilustrasi onboarding, empty state, logo recycle.

5. FOLDER: assets/icons/
   Digunakan sebagai ikon pelengkap di seluruh aplikasi.
   Contoh: 
   - Ikon sosial media (Google, Apple, FB) di halaman Login/Register.
   - Ikon Bank (BCA, BNI, dll) dan E-Wallet (GoPay, Dana, dll) di halaman Transfer Point.
