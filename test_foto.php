<?php
require_once 'bank_sampah/config/database.php';
$res = mysqli_query($koneksi, "SELECT username, foto_profil FROM pengguna WHERE level = 'driver' LIMIT 5");
while($row = mysqli_fetch_assoc($res)) {
    echo $row['username'] . ": " . $row['foto_profil'] . "\n";
}
?>
