<?php
require_once __DIR__ . '/config/database.php';

$sql = file_get_contents(__DIR__ . '/add_detail_driver.sql');

if (mysqli_multi_query($koneksi, $sql)) {
    do {
        if ($result = mysqli_store_result($koneksi)) {
            mysqli_free_result($result);
        }
    } while (mysqli_more_results($koneksi) && mysqli_next_result($koneksi));
    echo "Migration successful.\n";
} else {
    echo "Migration failed: " . mysqli_error($koneksi) . "\n";
}
?>
