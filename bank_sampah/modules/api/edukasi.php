<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');

require_once __DIR__ . '/../../config/database.php';

function json_response($success, $message = '', $data = null, $code = 200) {
    http_response_code($code);
    echo json_encode([
        'success' => $success,
        'message' => $message,
        'data' => $data
    ]);
    exit;
}

function abs_url($path) {
    if (!$path) return null;
    if (preg_match('#^https?://#', $path)) return $path;
    // Bangun URL absolut dari host root untuk menghindari penempelan path skrip
    $scheme = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https' : 'http';
    $host = $_SERVER['HTTP_HOST'] ?? 'localhost';
    $normalized = '/' . ltrim($path, '/');
    return $scheme . '://' . $host . $normalized;
}

/* =====================
   PARAM
===================== */
$id     = isset($_GET['id']) ? (int)$_GET['id'] : 0;
$search = trim($_GET['search'] ?? '');
$type   = trim($_GET['type'] ?? '');   // 'article' | 'video' | '' (semua)
$page   = max(1, (int)($_GET['page'] ?? 1));
$limit  = max(1, (int)($_GET['limit'] ?? 20));
$offset = ($page - 1) * $limit;

/* =====================
   DETAIL (BY ID)
===================== */
if ($id > 0) {
    $sql = "
        SELECT e.*, p.nama_lengkap AS author
        FROM edukasi e
        LEFT JOIN pengguna p ON p.id_pengguna = e.author_id
        WHERE e.id_edukasi = $id
        LIMIT 1
    ";
    $res = mysqli_query($koneksi, $sql);

    if (!$res || mysqli_num_rows($res) === 0) {
        json_response(false, 'Artikel tidak ditemukan', null, 404);
    }

    $r = mysqli_fetch_assoc($res);

    json_response(true, 'Detail edukasi', [
        'id'             => (int)$r['id_edukasi'],
        'title'          => $r['judul'],
        'konten'         => $r['konten'],
        'image_url'      => abs_url($r['gambar']),
        'video_url'      => $r['video_url'] ?: ($r['video_path'] ? abs_url($r['video_path']) : null),
        'video_path_url' => abs_url($r['video_path']),
        'author'         => $r['author'] ?? '-',
        'created_at'     => $r['created_at']
    ]);
}

/* =====================
   LIST
===================== */
$conditions = [];
if ($search !== '') {
    $s = mysqli_real_escape_string($koneksi, $search);
    $conditions[] = "(e.judul LIKE '%$s%' OR e.konten LIKE '%$s%')";
}

// Filter berdasarkan type: article = tanpa video_url, video = dengan video_url
if ($type === 'article') {
    $conditions[] = "(e.video_url IS NULL OR e.video_url = '')";
} elseif ($type === 'video') {
    $conditions[] = "(e.video_url IS NOT NULL AND e.video_url != '')";
}

$where = '';
if (!empty($conditions)) {
    $where = 'WHERE ' . implode(' AND ', $conditions);
}

$sql = "
    SELECT e.*, p.nama_lengkap AS author
    FROM edukasi e
    LEFT JOIN pengguna p ON p.id_pengguna = e.author_id
    $where
    ORDER BY e.created_at DESC
    LIMIT $limit OFFSET $offset
";
$res = mysqli_query($koneksi, $sql);

$items = [];
while ($r = mysqli_fetch_assoc($res)) {
    $items[] = [
        'id'        => (int)$r['id_edukasi'],
        'title'     => $r['judul'],
        'excerpt'   => mb_strimwidth(strip_tags($r['konten']), 0, 160, '...'),
        'konten'    => $r['konten'],
        'image_url' => abs_url($r['gambar']),
        'video_url' => $r['video_url'] ?: ($r['video_path'] ? abs_url($r['video_path']) : null),
        'author'    => $r['author'] ?? '-',
        'created_at'=> $r['created_at']
    ];
}

json_response(true, 'List edukasi', $items);
