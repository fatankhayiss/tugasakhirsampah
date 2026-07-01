<?php
$start = microtime(true);
$koneksi = mysqli_connect('127.0.0.1', 'root', '', 'db_banksampah');
$time = microtime(true) - $start;
echo "Time: $time\n";
if (!$koneksi) {
    echo "Error: " . mysqli_connect_error();
} else {
    echo "Connected!";
}
?>
