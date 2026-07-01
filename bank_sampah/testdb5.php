<?php
require 'config/database.php';
$r=mysqli_query($koneksi, "SHOW COLUMNS FROM jenis_sampah");
while($row=mysqli_fetch_assoc($r)) print_r($row);
?>
