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
define('WORKER_HOST', '127.0.0.1');
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
        'worker_unavailable'=> false,
    ];
}

// ─────────────────────────────────────────────
// 1. Validate uploaded image
// ─────────────────────────────────────────────
if (!isset($_FILES['image']) || $_FILES['image']['error'] !== UPLOAD_ERR_OK) {
    respond(false, 'Tidak ada file image yang dikirim atau terjadi error saat upload', null, 400);
}

$file = $_FILES['image'];

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
if (!is_dir($uploadDir)) mkdir($uploadDir, 0755, true);

$ext      = strtolower(preg_replace('/[^a-zA-Z0-9]/', '', pathinfo($file['name'], PATHINFO_EXTENSION)));
$filename = 'img_' . time() . '_' . bin2hex(random_bytes(6)) . '.' . ($ext ?: 'jpg');
$target   = $uploadDir . $filename;

if (!move_uploaded_file($file['tmp_name'], $target)) {
    respond(false, 'Gagal menyimpan file di server.', null, 500);
}

// ─────────────────────────────────────────────
// 3. Call detection worker via socket
// ─────────────────────────────────────────────
$worker_result    = call_detection_worker(realpath($target));
$detected_labels  = $worker_result['labels'];
$worker_unavailable = $worker_result['worker_unavailable'];

// ─────────────────────────────────────────────
// 4. Match labels against jenis_sampah table
// ─────────────────────────────────────────────
$results = [];
if (!empty($detected_labels)) {
    foreach ($detected_labels as $label) {
        $label_safe = mysqli_real_escape_string($koneksi, $label);
        $sql = "SELECT id_jenis_sampah, nama_sampah, kategori, deskripsi, cara_pengolahan, gambar, harga_per_kg
                FROM jenis_sampah
                WHERE nama_sampah LIKE '%$label_safe%' OR kategori LIKE '%$label_safe%'
                LIMIT 1";
        $res = mysqli_query($koneksi, $sql);
        if ($res && mysqli_num_rows($res) > 0) {
            $row     = mysqli_fetch_assoc($res);
            $img_url = null;
            if (!empty($row['gambar'])) {
                $img_url = rtrim(BASE_URL, '/') . '/' . ltrim($row['gambar'], '/');
            }
            $results[] = [
                'label'           => $label,
                'id_jenis_sampah' => $row['id_jenis_sampah'],
                'nama_sampah'     => $row['nama_sampah'],
                'kategori'        => $row['kategori'] ?? null,
                'deskripsi'       => $row['deskripsi'] ?? null,
                'cara_pengolahan' => $row['cara_pengolahan'] ?? null,
                'harga_per_kg'    => $row['harga_per_kg'] ?? null,
                'gambar'          => $img_url,
                'found'           => true,
            ];
        } else {
            $results[] = ['label' => $label, 'found' => false];
        }
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
    $ins_sql      = "INSERT INTO deteksi (id_pengguna, uploaded_file, labels_json, matched_json, note)
                     VALUES ($user_val, '$file_esc', '$labels_esc', '$matched_esc', '')";
    if (mysqli_query($koneksi, $ins_sql)) {
        $insert_id = mysqli_insert_id($koneksi);
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

respond(true, 'Deteksi selesai', $response_data);
