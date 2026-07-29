<?php
require 'bank_sampah/config/database.php';

$queries = [
    "ALTER TABLE deteksi ADD COLUMN kategori_sampah VARCHAR(100) DEFAULT 'Tidak Dikenali';",
    "ALTER TABLE deteksi ADD COLUMN confidence FLOAT DEFAULT 0;",
    "ALTER TABLE deteksi ADD COLUMN berat FLOAT DEFAULT 1;",
    "ALTER TABLE deteksi ADD COLUMN estimasi_poin FLOAT DEFAULT 0;"
];

foreach ($queries as $q) {
    if (mysqli_query($koneksi, $q)) {
        echo "Success: $q\n";
    } else {
        echo "Error or already exists: " . mysqli_error($koneksi) . "\n";
    }
}
echo "Done.\n";
