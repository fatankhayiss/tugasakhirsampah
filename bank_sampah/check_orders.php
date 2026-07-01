<?php
require_once __DIR__ . '/config/database.php';

$tables = ['orders', 'order_items'];
foreach ($tables as $t) {
    echo "TABLE: $t\n";
    $res = mysqli_query($koneksi, "DESCRIBE $t");
    if (!$res) echo "Error: " . mysqli_error($koneksi) . "\n";
    else {
        while($row = mysqli_fetch_assoc($res)) {
            echo $row['Field'] . " - " . $row['Type'] . "\n";
        }
    }
    echo "\n";
}
?>
