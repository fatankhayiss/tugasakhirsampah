<?php
require 'config/database.php';
$r=mysqli_query($koneksi, "SELECT api_token FROM pengguna WHERE id_pengguna=10");
print_r(mysqli_fetch_assoc($r));
?>
