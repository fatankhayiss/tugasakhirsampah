<?php
require 'bank_sampah/config/database.php';

$queries = [
    // 3. Drop detail_driver
    "DROP TABLE IF EXISTS detail_driver",

    // 4. Recreate detail_driver as Activity Log
    "CREATE TABLE detail_driver (
        id_detail_driver INT AUTO_INCREMENT PRIMARY KEY,
        id_order INT NOT NULL,
        id_picker INT NOT NULL,
        status VARCHAR(50) NOT NULL,
        assigned_at TIMESTAMP NULL DEFAULT NULL,
        departed_at TIMESTAMP NULL DEFAULT NULL,
        arrived_at TIMESTAMP NULL DEFAULT NULL,
        pickup_started_at TIMESTAMP NULL DEFAULT NULL,
        pickup_finished_at TIMESTAMP NULL DEFAULT NULL,
        arrived_bank_at TIMESTAMP NULL DEFAULT NULL,
        unloaded_at TIMESTAMP NULL DEFAULT NULL,
        note TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    )"
];

foreach ($queries as $q) {
    echo "Running: $q\n";
    if (mysqli_query($koneksi, $q)) {
        echo "Success\n";
    } else {
        echo "Error: " . mysqli_error($koneksi) . "\n";
    }
}
?>
