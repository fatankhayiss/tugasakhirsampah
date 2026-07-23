<?php
require 'config/database.php';
$koneksi = mysqli_connect(DB_HOST, DB_USER, DB_PASS, DB_NAME, DB_PORT);

if (!$koneksi) {
    die("Connection failed: " . mysqli_connect_error());
}

$queries = [
    "ALTER TABLE deteksi ADD COLUMN kategori_sampah VARCHAR(100) DEFAULT NULL;",
    "ALTER TABLE deteksi ADD COLUMN confidence FLOAT DEFAULT NULL;",
    "ALTER TABLE deteksi ADD COLUMN berat FLOAT DEFAULT 1.0;",
    "ALTER TABLE deteksi ADD COLUMN estimasi_poin FLOAT DEFAULT 0.0;"
];

foreach ($queries as $q) {
    if (mysqli_query($koneksi, $q)) {
        echo "Success: $q\n";
    } else {
        echo "Error or already exists: " . mysqli_error($koneksi) . "\n";
    }
}
echo "Migration complete.\n";
