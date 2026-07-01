<?php
require 'config/database.php';
$r=mysqli_query($koneksi, "SELECT id_pengguna, nama_lengkap, level FROM pengguna WHERE level='driver'");
while($row=mysqli_fetch_assoc($r)) print_r($row);
?>
