<?php
// modules/api/detect.php
// Endpoint: menerima POST multipart/form-data 'image' (file) dari mobile
// Menyimpan file, menjalankan deteksi (py script jika tersedia), lalu mencari data di tabel jenis_sampah
error_reporting(0);
ini_set('display_errors', 0);
ob_start(); // Buffer any output/warnings

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Accept');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    ob_end_clean();
    echo json_encode(['success' => true]);
    exit;
}

require_once __DIR__ . '/../../config/database.php';

function respond($success, $message, $data = null, $code = 200) {
    http_response_code($code);
    $out = ob_get_clean(); // clean any buffered warnings
    // Optional: error_log("Buffered output before json: " . $out);
    echo json_encode(array_filter([
        'success' => $success,
        'message' => $message,
        'data' => $data
    ], function($v){ return $v !== null; }));
    exit;
}

if (!isset($_FILES['image']) || $_FILES['image']['error'] !== UPLOAD_ERR_OK) {
    respond(false, 'Tidak ada file image yang dikirim atau terjadi error saat upload', null, 400);
}

$file = $_FILES['image'];

// Validasi mime type menggunakan getimagesize agar lebih aman dan tahan terhadap 
// default header 'application/octet-stream' dari client Flutter.
$image_info = @getimagesize($file['tmp_name']);
if ($image_info === false) {
    respond(false, 'File yang dikirim bukan gambar valid.', null, 400);
}
$allowedMime = ['image/jpeg','image/png','image/webp'];
if (!in_array($image_info['mime'], $allowedMime)) {
    respond(false, 'Tipe file tidak diperbolehkan. Hanya JPEG/PNG/WEBP. Diterima: ' . $image_info['mime'], null, 400);
}

// Validasi ukuran file (maks 5 MB)
$MAX_UPLOAD_BYTES = 5 * 1024 * 1024; // 5 MB
if ($file['size'] > $MAX_UPLOAD_BYTES) {
    respond(false, 'Ukuran file terlalu besar. Maksimal 5 MB.', null, 413);
}

$uploadDir = __DIR__ . '/../../assets/uploads/';
if (!is_dir($uploadDir)) mkdir($uploadDir, 0755, true);
$ext = pathinfo($file['name'], PATHINFO_EXTENSION);
$filename = 'img_' . time() . '_' . bin2hex(random_bytes(6)) . '.' . preg_replace('/[^a-zA-Z0-9]/','',$ext);
$target = $uploadDir . $filename;

if (!move_uploaded_file($file['tmp_name'], $target)) {
    respond(false, 'Gagal menyimpan file di server', null, 500);
}

// Try to run ML script if available
$mlScript = __DIR__ . '/ml/detect.py';
$detected_labels = [];
if (file_exists($mlScript)) {
    // Try .venv python first, then python3, then python
    $venvPythonWin = realpath(__DIR__ . '/../../../.venv/Scripts/python.exe');
    $venvPythonUnix = realpath(__DIR__ . '/../../../.venv/bin/python');
    
    $pythonCmds = [];
    if ($venvPythonWin && file_exists($venvPythonWin)) {
        $pythonCmds[] = $venvPythonWin;
    }
    if ($venvPythonUnix && file_exists($venvPythonUnix)) {
        $pythonCmds[] = $venvPythonUnix;
    }
    $pythonCmds[] = 'python'; // Windows default
    $pythonCmds[] = 'python3'; // Unix default

    $output = null; $returnVar = null; $raw = null;
    foreach ($pythonCmds as $py) {
        // Use escapeshellarg for the executable path in case it contains spaces
        $cmd = escapeshellarg($py) . ' ' . escapeshellarg($mlScript) . ' ' . escapeshellarg($target) . ' 2>&1';
        @exec($cmd, $output, $returnVar);
        $raw = implode("\n", (array)$output);
        if ($returnVar === 0 && !empty($raw)) {
            // Check if output is actually valid JSON
            json_decode($raw);
            if (json_last_error() === JSON_ERROR_NONE) break;
        }
        // Reset output for next iteration if failed
        $output = null;
    }

    if (!empty($raw)) {
        $json = json_decode($raw, true);
        if (json_last_error() === JSON_ERROR_NONE && isset($json['labels'])) {
            $detected_labels = (array)$json['labels'];
        }
    }
}

