<?php
require_once __DIR__ . '/config/database.php';
$sql = "DESCRIBE edukasi";
$res = mysqli_query($koneksi, $sql);
while($row = mysqli_fetch_assoc($res)) {
    echo $row['Field'] . " - " . $row['Type'] . "\n";
}
?>
