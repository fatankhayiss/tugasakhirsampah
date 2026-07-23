<?php
require_once __DIR__ . '/config/database.php';
$res = mysqli_query($koneksi, "SHOW COLUMNS FROM detail_driver");
$cols = [];
while ($row = mysqli_fetch_assoc($res)) {
    $cols[] = $row['Field'] . ' (' . $row['Type'] . ')';
}
echo "Columns in detail_driver:\n" . implode("\n", $cols) . "\n";
?>
