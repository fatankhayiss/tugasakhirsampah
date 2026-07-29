<?php
// modules/api/detect.php
// ─────────────────────────────────────────────────────────────
// Endpoint: menerima POST multipart/form-data 'image' (file)
// Alur:
//   1. Validasi & simpan gambar yang di-upload
//   2. Kirim path gambar ke detect_worker.py via socket TCP
//   3. Terima label dari worker
//   4. Cocokkan label ke tabel jenis_sampah
//   5. Simpan log ke tabel deteksi
//   6. Return JSON bersih ke Flutter / Admin
// ─────────────────────────────────────────────────────────────
error_reporting(0);
ini_set('display_errors', 0);
ob_start();

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Accept, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    ob_end_clean();
    echo json_encode(['success' => true]);
    exit;
}

require_once __DIR__ . '/../../config/database.php';

// ─────────────────────────────────────────────
// Worker configuration
// ─────────────────────────────────────────────
// WORKER_HOST and WORKER_PORT config based on environment
$worker_host = (defined('APP_ENV') && APP_ENV === 'production') ? '127.0.0.1' : '127.0.0.1';
define('WORKER_HOST', $worker_host);
define('WORKER_PORT', 5001);
define('WORKER_TIMEOUT', 15); // seconds

// ─────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────
function respond($success, $message, $data = null, $code = 200) {
    http_response_code($code);
    ob_end_clean();
    $payload = ['success' => $success, 'message' => $message];
    if ($data !== null) $payload['data'] = $data;
    echo json_encode($payload, JSON_UNESCAPED_UNICODE);
    exit;
}

/**
 * Send image_path to detect_worker.py via TCP socket.
 * Returns array: ['success' => bool, 'labels' => [...], 'worker_unavailable' => bool]
 */
function call_detection_worker(string $image_path): array {
    $sock = @fsockopen(WORKER_HOST, WORKER_PORT, $errno, $errstr, WORKER_TIMEOUT);

    if (!$sock) {
        // Worker not running — graceful fallback
        error_log("[detect.php] Worker unavailable ({$errno}): {$errstr}");
        return ['success' => false, 'labels' => [], 'worker_unavailable' => true];
    }

    stream_set_timeout($sock, WORKER_TIMEOUT);

    // Send newline-terminated JSON request
    $request = json_encode(['image_path' => $image_path], JSON_UNESCAPED_UNICODE) . "\n";
    fwrite($sock, $request);

    // Read newline-terminated JSON response
    $raw = '';
    while (!feof($sock)) {
        $chunk = fgets($sock, 8192);
        if ($chunk === false) break;
        $raw .= $chunk;
        if (str_contains($raw, "\n")) break;
    }
    fclose($sock);

    $raw = trim($raw);
    if (empty($raw)) {
        error_log("[detect.php] Worker returned empty response");
        return ['success' => false, 'labels' => [], 'worker_unavailable' => false];
    }

    $decoded = json_decode($raw, true);
    if (json_last_error() !== JSON_ERROR_NONE || !is_array($decoded)) {
        error_log("[detect.php] Worker returned invalid JSON: " . substr($raw, 0, 200));
        return ['success' => false, 'labels' => [], 'worker_unavailable' => false];
    }

    return [
        'success'           => ($decoded['success'] ?? false) === true,
        'labels'            => (array)($decoded['labels'] ?? []),
        'detections'        => (array)($decoded['detections'] ?? []), // [{label, confidence}]
        'worker_unavailable'=> false,
    ];
}

// ─────────────────────────────────────────────
// 1. Validate uploaded image
// ─────────────────────────────────────────────
error_log("\n==================================================");
error_log("STEP 3: PHP API (detect.php)");
error_log("==================================================");

if (!isset($_FILES['image']) || $_FILES['image']['error'] !== UPLOAD_ERR_OK) {
    error_log("❌ Error: No valid image file detected");
    respond(false, 'Tidak ada file image yang dikirim atau terjadi error saat upload', null, 400);
}

$file = $_FILES['image'];
error_log("✓ Image received successfully: " . $file['name']);

$image_info = @getimagesize($file['tmp_name']);
if ($image_info === false) {
    respond(false, 'File yang dikirim bukan gambar valid.', null, 400);
}
$allowedMime = ['image/jpeg', 'image/png', 'image/webp'];
if (!in_array($image_info['mime'], $allowedMime)) {
    respond(false, 'Tipe file tidak diperbolehkan. Hanya JPEG/PNG/WEBP.', null, 400);
}
if ($file['size'] > 5 * 1024 * 1024) {
    respond(false, 'Ukuran file terlalu besar. Maksimal 5 MB.', null, 413);
}

// ─────────────────────────────────────────────
// 2. Save uploaded image to disk
// ─────────────────────────────────────────────
$uploadDir = __DIR__ . '/../../assets/uploads/';
if (!is_dir($uploadDir)) {
    mkdir($uploadDir, 0755, true);
}

