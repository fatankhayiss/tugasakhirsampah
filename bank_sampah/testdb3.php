<?php
require 'config/database.php';
$sql = "SELECT o.id_order, o.alamat_jemput, o.latitude, o.longitude, o.tanggal_order, 
               o.waktu_jemput_dari, o.waktu_jemput_sampai, o.estimasi_berat, o.status,
               w.nama_lengkap as nama_warga, w.no_telepon as telp_warga, o.created_at
        FROM orders o
        JOIN pengguna w ON o.id_warga = w.id_pengguna
        WHERE o.id_driver = 10 AND o.status IN ('accepted', 'on_the_way')
        ORDER BY o.created_at ASC LIMIT 1";
$r = mysqli_query($koneksi, $sql);
if (!$r) echo mysqli_error($koneksi);
while($row = mysqli_fetch_assoc($r)) print_r($row);
?>
