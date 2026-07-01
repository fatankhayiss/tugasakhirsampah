<?php
// modules/api/jenis_sampah_api.php
// Endpoint: Daftar jenis sampah + harga per kg
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Accept, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    echo json_encode(['success' => true]);
    exit;
}

require_once __DIR__ . '/../../config/database.php';

function api_respond($success, $message, $data = null, $code = 200) {
    http_response_code($code);
    $response = ['success' => $success, 'message' => $message];
    if ($data !== null) $response['data'] = $data;
    echo json_encode($response);
    exit;
}

$search = isset($_GET['search']) ? trim($_GET['search']) : '';

$where = '';
$params = [];
$types = '';

if ($search !== '') {
    $where = "WHERE nama_sampah LIKE ? OR deskripsi LIKE ?";
    $search_like = '%' . $search . '%';
    $params = [$search_like, $search_like];
    $types = 'ss';
}

$sql = "SELECT id_jenis_sampah, nama_sampah, harga_per_kg, deskripsi, satuan
        FROM jenis_sampah $where ORDER BY nama_sampah ASC";

if (!empty($params)) {
    $stmt = mysqli_prepare($koneksi, $sql);
    mysqli_stmt_bind_param($stmt, $types, ...$params);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);
} else {
    $result = mysqli_query($koneksi, $sql);
}

$items = [];
if ($result) {
    while ($row = mysqli_fetch_assoc($result)) {
        $items[] = [
            'id' => (int)$row['id_jenis_sampah'],
            'nama' => $row['nama_sampah'],
            'harga_per_kg' => floatval($row['harga_per_kg']),
            'deskripsi' => $row['deskripsi'] ?? null,
            'satuan' => $row['satuan'] ?? 'kg',
            'kategori' => $row['kategori'] ?? null,
            'gambar' => $row['gambar'] ?? null,
            'video' => $row['video'] ?? null,
            'cara_pengolahan' => $row['cara_pengolahan'] ?? null,
        ];
    }
}

if (isset($stmt)) mysqli_stmt_close($stmt);

api_respond(true, 'Daftar jenis sampah', $items);
?>
