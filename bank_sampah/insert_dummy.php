<?php
require_once 'config/database.php';

$images = [
    'assets/uploads/botol pet.jpeg',
    'assets/uploads/kardus.jpeg',
    'assets/uploads/kaleng.jpeg',
    'assets/uploads/plastik hdpe.jpeg',
    'assets/uploads/besi.jpeg'
];

$labels = [
    '["Botol Plastik", "Plastik PET"]',
    '["Kardus Bekas", "Kertas"]',
    '["Kaleng Aluminium", "Logam"]',
    '["Plastik HDPE", "Botol Sampo"]',
    '["Besi", "Logam Berat"]'
];

$users_query = mysqli_query($koneksi, "SELECT id_pengguna FROM pengguna LIMIT 3");
$users = [];
while($row = mysqli_fetch_assoc($users_query)) {
    $users[] = $row['id_pengguna'];
}

$inserted = 0;
for ($i = 0; $i < 6; $i++) {
    $idx = array_rand($images);
    $img = $images[$idx];
    $lbl = $labels[$idx];
    $id_pengguna = count($users) > 0 ? $users[array_rand($users)] : "NULL";
    
    // Create random time within the last 2 hours
    $random_seconds = rand(0, 7200);
    $created_at = date('Y-m-d H:i:s', time() - $random_seconds);
    
    $sql = "INSERT INTO deteksi (id_pengguna, uploaded_file, labels_json, created_at) VALUES ($id_pengguna, '$img', '$lbl', '$created_at')";
    if (mysqli_query($koneksi, $sql)) {
        $inserted++;
    } else {
        echo "Error: " . mysqli_error($koneksi) . "\n";
    }
}
echo "Inserted $inserted dummy records.";
?>
