<?php
require 'config/database.php';
$r=mysqli_query($koneksi, "SELECT id_order, status, id_driver FROM orders ORDER BY id_order DESC LIMIT 5");
while($row=mysqli_fetch_assoc($r)) print_r($row);
?>
