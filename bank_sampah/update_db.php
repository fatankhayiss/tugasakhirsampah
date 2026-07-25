<?php
require_once __DIR__ . "/config/database.php";

$queries = [
    "ALTER TABLE pengguna ADD COLUMN foto_profil_b64 LONGTEXT NULL",
    "ALTER TABLE reward_redemptions ADD COLUMN transfer_proof_b64 LONGTEXT NULL"
];

foreach ($queries as $q) {
    if (mysqli_query($koneksi, $q)) {
        echo "SUCCESS: $q\n";
    } else {
        echo "FAILED: $q - " . mysqli_error($koneksi) . "\n";
    }
}
echo "Done.";