// Fallback: jika tidak ada ML atau ML gagal, pilih label acak dari DB (untuk development)
if (empty($detected_labels)) {
    // Ambil 1 label acak dari jenis_sampah
    $q = mysqli_query($koneksi, "SELECT nama_sampah FROM jenis_sampah ORDER BY RAND() LIMIT 1");
    if ($q && mysqli_num_rows($q) > 0) {
        $row = mysqli_fetch_assoc($q);
        $detected_labels[] = $row['nama_sampah'];
    }
}

$results = [];
foreach ($detected_labels as $label) {
    $label_safe = mysqli_real_escape_string($koneksi, $label);
    // Cari kecocokan nama atau kategori
    $sql = "SELECT * FROM jenis_sampah WHERE nama_sampah LIKE '%$label_safe%' OR kategori LIKE '%$label_safe%' LIMIT 1";
    $res = mysqli_query($koneksi, $sql);
    if ($res && mysqli_num_rows($res) > 0) {
        $data = mysqli_fetch_assoc($res);
        // Build public URL for gambar jika ada
        $img_url = null; if (!empty($data['gambar'])) {
            $img_url = rtrim(BASE_URL, '/') . '/' . ltrim($data['gambar'], '/');
        }
        $results[] = [
            'label' => $label,
            'id_jenis_sampah' => $data['id_jenis_sampah'],
            'nama_sampah' => $data['nama_sampah'],
            'kategori' => $data['kategori'] ?? null,
            'deskripsi' => $data['deskripsi'] ?? null,
            'cara_pengolahan' => $data['cara_pengolahan'] ?? null,
            'gambar' => $img_url,
            'video' => $data['video'] ?? null
        ];
    } else {
        $results[] = ['label' => $label, 'found' => false];
    }
}

$response = [
    'uploaded_file' => rtrim(BASE_URL, '/') . '/assets/uploads/' . $filename,
    'detections' => $results
];

// Optionally capture user id from POST (provided by mobile). If not provided, NULL.
$user_id = null;
if (isset($_POST['user_id']) && is_numeric($_POST['user_id'])) {
    $user_id = (int) $_POST['user_id'];
} elseif (isset($_SESSION['user_id'])) {
    $user_id = (int) $_SESSION['user_id'];
}

// Prepare JSON fields for DB
$labels_json = json_encode(array_values($detected_labels));
$matched_json = json_encode($results);

// Ensure deteksi table exists; if not, try to create it using SQL file
$tbl = 'deteksi';
$q = mysqli_query($koneksi, "SELECT COUNT(*) as cnt FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = '" . mysqli_real_escape_string($koneksi, $tbl) . "'");
$exists = false;
if ($q) {
    $r = mysqli_fetch_assoc($q);
    $exists = ($r['cnt'] > 0);
}

if (!$exists) {
    $sqlPath = __DIR__ . '/create_table_deteksi.sql';
    if (file_exists($sqlPath)) {
        $sqlContent = file_get_contents($sqlPath);
        if ($sqlContent !== false) {
            // Try to run multi query to create table
            if (mysqli_multi_query($koneksi, $sqlContent)) {
                // flush multi_query results
                do { } while (mysqli_more_results($koneksi) && mysqli_next_result($koneksi));
                $exists = true;
            }
        }
    }
}

$insert_id = null;
if ($exists) {
    $uploaded_file_db = 'assets/uploads/' . $filename;
    $labels_esc = mysqli_real_escape_string($koneksi, $labels_json);
    $matched_esc = mysqli_real_escape_string($koneksi, $matched_json);
    $uploaded_esc = mysqli_real_escape_string($koneksi, $uploaded_file_db);
    $user_val = ($user_id !== null) ? intval($user_id) : 'NULL';
    $insSql = "INSERT INTO deteksi (id_pengguna, uploaded_file, labels_json, matched_json, note) VALUES ($user_val, '$uploaded_esc', '$labels_esc', '$matched_esc', '')";
    if (mysqli_query($koneksi, $insSql)) {
        $insert_id = mysqli_insert_id($koneksi);
        // attach detection id to response
        $response['detection_id'] = $insert_id;
    } else {
        // if insert fails, include DB error in note but do not fail the entire response
        $response['db_error'] = mysqli_error($koneksi);
    }
} else {
    $response['note'] = 'Tabel deteksi tidak ditemukan dan tidak dapat dibuat otomatis. Jalankan modules/api/create_table_deteksi.sql';
}

respond(true, 'Deteksi selesai', $response, 200);
