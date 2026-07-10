<?php
// modules/api/driver_api.php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
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

$action = isset($_GET['action']) ? $_GET['action'] : '';

// Ambil Header Authorization
$headers = getallheaders();
$auth_header = isset($headers['Authorization']) ? $headers['Authorization'] : '';
if (empty($auth_header)) {
    api_respond(false, 'Token tidak ditemukan', null, 401);
}
list($bearer, $token) = explode(' ', $auth_header);
if ($bearer !== 'Bearer' || empty($token)) {
    api_respond(false, 'Format token tidak valid', null, 401);
}

// Cek token valid
$query = "SELECT id_pengguna, level FROM pengguna WHERE api_token = ? LIMIT 1";
$stmt = mysqli_prepare($koneksi, $query);
mysqli_stmt_bind_param($stmt, "s", $token);
mysqli_stmt_execute($stmt);
$result = mysqli_stmt_get_result($stmt);
if ($user = mysqli_fetch_assoc($result)) {
    if ($user['level'] !== 'driver') {
        api_respond(false, 'Akses ditolak, bukan driver', null, 403);
    }
    $id_driver = $user['id_pengguna'];
} else {
    api_respond(false, 'Token tidak valid atau expired', null, 401);
}
mysqli_stmt_close($stmt);

// ACTION: get_active_task
if ($action === 'get_active_task') {
    // Ambil tugas yang di-assign ke driver ini, statusnya 'accepted' atau 'on_the_way'
    $sql = "SELECT o.id_order, o.alamat_jemput, o.latitude, o.longitude, o.tanggal_order, 
                   o.waktu_jemput_dari, o.waktu_jemput_sampai, o.estimasi_berat, o.status,
                   w.nama_lengkap as nama_warga, w.no_telepon as telp_warga
            FROM orders o
            JOIN pengguna w ON o.id_warga = w.id_pengguna
            WHERE o.id_driver = ? AND o.status IN ('accepted', 'on_the_way', 'picked_up')
            ORDER BY o.created_at ASC LIMIT 1";
            
    $stmt_order = mysqli_prepare($koneksi, $sql);
    mysqli_stmt_bind_param($stmt_order, "i", $id_driver);
    mysqli_stmt_execute($stmt_order);
    $res_order = mysqli_stmt_get_result($stmt_order);
    
    if ($order = mysqli_fetch_assoc($res_order)) {
        // Cari jenis sampah detail jika mau
        $jenis_sql = "SELECT js.nama_sampah FROM order_items oi JOIN jenis_sampah js ON oi.id_jenis_sampah = js.id_jenis_sampah WHERE oi.id_order = ?";
        $stmt_j = mysqli_prepare($koneksi, $jenis_sql);
        mysqli_stmt_bind_param($stmt_j, "i", $order['id_order']);
        mysqli_stmt_execute($stmt_j);
        $res_j = mysqli_stmt_get_result($stmt_j);
        $jenis_list = [];
        while($rj = mysqli_fetch_assoc($res_j)) {
            $jenis_list[] = $rj['nama_sampah'];
        }
        $order['jenis_sampah'] = implode(', ', $jenis_list);
        mysqli_stmt_close($stmt_j);

        api_respond(true, 'Tugas aktif ditemukan', $order);
    } else {
        api_respond(true, 'Tidak ada tugas aktif', null);
    }
    mysqli_stmt_close($stmt_order);
}
// ACTION: get_notifications
elseif ($action === 'get_notifications') {
    $sql = "SELECT id_notifikasi, judul, pesan, tipe, is_read, created_at 
            FROM notifikasi 
            WHERE id_pengguna = ? 
            ORDER BY created_at DESC LIMIT 20";
    $stmt_notif = mysqli_prepare($koneksi, $sql);
    mysqli_stmt_bind_param($stmt_notif, "i", $id_driver);
    mysqli_stmt_execute($stmt_notif);
    $res_notif = mysqli_stmt_get_result($stmt_notif);
    
    $notifs = [];
    while($row = mysqli_fetch_assoc($res_notif)) {
        $notifs[] = $row;
    }
    api_respond(true, 'Berhasil memuat notifikasi', $notifs);
}
else {
    api_respond(false, 'Action tidak valid', null, 400);
}
?>
