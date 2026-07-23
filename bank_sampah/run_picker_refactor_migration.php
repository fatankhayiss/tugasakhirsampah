<?php
require_once __DIR__ . '/config/database.php';

echo "Running migrations for Picker Refactor...\n";

// 1. Modify driver_status column in pengguna
$q1 = "ALTER TABLE pengguna MODIFY COLUMN driver_status VARCHAR(30) DEFAULT 'offline'";
echo "Executing: $q1 ... ";
if (mysqli_query($koneksi, $q1)) {
    echo "SUCCESS\n";
} else {
    echo "FAILED: " . mysqli_error($koneksi) . "\n";
}

// 2. Add status column to pengguna
$check_status = mysqli_query($koneksi, "SHOW COLUMNS FROM pengguna LIKE 'status'");
if (mysqli_num_rows($check_status) == 0) {
    $q2 = "ALTER TABLE pengguna ADD COLUMN status VARCHAR(20) DEFAULT 'aktif'";
    echo "Executing: $q2 ... ";
    if (mysqli_query($koneksi, $q2)) {
        echo "SUCCESS\n";
    } else {
        echo "FAILED: " . mysqli_error($koneksi) . "\n";
    }
} else {
    echo "Column 'status' already exists in 'pengguna'.\n";
}

// 3. Modify detail_driver columns to make vehicle fields nullable
$detail_driver_alters = [
    "ALTER TABLE detail_driver MODIFY COLUMN tipe_kendaraan ENUM('Mobil','Truk','Motor') NULL",
    "ALTER TABLE detail_driver MODIFY COLUMN jenis_kendaraan VARCHAR(100) NULL",
    "ALTER TABLE detail_driver MODIFY COLUMN plat_nomor VARCHAR(20) NULL"
];
foreach ($detail_driver_alters as $q) {
    echo "Executing: $q ... ";
    if (mysqli_query($koneksi, $q)) {
        echo "SUCCESS\n";
    } else {
        echo "FAILED: " . mysqli_error($koneksi) . "\n";
    }
}

// 4. Add notes column to detail_driver
$check_notes = mysqli_query($koneksi, "SHOW COLUMNS FROM detail_driver LIKE 'notes'");
if (mysqli_num_rows($check_notes) == 0) {
    $q4 = "ALTER TABLE detail_driver ADD COLUMN notes TEXT DEFAULT NULL";
    echo "Executing: $q4 ... ";
    if (mysqli_query($koneksi, $q4)) {
        echo "SUCCESS\n";
    } else {
        echo "FAILED: " . mysqli_error($koneksi) . "\n";
    }
} else {
    echo "Column 'notes' already exists in 'detail_driver'.\n";
}

echo "Migration finished!\n";
?>
