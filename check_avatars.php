<?php
require 'bank_sampah/config/database.php';
$res = mysqli_query($koneksi, "SELECT id_pengguna, nama_lengkap, foto_profil FROM pengguna");
while ($row = mysqli_fetch_assoc($res)) {
    echo $row['nama_lengkap'] . " -> " . $row['foto_profil'] . "\n";
}
