<?php
// modules/api/driver_api.php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, OPTIONS');
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

$action = isset($_GET['action']) ? trim($_GET['action']) : '';

// Ambil Header Authorization
$headers = getallheaders(); 
$auth_header = '';
foreach ($headers as $k => $v) {
    if (strtolower($k) === 'authorization') {
        $auth_header = $v;
        break;
    }
}
if (empty($auth_header)) {
    api_respond(false, 'Token tidak ditemukan', null, 401);
}
$parts = explode(' ', $auth_header);
if (count($parts) != 2 || $parts[0] !== 'Bearer' || empty($parts[1])) {
    api_respond(false, 'Format token tidak valid', null, 401);
}
$token = $parts[1];

// Cek token valid
$query = "SELECT id_pengguna, level, nama_lengkap, email, no_telepon FROM pengguna WHERE api_token = ? LIMIT 1";
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
// ACTION: get_dashboard_stats
elseif ($action === 'get_dashboard_stats') {
    $sql_completed = "SELECT COUNT(*) as total_completed, COALESCE(SUM(estimasi_berat), 0) as total_berat FROM orders WHERE id_driver = ? AND status = 'completed'";
    $stmt_c = mysqli_prepare($koneksi, $sql_completed);
    mysqli_stmt_bind_param($stmt_c, "i", $id_driver);
    mysqli_stmt_execute($stmt_c);
    $res_c = mysqli_stmt_get_result($stmt_c);
    $row_c = mysqli_fetch_assoc($res_c);
    mysqli_stmt_close($stmt_c);

    $sql_today = "SELECT COUNT(*) as today_orders FROM orders WHERE id_driver = ? AND (tanggal_order = CURDATE() OR DATE(created_at) = CURDATE())";
    $stmt_t = mysqli_prepare($koneksi, $sql_today);
    mysqli_stmt_bind_param($stmt_t, "i", $id_driver);
    mysqli_stmt_execute($stmt_t);
    $res_t = mysqli_stmt_get_result($stmt_t);
    $row_t = mysqli_fetch_assoc($res_t);
    mysqli_stmt_close($stmt_t);

    $sql_pending = "SELECT COUNT(*) as pending_orders FROM orders WHERE id_driver = ? AND status IN ('accepted', 'on_the_way')";
    $stmt_p = mysqli_prepare($koneksi, $sql_pending);
    mysqli_stmt_bind_param($stmt_p, "i", $id_driver);
    mysqli_stmt_execute($stmt_p);
    $res_p = mysqli_stmt_get_result($stmt_p);
    $row_p = mysqli_fetch_assoc($res_p);
    mysqli_stmt_close($stmt_p);

    api_respond(true, 'Statistik berhasil dimuat', [
        'total_completed' => (int)$row_c['total_completed'],
        'total_berat' => (float)$row_c['total_berat'],
        'today_orders' => (int)$row_t['today_orders'],
        'pending_orders' => (int)$row_p['pending_orders'],
        'rating' => 4.9
    ]);
}
// ACTION: get_orders
elseif ($action === 'get_orders') {
    $status_filter = isset($_GET['status']) ? trim($_GET['status']) : '';
    $sql = "SELECT o.id_order, o.alamat_jemput, o.latitude, o.longitude, o.tanggal_order, 
                   o.waktu_jemput_dari, o.waktu_jemput_sampai, o.estimasi_berat, o.status,
                   w.nama_lengkap as nama_warga, w.no_telepon as telp_warga
            FROM orders o
            JOIN pengguna w ON o.id_warga = w.id_pengguna
            WHERE o.id_driver = ? ";
    if (!empty($status_filter)) {
        if ($status_filter === 'active') {
            $sql .= " AND o.status IN ('accepted', 'on_the_way', 'picked_up') ";
        } else {
            $sql .= " AND o.status = '" . mysqli_real_escape_string($koneksi, $status_filter) . "' ";
        }
    }
    $sql .= " ORDER BY o.created_at DESC";
    $stmt = mysqli_prepare($koneksi, $sql);
    mysqli_stmt_bind_param($stmt, "i", $id_driver);
    mysqli_stmt_execute($stmt);
    $res = mysqli_stmt_get_result($stmt);
    $orders = [];
    while($row = mysqli_fetch_assoc($res)) {
        $jenis_sql = "SELECT js.nama_sampah FROM order_items oi JOIN jenis_sampah js ON oi.id_jenis_sampah = js.id_jenis_sampah WHERE oi.id_order = ?";
        $stmt_j = mysqli_prepare($koneksi, $jenis_sql);
        mysqli_stmt_bind_param($stmt_j, "i", $row['id_order']);
        mysqli_stmt_execute($stmt_j);
        $res_j = mysqli_stmt_get_result($stmt_j);
        $jenis_list = [];
        while($rj = mysqli_fetch_assoc($res_j)) {
            $jenis_list[] = $rj['nama_sampah'];
        }
        $row['jenis_sampah'] = implode(', ', $jenis_list);
        if (empty($row['jenis_sampah'])) $row['jenis_sampah'] = 'Campuran';
        mysqli_stmt_close($stmt_j);
        $orders[] = $row;
    }
    mysqli_stmt_close($stmt);
    api_respond(true, 'Berhasil memuat daftar pesanan', $orders);
}
// ACTION: get_schedules
elseif ($action === 'get_schedules') {
    $sql = "SELECT o.id_order, o.alamat_jemput, o.tanggal_order, 
                   o.waktu_jemput_dari, o.waktu_jemput_sampai, o.estimasi_berat, o.status,
                   w.nama_lengkap as nama_warga, w.no_telepon as telp_warga
            FROM orders o
            JOIN pengguna w ON o.id_warga = w.id_pengguna
            WHERE o.id_driver = ? AND o.status NOT IN ('completed', 'cancelled')
            ORDER BY o.tanggal_order ASC, o.waktu_jemput_dari ASC";
    $stmt = mysqli_prepare($koneksi, $sql);
    mysqli_stmt_bind_param($stmt, "i", $id_driver);
    mysqli_stmt_execute($stmt);
    $res = mysqli_stmt_get_result($stmt);
    $schedules = [];
    while($row = mysqli_fetch_assoc($res)) {
        $jenis_sql = "SELECT js.nama_sampah FROM order_items oi JOIN jenis_sampah js ON oi.id_jenis_sampah = js.id_jenis_sampah WHERE oi.id_order = ?";
        $stmt_j = mysqli_prepare($koneksi, $jenis_sql);
        mysqli_stmt_bind_param($stmt_j, "i", $row['id_order']);
        mysqli_stmt_execute($stmt_j);
        $res_j = mysqli_stmt_get_result($stmt_j);
        $jenis_list = [];
        while($rj = mysqli_fetch_assoc($res_j)) {
            $jenis_list[] = $rj['nama_sampah'];
        }
        $row['jenis_sampah'] = implode(', ', $jenis_list);
        if (empty($row['jenis_sampah'])) $row['jenis_sampah'] = 'Campuran';
        mysqli_stmt_close($stmt_j);
        $schedules[] = $row;
    }
    mysqli_stmt_close($stmt);
    api_respond(true, 'Berhasil memuat jadwal penjemputan', $schedules);
}
// ACTION: get_history
elseif ($action === 'get_history') {
    $sql = "SELECT o.id_order, o.alamat_jemput, o.tanggal_order, o.created_at,
                   o.waktu_jemput_dari, o.waktu_jemput_sampai, o.estimasi_berat, o.berat_aktual, o.status,
                   w.nama_lengkap as nama_warga, w.no_telepon as telp_warga
            FROM orders o
            JOIN pengguna w ON o.id_warga = w.id_pengguna
            WHERE o.id_driver = ? AND o.status IN ('completed', 'cancelled')
            ORDER BY o.tanggal_order DESC, o.id_order DESC LIMIT 50";
    $stmt = mysqli_prepare($koneksi, $sql);
    mysqli_stmt_bind_param($stmt, "i", $id_driver);
    mysqli_stmt_execute($stmt);
    $res = mysqli_stmt_get_result($stmt);
    $history = [];
    while($row = mysqli_fetch_assoc($res)) {
        $jenis_sql = "SELECT js.nama_sampah FROM order_items oi JOIN jenis_sampah js ON oi.id_jenis_sampah = js.id_jenis_sampah WHERE oi.id_order = ?";
        $stmt_j = mysqli_prepare($koneksi, $jenis_sql);
        mysqli_stmt_bind_param($stmt_j, "i", $row['id_order']);
        mysqli_stmt_execute($stmt_j);
        $res_j = mysqli_stmt_get_result($stmt_j);
        $jenis_list = [];
        while($rj = mysqli_fetch_assoc($res_j)) {
            $jenis_list[] = $rj['nama_sampah'];
        }
        $row['jenis_sampah'] = implode(', ', $jenis_list);
        if (empty($row['jenis_sampah'])) $row['jenis_sampah'] = 'Campuran';
        mysqli_stmt_close($stmt_j);
        $history[] = $row;
    }
    mysqli_stmt_close($stmt);
    api_respond(true, 'Berhasil memuat riwayat', $history);
}
// ACTION: get_profile
elseif ($action === 'get_profile') {
    $sql = "SELECT p.id_pengguna, p.nama_lengkap, p.email, p.no_telepon, p.level,
                   d.tipe_kendaraan, d.jenis_kendaraan, d.plat_nomor, d.kapasitas_berat
            FROM pengguna p
            LEFT JOIN detail_driver d ON p.id_pengguna = d.id_pengguna
            WHERE p.id_pengguna = ?";
    $stmt = mysqli_prepare($koneksi, $sql);
    mysqli_stmt_bind_param($stmt, "i", $id_driver);
    mysqli_stmt_execute($stmt);
    $res = mysqli_stmt_get_result($stmt);
    $profile = mysqli_fetch_assoc($res);
    mysqli_stmt_close($stmt);

    $sql_c = "SELECT COUNT(*) as total_completed FROM orders WHERE id_driver = ? AND status = 'completed'";
    $stmt_c = mysqli_prepare($koneksi, $sql_c);
    mysqli_stmt_bind_param($stmt_c, "i", $id_driver);
    mysqli_stmt_execute($stmt_c);
    $res_c = mysqli_stmt_get_result($stmt_c);
    $row_c = mysqli_fetch_assoc($res_c);
    mysqli_stmt_close($stmt_c);

    $profile['total_completed'] = (int)$row_c['total_completed'];
    $profile['rating'] = 4.9;

    api_respond(true, 'Profil berhasil dimuat', $profile);
}
// ACTION: update_profile
elseif ($action === 'update_profile') {
    $input = json_decode(file_get_contents('php://input'), true);
    if (!$input) $input = $_POST;

    $nama = isset($input['nama_lengkap']) ? trim($input['nama_lengkap']) : $user['nama_lengkap'];
    $no_telepon = isset($input['no_telepon']) ? trim($input['no_telepon']) : $user['no_telepon'];
    $plat_nomor = isset($input['plat_nomor']) ? trim($input['plat_nomor']) : '';
    $jenis_kendaraan = isset($input['jenis_kendaraan']) ? trim($input['jenis_kendaraan']) : '';

    $stmt_u = mysqli_prepare($koneksi, "UPDATE pengguna SET nama_lengkap = ?, no_telepon = ? WHERE id_pengguna = ?");
    mysqli_stmt_bind_param($stmt_u, "ssi", $nama, $no_telepon, $id_driver);
    mysqli_stmt_execute($stmt_u);
    mysqli_stmt_close($stmt_u);

    // Cek atau update detail_driver
    $chk = mysqli_query($koneksi, "SELECT id_pengguna FROM detail_driver WHERE id_pengguna = $id_driver");
    if (mysqli_num_rows($chk) > 0) {
        $stmt_d = mysqli_prepare($koneksi, "UPDATE detail_driver SET plat_nomor = ?, jenis_kendaraan = ? WHERE id_pengguna = ?");
        mysqli_stmt_bind_param($stmt_d, "ssi", $plat_nomor, $jenis_kendaraan, $id_driver);
        mysqli_stmt_execute($stmt_d);
        mysqli_stmt_close($stmt_d);
    } else {
        $stmt_d = mysqli_prepare($koneksi, "INSERT INTO detail_driver (id_pengguna, plat_nomor, jenis_kendaraan) VALUES (?, ?, ?)");
        mysqli_stmt_bind_param($stmt_d, "iss", $id_driver, $plat_nomor, $jenis_kendaraan);
        mysqli_stmt_execute($stmt_d);
        mysqli_stmt_close($stmt_d);
    }

    api_respond(true, 'Profil berhasil diperbarui');
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
