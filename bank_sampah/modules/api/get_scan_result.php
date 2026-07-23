<?php
require_once __DIR__ . '/../../config/database.php';

header('Content-Type: application/json');

function respond($success, $message = '', $data = null, $code = 200) {
    http_response_code($code);
    echo json_encode([
        'success' => $success,
        'message' => $message,
        'data'    => $data
    ]);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    respond(false, 'Metode tidak diizinkan. Gunakan GET.', null, 405);
}

$id = isset($_GET['id']) ? intval($_GET['id']) : 0;
if ($id <= 0) {
    respond(false, 'ID deteksi tidak valid.', null, 400);
}

$koneksi = mysqli_connect(DB_HOST, DB_USER, DB_PASS, DB_NAME, DB_PORT);
if (!$koneksi) {
    respond(false, 'Koneksi database gagal.', null, 500);
}

$sql = "SELECT d.id_deteksi, d.uploaded_file, d.kategori_sampah, d.confidence, d.berat, d.estimasi_poin, d.created_at
        FROM deteksi d
        WHERE d.id_deteksi = $id";
$res = mysqli_query($koneksi, $sql);

if (!$res || mysqli_num_rows($res) === 0) {
    respond(false, 'Data deteksi tidak ditemukan.', null, 404);
}

$row = mysqli_fetch_assoc($res);

// Resolve full image URL
$img = $row['uploaded_file'];
if (!empty($img) && !filter_var($img, FILTER_VALIDATE_URL)) {
    // Determine BASE_URL if not defined
    if (!defined('BASE_URL')) {
        $protocol = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off' || $_SERVER['SERVER_PORT'] == 443) ? "https://" : "http://";
        $domainName = $_SERVER['HTTP_HOST'];
        $path = rtrim(dirname(dirname(dirname($_SERVER['PHP_SELF']))), '/\\');
        $baseUrl = $protocol . $domainName . $path;
        define('BASE_URL', $baseUrl);
    }
    $img = rtrim(BASE_URL, '/') . '/' . ltrim($img, '/');
}

$data = [
    'id_deteksi'      => (int)$row['id_deteksi'],
    'image_url'       => $img,
    'kategori_sampah' => $row['kategori_sampah'],
    'confidence'      => $row['confidence'] !== null ? (float)$row['confidence'] : null,
    'berat'           => $row['berat'] !== null ? (float)$row['berat'] : 1.0,
    'estimasi_poin'   => $row['estimasi_poin'] !== null ? (float)$row['estimasi_poin'] : 0.0,
    'created_at'      => $row['created_at'],
];

respond(true, 'Data ditemukan', $data);
