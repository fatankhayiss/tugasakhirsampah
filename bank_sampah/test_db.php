<?php
require_once __DIR__ . "/config/database.php";
$res = mysqli_query($koneksi, "SHOW CREATE TABLE pengguna");
$row = mysqli_fetch_row($res);
echo $row[1] . "\n\n";
$res = mysqli_query($koneksi, "SHOW CREATE TABLE reward_redemptions");
$row = mysqli_fetch_row($res);
echo $row[1] . "\n\n";

