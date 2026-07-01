<?php
// modules/api/upload.php
// Endpoint sederhana untuk menerima upload gambar dari aplikasi (Flutter/Android)
// Menerima: POST multipart/form-data dengan field 'image' (file) dan optional 'user_id'
// Mengembalikan: JSON { success: bool, message: string, path: string }

header('Content-Type: application/json; charset=utf-8');
// Izinkan CORS agar dapat diakses dari mobile app selama pengembangan
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Accept');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    // Preflight
    http_response_code(200);
    echo json_encode(['success' => true]);
    exit;
}

function respond($success, $message, $path = null, $code = 200) {
    http_response_code($code);
    echo json_encode(array_filter([
        'success' => $success,
        'message' => $message,
        'path' => $path
    ], function($v){ return $v !== null; }));
    exit;
}

// Pastikan upload field ada
if (!isset($_FILES['image']) || $_FILES['image']['error'] !== UPLOAD_ERR_OK) {
    respond(false, 'Tidak ada file image yang dikirim atau terjadi error saat upload', null, 400);
}

$file = $_FILES['image'];

// Validasi tipe file sederhana
$allowedMime = ['image/jpeg', 'image/png', 'image/webp'];
if (!in_array($file['type'], $allowedMime)) {
    respond(false, 'Tipe file tidak diperbolehkan. Hanya JPEG/PNG/WEBP.', null, 400);
}

// Validasi ukuran file (maks 5 MB)
$MAX_UPLOAD_BYTES = 5 * 1024 * 1024; // 5 MB
if ($file['size'] > $MAX_UPLOAD_BYTES) {
    respond(false, 'Ukuran file terlalu besar. Maksimal 5 MB.', null, 413);
}

// Cek pengaturan PHP (informasi jika server membatasi ukuran lebih kecil dari yang diinginkan)
$uploadMax = ini_get('upload_max_filesize');
$postMax = ini_get('post_max_size');
// convert helper
function phpSizeToBytes($size) {
    $unit = strtoupper(substr($size, -1));
    $value = (int)$size;
    switch($unit) {
        case 'G': return $value * 1024 * 1024 * 1024;
        case 'M': return $value * 1024 * 1024;
        case 'K': return $value * 1024;
        default: return (int)$size;
    }
}
if (phpSizeToBytes($uploadMax) < $MAX_UPLOAD_BYTES || phpSizeToBytes($postMax) < $MAX_UPLOAD_BYTES) {
    respond(false, 'Pengaturan server lebih kecil dari batas upload yang diizinkan. Periksa upload_max_filesize/post_max_size di php.ini.', null, 500);
}

// Lokasi penyimpanan relatif ke root project
$uploadDir = __DIR__ . '/../../assets/uploads/';
if (!is_dir($uploadDir)) {
    if (!mkdir($uploadDir, 0755, true)) {
        respond(false, 'Gagal membuat folder upload di server', null, 500);
    }
}

// Buat nama file unik
$ext = pathinfo($file['name'], PATHINFO_EXTENSION);
$safeExt = preg_replace('/[^a-zA-Z0-9]/', '', $ext);
$filename = 'img_' . time() . '_' . bin2hex(random_bytes(6)) . ($safeExt ? '.' . $safeExt : '');
$target = $uploadDir . $filename;

if (!move_uploaded_file($file['tmp_name'], $target)) {
    respond(false, 'Gagal menyimpan file di server', null, 500);
}

// Jika aplikasi membutuhkan path yang dapat diakses via web, coba bangun URL relatif
$baseUrl = '';
if (defined('BASE_URL')) {
    $baseUrl = rtrim(BASE_URL, '/') . '/';
} else {
    // Karena BASE_URL mungkin belum didefinisikan, coba bangun dari request
    $protocol = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https' : 'http';
    $host = $_SERVER['HTTP_HOST'] ?? 'localhost';
    $scriptDir = dirname($_SERVER['SCRIPT_NAME']);
    // assets/uploads di-root-kan relatif ke direktori project
    $baseUrl = $protocol . '://' . $host . rtrim(str_replace('\\', '/', dirname(dirname(dirname($_SERVER['SCRIPT_NAME'])))), '/') . '/';
}

$publicPath = 'assets/uploads/' . $filename;
$publicUrl = $baseUrl . $publicPath;

respond(true, 'File berhasil diupload', $publicUrl, 200);