$ext      = strtolower(preg_replace('/[^a-zA-Z0-9]/', '', pathinfo($file['name'], PATHINFO_EXTENSION)));
$filename = 'img_' . time() . '_' . bin2hex(random_bytes(6)) . '.' . ($ext ?: 'jpg');
$target   = $uploadDir . $filename;

if (!move_uploaded_file($file['tmp_name'], $target)) {
    respond(false, 'Gagal menyimpan file di server.', null, 500);
}
error_log("✓ Image saved: " . $target);

// ─────────────────────────────────────────────
// 3. Call detection worker via socket
// ─────────────────────────────────────────────
error_log("• Executing Python AI worker...");
$worker_result    = call_detection_worker(realpath($target));
error_log("✓ Python executed. Result: " . json_encode($worker_result));
$detected_labels  = $worker_result['labels'];
$worker_unavailable = $worker_result['worker_unavailable'];

// ─────────────────────────────────────────────
// 4. Extract results (no DB matching needed)
// ─────────────────────────────────────────────
$results = [];
if (isset($worker_result['detections']) && is_array($worker_result['detections'])) {
    foreach ($worker_result['detections'] as $d) {
        if (isset($d['label'])) {
            $results[] = [
                'class'      => $d['label'],
                'confidence' => $d['confidence'] ?? 0.0,
                'box'        => $d['box'] ?? null
            ];
        }
    }
} else if (!empty($detected_labels)) {
    foreach ($detected_labels as $label) {
        $results[] = [
            'class'      => $label,
            'confidence' => 0.0,
            'box'        => null
        ];
    }
}

// ─────────────────────────────────────────────
// 5. Log to deteksi table
// ─────────────────────────────────────────────
$user_id = null;
if (isset($_POST['user_id']) && is_numeric($_POST['user_id'])) {
    $user_id = (int) $_POST['user_id'];
}

$labels_json  = json_encode(array_values($detected_labels), JSON_UNESCAPED_UNICODE);
$matched_json = json_encode($results, JSON_UNESCAPED_UNICODE);
$file_db_path = 'assets/uploads/' . $filename;

// Auto-create table if missing
$tbl_check = mysqli_query($koneksi,
    "SELECT COUNT(*) as cnt FROM INFORMATION_SCHEMA.TABLES
     WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'deteksi'"
);
$tbl_exists = false;
if ($tbl_check) {
    $tbl_row = mysqli_fetch_assoc($tbl_check);
    $tbl_exists = (int)$tbl_row['cnt'] > 0;
}
if (!$tbl_exists) {
    $sql_path = __DIR__ . '/create_table_deteksi.sql';
    if (file_exists($sql_path)) {
        $sql_content = file_get_contents($sql_path);
        if ($sql_content && mysqli_multi_query($koneksi, $sql_content)) {
            do {} while (mysqli_more_results($koneksi) && mysqli_next_result($koneksi));
            $tbl_exists = true;
        }
    }
}

$insert_id = null;
if ($tbl_exists) {
    $labels_esc   = mysqli_real_escape_string($koneksi, $labels_json);
    $matched_esc  = mysqli_real_escape_string($koneksi, $matched_json);
    $file_esc     = mysqli_real_escape_string($koneksi, $file_db_path);
    $user_val     = ($user_id !== null) ? intval($user_id) : 'NULL';
    
    $top_kategori_sampah = 'Tidak Dikenali';
    $top_confidence = 0.0;
    $top_berat = 1.0;
    $top_estimasi = 0.0; // Wait, without joining jenis_sampah, we don't know the price. But Flutter handles this.
    
    if (!empty($results)) {
        $first = $results[0];
        $top_kategori_sampah = !empty($first['class']) ? $first['class'] : 'Tidak Dikenali';
        $top_confidence = isset($first['confidence']) ? floatval($first['confidence']) : 0.0;
        // Default values, will be updated from Flutter
    }
    $cat_esc = mysqli_real_escape_string($koneksi, $top_kategori_sampah);

    $ins_sql      = "INSERT INTO deteksi (id_pengguna, uploaded_file, labels_json, matched_json, note, kategori_sampah, confidence, berat, estimasi_poin)
                     VALUES ($user_val, '$file_esc', '$labels_esc', '$matched_esc', '', '$cat_esc', $top_confidence, $top_berat, $top_estimasi)";
    if (mysqli_query($koneksi, $ins_sql)) {
        $insert_id = mysqli_insert_id($koneksi);
    } else {
        error_log("❌ Error inserting deteksi: " . mysqli_error($koneksi));
    }
}

// ─────────────────────────────────────────────
// 6. Build response
// ─────────────────────────────────────────────
$response_data = [
    'uploaded_file'      => rtrim(BASE_URL, '/') . '/assets/uploads/' . $filename,
    'labels'             => array_values($detected_labels),
    'detections'         => $results,
    'worker_unavailable' => $worker_unavailable,
];
if ($insert_id !== null) {
    $response_data['detection_id'] = $insert_id;
}

error_log("✓ JSON generated and returned: " . json_encode(['success' => true, 'message' => 'Deteksi selesai', 'data' => $response_data]));
respond(true, 'Deteksi selesai', $response_data);
