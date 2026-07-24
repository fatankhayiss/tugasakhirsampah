<?php
// modules/monitor_ai/data.php
// API endpoint for fetching live AI detection logs
header('Content-Type: application/json');

if (!defined('BASE_URL')) {
    require_once '../../config/database.php'; 
    require_once '../../includes/functions.php'; 
}

// Pastikan hanya admin yang bisa akses
// Check_user_level will redirect if failed, but since this is an API, we can just check is_logged_in and user_level manually to return JSON instead of HTML redirect
if (!is_logged_in() || !isset($_SESSION['user_level']) || !in_array($_SESSION['user_level'], ['admin'])) {
    echo json_encode(['success' => false, 'message' => 'Unauthorized']);
    exit;
}

// Helper untuk time ago
function time_elapsed_string($datetime, $full = false) {
    $now = new DateTime;
    $ago = new DateTime($datetime);
    $diff = $now->diff($ago);

    $diff->w = floor($diff->d / 7);
    $diff->d -= $diff->w * 7;

    $string = array(
        'y' => 'tahun',
        'm' => 'bulan',
        'w' => 'minggu',
        'd' => 'hari',
        'h' => 'jam',
        'i' => 'menit',
        's' => 'detik',
    );
    foreach ($string as $k => &$v) {
        if ($diff->$k) {
            $v = $diff->$k . ' ' . $v;
        } else {
            unset($string[$k]);
        }
    }

    if (!$full) $string = array_slice($string, 0, 1);
    return $string ? implode(', ', $string) . ' yang lalu' : 'baru saja';
}

// Query untuk mengambil data deteksi terbaru, join ke tabel pengguna untuk ambil nama lengkap
// Tampilkan 12 data terakhir
$sql = "SELECT d.id_deteksi, d.uploaded_file, d.labels_json, d.created_at, p.nama_lengkap, p.foto_profil 
        FROM deteksi d 
        LEFT JOIN pengguna p ON d.id_pengguna = p.id_pengguna 
        ORDER BY d.id_deteksi DESC 
        LIMIT 12";

$result = mysqli_query($koneksi, $sql);

$data = [];
if ($result) {
    while ($row = mysqli_fetch_assoc($result)) {
        // Cek kalau item dibuat dalam 10 detik terakhir, maka tandai is_new = true
        $is_new = false;
        $created_time = strtotime($row['created_at']);
        if (time() - $created_time < 15) { // 15 detik
            $is_new = true;
        }

        $labels = [];
        if (!empty($row['labels_json'])) {
            $decoded = json_decode($row['labels_json'], true);
            if (is_array($decoded)) {
                $labels = $decoded;
            }
        }

        $data[] = [
            'id' => $row['id_deteksi'],
            'uploaded_file' => $row['uploaded_file'], // relative path, e.g. assets/uploads/img_xxx.jpg
            'nama_lengkap' => $row['nama_lengkap'],
            'foto_profil' => $row['foto_profil'],
            'labels' => $labels,
            'time_ago' => time_elapsed_string($row['created_at']),
            'is_new' => $is_new
        ];
    }
}

echo json_encode([
    'success' => true,
    'data' => $data
]);
