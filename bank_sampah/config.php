<?php
// config.php

// Pengaturan Database (Sesuaikan dengan detail database Anda di Serv00)
define('DB_HOST', getenv('DB_HOST') ?: '127.0.0.1');
define('DB_USER', getenv('DB_USER') ?: 'root');
define('DB_PASS', getenv('DB_PASS') ?: '');
define('DB_PORT', getenv('DB_PORT') ?: 3306);

$use_dummy_flag = __DIR__ . DIRECTORY_SEPARATOR . 'use_dummy_db';

if (file_exists($use_dummy_flag)) {
    define('DB_NAME', 'db_banksampah_dummy');
} else {
    define('DB_NAME', getenv('DB_NAME') ?: 'db_banksampah');
}
  

// Membuat Koneksi
$koneksi = mysqli_connect(
    DB_HOST,
    DB_USER,
    DB_PASS,
    DB_NAME
);

// Cek Koneksi
if ($conn->connect_error) {
    // Jika koneksi gagal, hentikan skrip dan tampilkan pesan error.
    // Sebaiknya ini tidak ditampilkan ke user umum di mode produksi,
    // tapi untuk pengembangan ini membantu.
    die("Koneksi ke database gagal: " . $conn->connect_error);
}

// (Opsional) Atur character set ke utf8mb4 untuk dukungan karakter yang lebih baik
if (!$conn->set_charset("utf8mb4")) {
    // printf("Error loading character set utf8mb4: %s\n", $conn->error);
    // Untuk produksi, Anda mungkin hanya ingin log error ini.
}

// Anda bisa menambahkan konstanta atau pengaturan global lainnya di sini jika perlu
// define('NAMA_APLIKASI', 'Bank Sampah Kampung Kita');
// define('BASE_URL', 'http://domainanda.serv00.com/nama_proyek_bank_sampah/');

// Atur zona waktu default jika diperlukan
date_default_timezone_set('Asia/Jakarta');

?>
