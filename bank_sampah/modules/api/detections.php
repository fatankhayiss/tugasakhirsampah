<?php
// modules/api/detections.php
// Endpoint untuk mengambil riwayat deteksi
// Support params (GET): detection_id, user_id, limit, page
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    echo json_encode(['success' => true]);
    exit;
}

require_once __DIR__ . '/../../config/database.php';

function respond($success, $message, $data = null, $code = 200) {
    http_response_code($code);
    echo json_encode(array_filter([
        'success' => $success,
        'message' => $message,
        'data' => $data
    ], function($v){ return $v !== null; }));
    exit;
}

$detection_id = isset($_GET['detection_id']) ? (int)$_GET['detection_id'] : null;
$user_id = isset($_GET['user_id']) ? (int)$_GET['user_id'] : null;
$limit = isset($_GET['limit']) ? max(1,(int)$_GET['limit']) : 20;
$page = isset($_GET['page']) ? max(1,(int)$_GET['page']) : 1;
$offset = ($page - 1) * $limit;

// check if table exists
$tbl = 'deteksi';
$q = mysqli_query($koneksi, "SELECT COUNT(*) as cnt FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = '". mysqli_real_escape_string($koneksi, $tbl) ."'");
$exists = false;
if ($q) {
    $r = mysqli_fetch_assoc($q);
    $exists = ($r['cnt'] > 0);
}

if (!$exists) {
    // Inform user how to create table
    $path = 'modules/api/create_table_deteksi.sql';
    respond(false, "Tabel '$tbl' tidak ditemukan. Jalankan file SQL: $path untuk membuat tabel deteksi.", ['create_sql' => $path], 404);
}

// Build query
if ($detection_id) {
    $sql = "SELECT * FROM `deteksi` WHERE `id_deteksi` = " . intval($detection_id) . " LIMIT 1";
    $res = mysqli_query($koneksi, $sql);
    if ($res && mysqli_num_rows($res) > 0) {
        $row = mysqli_fetch_assoc($res);
        respond(true, 'Deteksi ditemukan', $row, 200);
    } else {
        respond(false, 'Deteksi tidak ditemukan', null, 404);
    }
} else {
    $where = [];
    if ($user_id) $where[] = "id_pengguna = " . intval($user_id);
    $where_sql = '';
    if (!empty($where)) $where_sql = 'WHERE ' . implode(' AND ', $where);

    $count_sql = "SELECT COUNT(*) as total FROM `deteksi` $where_sql";
    $cnt_res = mysqli_query($koneksi, $count_sql);
    $total = 0;
    if ($cnt_res) { $cnt_row = mysqli_fetch_assoc($cnt_res); $total = (int)$cnt_row['total']; }

    $sql = "SELECT * FROM `deteksi` $where_sql ORDER BY created_at DESC LIMIT " . intval($limit) . " OFFSET " . intval($offset);
    $res = mysqli_query($koneksi, $sql);
    $items = [];
    if ($res) {
        while ($r = mysqli_fetch_assoc($res)) {
            $items[] = $r;
        }
    }

    $data = [
        'total' => $total,
        'page' => $page,
        'limit' => $limit,
        'items' => $items
    ];
    respond(true, 'Daftar deteksi', $data, 200);
}
