<?php
// Simulate what detect.php does for SQL matching — test all 7 YOLO labels
require 'config/database.php';

$yolo_labels = ['kaca', 'kaleng', 'kardus', 'kertas', 'organik', 'plastik_hdpe', 'plastik_pet'];

echo "=== SQL Match Test for all 7 YOLO labels ===\n\n";

foreach ($yolo_labels as $label) {
    $label_lower = strtolower(trim($label));
    $label_norm  = mysqli_real_escape_string($koneksi, $label_lower);
    $tokens = array_values(array_filter(
        preg_split('/[_\s]+/', $label_lower),
        fn($t) => strlen($t) >= 3
    ));

    // Priority 1: exact normalised match
    $sql = "SELECT id_jenis_sampah, nama_sampah, kategori, harga_per_kg
            FROM jenis_sampah
            WHERE REPLACE(LOWER(nama_sampah),' ','_') = '$label_norm'
            LIMIT 1";
    $res = mysqli_query($koneksi, $sql);

    $match_priority = 1;

    // Priority 2: AND tokens
    if (!$res || mysqli_num_rows($res) === 0) {
        $match_priority = 2;
        if (count($tokens) > 1) {
            $and_parts = array_map(fn($t) =>
                "LOWER(nama_sampah) LIKE '%" . mysqli_real_escape_string($koneksi, $t) . "%'",
                $tokens
            );
            $sql = "SELECT id_jenis_sampah, nama_sampah, kategori, harga_per_kg
                    FROM jenis_sampah WHERE " . implode(' AND ', $and_parts) . " LIMIT 1";
            $res = mysqli_query($koneksi, $sql);
        }
    }

    // Priority 3: OR fallback
    if (!$res || mysqli_num_rows($res) === 0) {
        $match_priority = 3;
        $or_parts = ["LOWER(nama_sampah) LIKE '%$label_norm%'"];
        foreach ($tokens as $tok) {
            $ts = mysqli_real_escape_string($koneksi, $tok);
            $or_parts[] = "LOWER(nama_sampah) LIKE '%$ts%'";
            $or_parts[] = "LOWER(kategori) LIKE '%$ts%'";
        }
        $sql = "SELECT id_jenis_sampah, nama_sampah, kategori, harga_per_kg
                FROM jenis_sampah WHERE " . implode(' OR ', $or_parts) . " LIMIT 1";
        $res = mysqli_query($koneksi, $sql);
    }

    if ($res && mysqli_num_rows($res) > 0) {
        $row = mysqli_fetch_assoc($res);
        echo "✅ [$label] (P$match_priority) → id={$row['id_jenis_sampah']} | {$row['nama_sampah']} | {$row['kategori']} | Rp{$row['harga_per_kg']}\n";
    } else {
        echo "❌ [$label] → NO MATCH\n";
    }
}
