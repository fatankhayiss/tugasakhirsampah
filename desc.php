<?php
require 'bank_sampah/config/database.php';
$r = mysqli_query($koneksi, "DESCRIBE detail_driver");
while($row = mysqli_fetch_assoc($r)) {
    echo $row['Field'] . " - " . $row['Type'] . "\n";
}
?>
