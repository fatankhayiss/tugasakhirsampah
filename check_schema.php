<?php
require 'bank_sampah/config/database.php';
$res = mysqli_query($koneksi, 'DESCRIBE jenis_sampah');
while($row = mysqli_fetch_assoc($res)) {
    print_r($row);
}
?>
