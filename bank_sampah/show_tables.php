<?php
require_once __DIR__ . '/config/database.php';

$res = mysqli_query($koneksi, "SHOW TABLES");
while($row = mysqli_fetch_array($res)) {
    echo $row[0] . "\n";
}
?>
