<?php
require_once __DIR__ . '/../config/database.php';

echo "Checking pengguna table schema...\n";

// Check and add google_uid
$c1 = mysqli_query($koneksi, "SHOW COLUMNS FROM pengguna LIKE 'google_uid'");
if (mysqli_num_rows($c1) == 0) {
    if (mysqli_query($koneksi, "ALTER TABLE pengguna ADD COLUMN google_uid VARCHAR(255) NULL DEFAULT NULL AFTER email")) {
        echo "Successfully added column 'google_uid'.\n";
    } else {
        echo "Error adding 'google_uid': " . mysqli_error($koneksi) . "\n";
    }
} else {
    echo "Column 'google_uid' already exists.\n";
}

// Check and add updated_at
$c2 = mysqli_query($koneksi, "SHOW COLUMNS FROM pengguna LIKE 'updated_at'");
if (mysqli_num_rows($c2) == 0) {
    if (mysqli_query($koneksi, "ALTER TABLE pengguna ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP AFTER tanggal_daftar")) {
        echo "Successfully added column 'updated_at'.\n";
    } else {
        echo "Error adding 'updated_at': " . mysqli_error($koneksi) . "\n";
    }
} else {
    echo "Column 'updated_at' already exists.\n";
}

// Ensure status exists (we added it previously, check to be safe)
$c3 = mysqli_query($koneksi, "SHOW COLUMNS FROM pengguna LIKE 'status'");
if (mysqli_num_rows($c3) == 0) {
    if (mysqli_query($koneksi, "ALTER TABLE pengguna ADD COLUMN status VARCHAR(20) NOT NULL DEFAULT 'aktif' AFTER level")) {
        echo "Successfully added column 'status'.\n";
    } else {
        echo "Error adding 'status': " . mysqli_error($koneksi) . "\n";
    }
} else {
    echo "Column 'status' already exists.\n";
}

echo "Migration completed successfully.\n";
?>
