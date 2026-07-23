<?php
require 'config/database.php';

// Helper: add column only if it doesn't exist (MySQL compatible)
function addCol($koneksi, $table, $col, $def) {
    $r = mysqli_query($koneksi,
        "SELECT COUNT(*) as cnt FROM INFORMATION_SCHEMA.COLUMNS
         WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='$table' AND COLUMN_NAME='$col'");
    $row = mysqli_fetch_assoc($r);
    if ((int)$row['cnt'] === 0) {
        mysqli_query($koneksi, "ALTER TABLE $table ADD COLUMN $col $def")
            ? print("ADDED: $col\n")
            : print("FAIL ADD $col: " . mysqli_error($koneksi) . "\n");
    } else {
        echo "EXISTS: $col\n";
    }
}

// 1. Add missing columns
addCol($koneksi, 'jenis_sampah', 'kategori',       'VARCHAR(100) DEFAULT NULL');
addCol($koneksi, 'jenis_sampah', 'cara_pengolahan', 'TEXT DEFAULT NULL');
addCol($koneksi, 'jenis_sampah', 'gambar',          'VARCHAR(255) DEFAULT NULL');

// 2. Update existing rows with kategori
$updates = [
    ['Plastik', "LOWER(nama_sampah) LIKE '%plastik%'"],
    ['Kardus',  "LOWER(nama_sampah) LIKE '%kardus%'"],
    ['Kertas',  "LOWER(nama_sampah) LIKE '%kertas%'"],
    ['Logam',   "LOWER(nama_sampah) LIKE '%logam%'"],
    ['Kaca',    "LOWER(nama_sampah) LIKE '%kaca%'"],
    ['Organik', "LOWER(nama_sampah) LIKE '%organik%'"],
    ['Logam',   "LOWER(nama_sampah) LIKE '%aluminium%'"],
];
echo "\n--- Updating existing rows ---\n";
foreach ($updates as [$kat, $where]) {
    mysqli_query($koneksi, "UPDATE jenis_sampah SET kategori='$kat' WHERE $where AND (kategori IS NULL OR kategori='')");
    echo "Updated $kat: " . mysqli_affected_rows($koneksi) . " rows\n";
}

// 3. Seed the 7 YOLO model class rows
$seeds = [
    ['kaca',         'Kaca',         500.00,  'Botol kaca, gelas kaca bekas.',               'Kaca',    'Bungkus dengan kertas agar tidak melukai. Kumpulkan ke bank sampah.'],
    ['kaleng',       'Kaleng',      1500.00,  'Kaleng minuman, kaleng makanan bekas.',        'Logam',   'Cuci bersih, pipihkan, kumpulkan ke bank sampah.'],
    ['kardus',       'Kardus',      1500.00,  'Kardus bekas kemasan, dus.',                  'Kardus',  'Lipat dan kempiskan, pisahkan dari kotoran, serahkan ke bank sampah.'],
    ['kertas',       'Kertas',      1200.00,  'Kertas HVS, buku, koran bekas.',              'Kertas',  'Pisahkan bersih dan kering, bundel dan serahkan ke bank sampah.'],
    ['organik',      'Organik',        0.00,  'Sisa makanan, sayuran, buah-buahan.',         'Organik', 'Olah menjadi kompos atau serahkan ke unit pengolahan organik.'],
    ['plastik_hdpe', 'Plastik HDPE',2800.00,  'Plastik HDPE: botol shampo, detergen, galon.','Plastik', 'Cuci bersih, pisahkan tutupnya, serahkan ke bank sampah.'],
    ['plastik_pet',  'Plastik PET', 3000.00,  'Botol plastik PET: air mineral, minuman soda.','Plastik', 'Cuci bersih, keringkan, kumpulkan ke bank sampah atau pusat daur ulang.'],
];

echo "\n--- Seeding YOLO class rows ---\n";
foreach ($seeds as [$yolo_key, $nama, $harga, $deskripsi, $kat, $cara]) {
    // Check by exact YOLO key match in nama_sampah (case insensitive)
    $key_esc = mysqli_real_escape_string($koneksi, $yolo_key);
    $check = mysqli_query($koneksi,
        "SELECT id_jenis_sampah FROM jenis_sampah WHERE REPLACE(LOWER(nama_sampah),' ','_')='$key_esc' OR LOWER(nama_sampah)='$key_esc'");
    if ($check && mysqli_num_rows($check) > 0) {
        echo "EXISTS (yolo_key=$yolo_key): $nama\n";
        continue;
    }
    $n = mysqli_real_escape_string($koneksi, $nama);
    $d = mysqli_real_escape_string($koneksi, $deskripsi);
    $k = mysqli_real_escape_string($koneksi, $kat);
    $c = mysqli_real_escape_string($koneksi, $cara);
    $sql = "INSERT INTO jenis_sampah (nama_sampah, harga_per_kg, deskripsi, satuan, kategori, cara_pengolahan)
            VALUES ('$n', $harga, '$d', 'kg', '$k', '$c')";
    mysqli_query($koneksi, $sql)
        ? print("INSERTED: $nama\n")
        : print("FAIL INSERT $nama: " . mysqli_error($koneksi) . "\n");
}

echo "\n=== FINAL jenis_sampah ===\n";
$r = mysqli_query($koneksi, 'SELECT id_jenis_sampah, nama_sampah, kategori, harga_per_kg FROM jenis_sampah ORDER BY id_jenis_sampah');
while ($row = mysqli_fetch_assoc($r)) {
    echo "{$row['id_jenis_sampah']}: {$row['nama_sampah']} | {$row['kategori']} | Rp{$row['harga_per_kg']}\n";
}
