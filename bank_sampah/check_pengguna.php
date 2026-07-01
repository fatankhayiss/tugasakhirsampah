<?php
require_once __DIR__ . '/config/database.php';

$res = mysqli_query($koneksi, "DESCRIBE pengguna");
if (!$res) {
    echo "Error: " . mysqli_error($koneksi);
} else {
    while($row = mysqli_fetch_assoc($res)) {
        echo $row['Field'] . " - " . $row['Type'] . "\n";
    }
}
?>
