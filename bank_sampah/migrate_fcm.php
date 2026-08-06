<?php
require_once __DIR__ . '/config/database.php';

$query = "ALTER TABLE pengguna ADD COLUMN IF NOT EXISTS fcm_token VARCHAR(255) NULL DEFAULT NULL AFTER api_token";

if (mysqli_query($koneksi, $query)) {
    echo "Kolom fcm_token berhasil ditambahkan atau sudah ada.\n";
} else {
    echo "Gagal menambahkan kolom fcm_token: " . mysqli_error($koneksi) . "\n";
}
?>
