<?php
require_once __DIR__ . '/config/database.php';
$sql = "UPDATE edukasi SET judul='Mendaur Ulang Sampah (LIVE DARI DATABASE!)' WHERE id_edukasi=1";
mysqli_query($koneksi, $sql);
echo "Updated!";
?>
