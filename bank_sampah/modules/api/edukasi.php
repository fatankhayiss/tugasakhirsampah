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
    
    $scheme = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https' : 'http';
    $host = $_SERVER['HTTP_HOST'] ?? 'localhost';
    
    $script = $_SERVER['SCRIPT_NAME'] ?? '';
    $pos = strpos($script, 'bank_sampah');
    if ($pos !== false) {
        $base = substr($script, 0, $pos + 12); // 'bank_sampah/'
    } else {
        $base = '/';
    }
    
    $normalized = rtrim($base, '/') . '/' . ltrim($path, '/');
    return $scheme . '://' . $host . $normalized;
}

$action = $_POST['action'] ?? $_GET['action'] ?? 'read';

if ($_SERVER['REQUEST_METHOD'] === 'POST' && in_array($action, ['create', 'update', 'delete'])) {
    $id = isset($_POST['id']) ? (int)$_POST['id'] : 0;
    
    if ($action === 'delete') {
        if ($id <= 0) json_response(false, 'ID tidak valid', null, 400);
        $sql = "DELETE FROM edukasi WHERE id_edukasi = $id";
        if (mysqli_query($koneksi, $sql)) {
            json_response(true, 'Konten berhasil dihapus');
        } else {
            json_response(false, 'Gagal menghapus konten: ' . mysqli_error($koneksi), null, 500);
        }
    }
    
    $judul = mysqli_real_escape_string($koneksi, $_POST['judul'] ?? '');
    $konten = mysqli_real_escape_string($koneksi, $_POST['konten'] ?? '');
    $kategori = mysqli_real_escape_string($koneksi, $_POST['kategori'] ?? 'Umum');
    $status = mysqli_real_escape_string($koneksi, $_POST['status'] ?? 'draft');
    $video_url = mysqli_real_escape_string($koneksi, $_POST['video_url'] ?? '');
    $author_id = isset($_POST['author_id']) ? (int)$_POST['author_id'] : 1;
    
    $gambar = '';
    if (isset($_FILES['gambar']) && $_FILES['gambar']['error'] === UPLOAD_ERR_OK) {
        $uploadDir = __DIR__ . '/../../assets/uploads/';
        if (!is_dir($uploadDir)) mkdir($uploadDir, 0777, true);
        $filename = time() . '_' . basename($_FILES['gambar']['name']);
        if (move_uploaded_file($_FILES['gambar']['tmp_name'], $uploadDir . $filename)) {
            $gambar = 'tugasakhirsampah/bank_sampah/assets/uploads/' . $filename;
        }
    } else {
        $gambar = mysqli_real_escape_string($koneksi, $_POST['gambar_existing'] ?? '');
    }

    $video_path = '';
    if (isset($_FILES['video_file']) && $_FILES['video_file']['error'] === UPLOAD_ERR_OK) {
        $uploadDir = __DIR__ . '/../../assets/uploads/videos/';
        if (!is_dir($uploadDir)) mkdir($uploadDir, 0777, true);
        $filename = time() . '_' . basename($_FILES['video_file']['name']);
        if (move_uploaded_file($_FILES['video_file']['tmp_name'], $uploadDir . $filename)) {
            $video_path = 'tugasakhirsampah/bank_sampah/assets/uploads/videos/' . $filename;
        }
    } else {
        $video_path = mysqli_real_escape_string($koneksi, $_POST['video_path_existing'] ?? '');
    }

    if ($action === 'create') {
        $sql = "INSERT INTO edukasi (judul, konten, kategori, status, gambar, video_url, video_path, author_id) 
                VALUES ('$judul', '$konten', '$kategori', '$status', '$gambar', '$video_url', '$video_path', $author_id)";
        if (mysqli_query($koneksi, $sql)) {
            json_response(true, 'Konten berhasil ditambahkan', ['id' => mysqli_insert_id($koneksi)]);
        } else {
            json_response(false, 'Gagal menambah konten: ' . mysqli_error($koneksi), null, 500);
        }
    } elseif ($action === 'update') {
        if ($id <= 0) json_response(false, 'ID tidak valid', null, 400);
        
        $sql = "UPDATE edukasi SET 
                judul = '$judul', 
                konten = '$konten', 
                kategori = '$kategori', 
                status = '$status', 
                video_url = '$video_url', 
                author_id = $author_id";
                
        if ($gambar !== '') {
            $sql .= ", gambar = '$gambar'";
        }
        if ($video_path !== '') {
            $sql .= ", video_path = '$video_path'";
        }
        
        $sql .= " WHERE id_edukasi = $id";
        
        if (mysqli_query($koneksi, $sql)) {
            json_response(true, 'Konten berhasil diupdate');
        } else {
            json_response(false, 'Gagal mengupdate konten: ' . mysqli_error($koneksi), null, 500);
        }
    }
}

/* =====================
   READ (LIST / DETAIL)
===================== */
$id     = isset($_GET['id']) ? (int)$_GET['id'] : 0;
$search = trim($_GET['search'] ?? '');
$type   = trim($_GET['type'] ?? '');
$status = trim($_GET['status'] ?? 'published'); // Default published
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
        json_response(false, 'Konten tidak ditemukan', null, 404);
    }

    $r = mysqli_fetch_assoc($res);

    json_response(true, 'Detail edukasi', [
        'id'             => (int)$r['id_edukasi'],
        'title'          => $r['judul'],
        'konten'         => $r['konten'],
        'kategori'       => $r['kategori'],
        'status'         => $r['status'],
        'image_url'      => abs_url($r['gambar']),
        'video_url'      => $r['video_url'] ?: ($r['video_path'] ? abs_url($r['video_path']) : null),
        'video_path_url' => abs_url($r['video_path']),
        'author'         => $r['author'] ?? '-',
        'created_at'     => $r['created_at'],
        'updated_at'     => $r['updated_at']
    ]);
}

/* =====================
   LIST
===================== */
$conditions = [];

if ($status !== 'all') {
    $st = mysqli_real_escape_string($koneksi, $status);
    $conditions[] = "e.status = '$st'";
}

if ($search !== '') {
    $s = mysqli_real_escape_string($koneksi, $search);
    $conditions[] = "(e.judul LIKE '%$s%' OR e.konten LIKE '%$s%' OR e.kategori LIKE '%$s%')";
}

if ($type === 'article') {
    $conditions[] = "((e.video_url IS NULL OR e.video_url = '') AND (e.video_path IS NULL OR e.video_path = ''))";
} elseif ($type === 'video') {
    $conditions[] = "((e.video_url IS NOT NULL AND e.video_url != '') OR (e.video_path IS NOT NULL AND e.video_path != ''))";
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
        'kategori'  => $r['kategori'],
        'status'    => $r['status'],
        'image_url' => abs_url($r['gambar']),
        'video_url' => $r['video_url'] ?: ($r['video_path'] ? abs_url($r['video_path']) : null),
        'author'    => $r['author'] ?? '-',
        'created_at'=> $r['created_at'],
        'updated_at'=> $r['updated_at']
    ];
}

json_response(true, 'List edukasi', $items);
