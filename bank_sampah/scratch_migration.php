<?php
require_once __DIR__ . '/config/database.php';

// Check if column driver_status exists
$res = mysqli_query($koneksi, "SHOW COLUMNS FROM pengguna LIKE 'driver_status'");
if (mysqli_num_rows($res) == 0) {
    $q = "ALTER TABLE pengguna ADD COLUMN driver_status ENUM('online','offline') DEFAULT 'offline'";
    if (mysqli_query($koneksi, $q)) {
        echo "Successfully added driver_status column to pengguna table.\n";
    } else {
        echo "Error adding column: " . mysqli_error($koneksi) . "\n";
    }
} else {
    $q = "ALTER TABLE pengguna MODIFY COLUMN driver_status ENUM('online','offline') DEFAULT 'offline'";
    if (mysqli_query($koneksi, $q)) {
        echo "Successfully modified driver_status column to ENUM('online','offline').\n";
    } else {
        echo "Error modifying column: " . mysqli_error($koneksi) . "\n";
    }
}
