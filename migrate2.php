<?php
require 'bank_sampah/config/database.php';
mysqli_query($koneksi, "ALTER TABLE notifikasi ADD COLUMN read_at DATETIME NULL");
echo "Migration read_at completed: " . mysqli_error($koneksi);
?>
