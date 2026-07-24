<?php
require 'config/database.php';
$res = mysqli_query($koneksi, 'DESCRIBE deteksi');
while($row = mysqli_fetch_assoc($res)) {
    print_r($row);
}
?>
