<?php
require_once __DIR__ . '/config/database.php';
$res = mysqli_query($koneksi, "SHOW COLUMNS FROM pengguna");
$cols = [];
while ($row = mysqli_fetch_assoc($res)) {
    $cols[] = $row['Field'] . ' (' . $row['Type'] . ')';
}
echo "Columns in pengguna:\n" . implode("\n", $cols) . "\n";
?>
