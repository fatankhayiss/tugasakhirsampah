<?php
require_once __DIR__ . '/config/database.php';
$res = mysqli_query($koneksi, 'SELECT * FROM pengguna ORDER BY id_pengguna DESC LIMIT 1');
print_r(mysqli_fetch_assoc($res));
?>
