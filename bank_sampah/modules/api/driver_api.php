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

// ============================================================
// ACTION: get_active_task
// ============================================================
if ($action === 'get_active_task') {
    $sql = "SELECT o.id_order, o.alamat_jemput, o.latitude, o.longitude, o.tanggal_order,
                   o.waktu_jemput_dari, o.waktu_jemput_sampai, o.estimasi_berat, o.status,
                   w.nama_lengkap as nama_warga, w.no_telepon as telp_warga
            FROM orders o
            JOIN pengguna w ON o.id_warga = w.id_pengguna
            WHERE o.id_driver = ? AND o.status IN ('DRIVER_DITUGASKAN','DRIVER_MENUJU_LOKASI','DRIVER_TIBA','SAMPAH_DIJEMPUT')
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
        while ($rj = mysqli_fetch_assoc($res_j)) { $jenis_list[] = $rj['nama_sampah']; }
        $order['jenis_sampah'] = !empty($jenis_list) ? implode(', ', $jenis_list) : 'Campuran';
        mysqli_stmt_close($stmt_j);
        api_respond(true, 'Tugas aktif ditemukan', $order);
    } else {
        api_respond(true, 'Tidak ada tugas aktif', null);
    }
    mysqli_stmt_close($stmt_order);
}

// ============================================================
// ACTION: get_dashboard_stats
// ============================================================
elseif ($action === 'get_dashboard_stats') {
    // Total completed (all time)
    $stmt_c = mysqli_prepare($koneksi, "SELECT COUNT(*) as total_completed, COALESCE(SUM(estimasi_berat),0) as total_berat FROM orders WHERE id_driver = ? AND status = 'SELESAI'");
    mysqli_stmt_bind_param($stmt_c, "i", $id_driver);
    mysqli_stmt_execute($stmt_c);
    $row_c = mysqli_fetch_assoc(mysqli_stmt_get_result($stmt_c));
    mysqli_stmt_close($stmt_c);

    // Today's total assigned
    $stmt_t = mysqli_prepare($koneksi, "SELECT COUNT(*) as today_orders FROM orders WHERE id_driver = ? AND tanggal_order = CURDATE()");
    mysqli_stmt_bind_param($stmt_t, "i", $id_driver);
    mysqli_stmt_execute($stmt_t);
    $row_t = mysqli_fetch_assoc(mysqli_stmt_get_result($stmt_t));
    mysqli_stmt_close($stmt_t);

    // Today's completed
    $stmt_td = mysqli_prepare($koneksi, "SELECT COUNT(*) as today_completed FROM orders WHERE id_driver = ? AND status = 'SELESAI' AND tanggal_order = CURDATE()");
    mysqli_stmt_bind_param($stmt_td, "i", $id_driver);
    mysqli_stmt_execute($stmt_td);
    $row_td = mysqli_fetch_assoc(mysqli_stmt_get_result($stmt_td));
    mysqli_stmt_close($stmt_td);

    // Today's total weight (completed)
    $stmt_tb = mysqli_prepare($koneksi, "SELECT COALESCE(SUM(estimasi_berat),0) as today_berat FROM orders WHERE id_driver = ? AND status = 'SELESAI' AND tanggal_order = CURDATE()");
    mysqli_stmt_bind_param($stmt_tb, "i", $id_driver);
    mysqli_stmt_execute($stmt_tb);
    $row_tb = mysqli_fetch_assoc(mysqli_stmt_get_result($stmt_tb));
    mysqli_stmt_close($stmt_tb);

    // Pending (in progress)
    $stmt_p = mysqli_prepare($koneksi, "SELECT COUNT(*) as pending_orders FROM orders WHERE id_driver = ? AND status IN ('DRIVER_DITUGASKAN','DRIVER_MENUJU_LOKASI','DRIVER_TIBA','SAMPAH_DIJEMPUT')");
    mysqli_stmt_bind_param($stmt_p, "i", $id_driver);
    mysqli_stmt_execute($stmt_p);
    $row_p = mysqli_fetch_assoc(mysqli_stmt_get_result($stmt_p));
    mysqli_stmt_close($stmt_p);

    api_respond(true, 'Statistik berhasil dimuat', [
        'total_completed' => (int)$row_c['total_completed'],
        'total_berat'     => (float)$row_c['total_berat'],
        'today_orders'    => (int)$row_t['today_orders'],
        'today_completed' => (int)$row_td['today_completed'],
        'today_berat'     => (float)$row_tb['today_berat'],
        'pending_orders'  => (int)$row_p['pending_orders'],
    ]);
}

// ============================================================
// ACTION: get_orders
// ============================================================
elseif ($action === 'get_orders') {
    $status_filter = isset($_GET['status']) ? trim($_GET['status']) : '';
    $sql = "SELECT o.id_order, o.alamat_jemput, o.latitude, o.longitude, o.tanggal_order,
                   o.waktu_jemput_dari, o.waktu_jemput_sampai, o.estimasi_berat, o.status,
                   w.nama_lengkap as nama_warga, w.no_telepon as telp_warga
            FROM orders o
            JOIN pengguna w ON o.id_warga = w.id_pengguna
            WHERE o.id_driver = ?";
    if (!empty($status_filter)) {
        if ($status_filter === 'active') {
            $sql .= " AND o.status IN ('DRIVER_DITUGASKAN','DRIVER_MENUJU_LOKASI','DRIVER_TIBA','SAMPAH_DIJEMPUT')";
        } else {
            $sql .= " AND o.status = '" . mysqli_real_escape_string($koneksi, $status_filter) . "'";
        }
    }
    $sql .= " ORDER BY o.created_at DESC";
    $stmt = mysqli_prepare($koneksi, $sql);
    mysqli_stmt_bind_param($stmt, "i", $id_driver);
    mysqli_stmt_execute($stmt);
    $res = mysqli_stmt_get_result($stmt);
    $orders = [];
    while ($row = mysqli_fetch_assoc($res)) {
        $stmt_j = mysqli_prepare($koneksi, "SELECT js.nama_sampah FROM order_items oi JOIN jenis_sampah js ON oi.id_jenis_sampah = js.id_jenis_sampah WHERE oi.id_order = ?");
        mysqli_stmt_bind_param($stmt_j, "i", $row['id_order']);
        mysqli_stmt_execute($stmt_j);
        $res_j = mysqli_stmt_get_result($stmt_j);
        $jl = [];
        while ($rj = mysqli_fetch_assoc($res_j)) { $jl[] = $rj['nama_sampah']; }
        $row['jenis_sampah'] = !empty($jl) ? implode(', ', $jl) : 'Campuran';
        mysqli_stmt_close($stmt_j);
        $orders[] = $row;
    }
    mysqli_stmt_close($stmt);
    api_respond(true, 'Berhasil memuat daftar pesanan', $orders);
}

// ============================================================
// ACTION: get_schedules
// ============================================================
elseif ($action === 'get_schedules') {
    $sql = "SELECT o.id_order, o.alamat_jemput, o.tanggal_order,
                   o.waktu_jemput_dari, o.waktu_jemput_sampai, o.estimasi_berat, o.status,
                   w.nama_lengkap as nama_warga, w.no_telepon as telp_warga
            FROM orders o
            JOIN pengguna w ON o.id_warga = w.id_pengguna
            WHERE o.id_driver = ? AND o.status NOT IN ('SELESAI','DIBATALKAN')
            ORDER BY o.tanggal_order ASC, o.waktu_jemput_dari ASC";
    $stmt = mysqli_prepare($koneksi, $sql);
    mysqli_stmt_bind_param($stmt, "i", $id_driver);
    mysqli_stmt_execute($stmt);
    $res = mysqli_stmt_get_result($stmt);
    $schedules = [];
    while ($row = mysqli_fetch_assoc($res)) {
        $stmt_j = mysqli_prepare($koneksi, "SELECT js.nama_sampah FROM order_items oi JOIN jenis_sampah js ON oi.id_jenis_sampah = js.id_jenis_sampah WHERE oi.id_order = ?");
        mysqli_stmt_bind_param($stmt_j, "i", $row['id_order']);
        mysqli_stmt_execute($stmt_j);
        $res_j = mysqli_stmt_get_result($stmt_j);
        $jl = [];
        while ($rj = mysqli_fetch_assoc($res_j)) { $jl[] = $rj['nama_sampah']; }
        $row['jenis_sampah'] = !empty($jl) ? implode(', ', $jl) : 'Campuran';
        mysqli_stmt_close($stmt_j);
        $schedules[] = $row;
    }
    mysqli_stmt_close($stmt);
    api_respond(true, 'Berhasil memuat jadwal penjemputan', $schedules);
}

// ============================================================
// ACTION: get_history
// ============================================================
elseif ($action === 'get_history') {
    $sql = "SELECT o.id_order, o.alamat_jemput, o.tanggal_order, o.created_at,
                   o.waktu_jemput_dari, o.waktu_jemput_sampai, o.estimasi_berat, o.berat_aktual, o.status,
                   w.nama_lengkap as nama_warga, w.no_telepon as telp_warga
            FROM orders o
            JOIN pengguna w ON o.id_warga = w.id_pengguna
            WHERE o.id_driver = ? AND o.status IN ('SELESAI','DIBATALKAN')
            ORDER BY o.tanggal_order DESC, o.id_order DESC LIMIT 50";
    $stmt = mysqli_prepare($koneksi, $sql);
    mysqli_stmt_bind_param($stmt, "i", $id_driver);
    mysqli_stmt_execute($stmt);
    $res = mysqli_stmt_get_result($stmt);
    $history = [];
    while ($row = mysqli_fetch_assoc($res)) {
        $stmt_j = mysqli_prepare($koneksi, "SELECT js.nama_sampah FROM order_items oi JOIN jenis_sampah js ON oi.id_jenis_sampah = js.id_jenis_sampah WHERE oi.id_order = ?");
        mysqli_stmt_bind_param($stmt_j, "i", $row['id_order']);
        mysqli_stmt_execute($stmt_j);
        $res_j = mysqli_stmt_get_result($stmt_j);
        $jl = [];
        while ($rj = mysqli_fetch_assoc($res_j)) { $jl[] = $rj['nama_sampah']; }
        $row['jenis_sampah'] = !empty($jl) ? implode(', ', $jl) : 'Campuran';
        mysqli_stmt_close($stmt_j);
        $history[] = $row;
    }
    mysqli_stmt_close($stmt);
    api_respond(true, 'Berhasil memuat riwayat', $history);
}

// ============================================================
// ACTION: get_profile
// ============================================================
elseif ($action === 'get_profile') {
    $sql = "SELECT p.id_pengguna, p.nama_lengkap, p.email, p.username, p.no_telepon, p.level, p.foto_profil,
                   COALESCE(p.driver_status, 'offline') as driver_status,
                   d.tipe_kendaraan, d.jenis_kendaraan, d.plat_nomor, d.kapasitas_berat
            FROM pengguna p
            LEFT JOIN detail_driver d ON p.id_pengguna = d.id_pengguna
            WHERE p.id_pengguna = ?";
    $stmt = mysqli_prepare($koneksi, $sql);
    mysqli_stmt_bind_param($stmt, "i", $id_driver);
    mysqli_stmt_execute($stmt);
    $profile = mysqli_fetch_assoc(mysqli_stmt_get_result($stmt));
    mysqli_stmt_close($stmt);

    $stmt_c = mysqli_prepare($koneksi, "SELECT COUNT(*) as total_completed FROM orders WHERE id_driver = ? AND status = 'SELESAI'");
    mysqli_stmt_bind_param($stmt_c, "i", $id_driver);
    mysqli_stmt_execute($stmt_c);
    $row_c = mysqli_fetch_assoc(mysqli_stmt_get_result($stmt_c));
    mysqli_stmt_close($stmt_c);
    $profile['total_completed'] = (int)$row_c['total_completed'];

    // Kendaraan hari ini dari driver_daily_vehicle
    $vehicle_row = null;
    $stmt_v = mysqli_prepare($koneksi, "SELECT vehicle_type, license_plate, capacity, notes FROM driver_daily_vehicle WHERE driver_id = ? AND date = CURDATE() LIMIT 1");
    if ($stmt_v) {
        mysqli_stmt_bind_param($stmt_v, "i", $id_driver);
        mysqli_stmt_execute($stmt_v);
        $vehicle_row = mysqli_fetch_assoc(mysqli_stmt_get_result($stmt_v));
        mysqli_stmt_close($stmt_v);
    }
    $profile['today_vehicle'] = $vehicle_row ?? null;

    api_respond(true, 'Profil berhasil dimuat', $profile);
}

// ============================================================
// ACTION: update_profile (legacy — kept for compatibility)
// ============================================================
elseif ($action === 'update_profile') {
    $input = json_decode(file_get_contents('php://input'), true);
    if (!$input) $input = $_POST;

    $nama       = isset($input['nama_lengkap'])  ? trim($input['nama_lengkap'])  : $user['nama_lengkap'];
    $no_telepon = isset($input['no_telepon'])     ? trim($input['no_telepon'])    : $user['no_telepon'];
    $plat_nomor = isset($input['plat_nomor'])     ? trim($input['plat_nomor'])    : '';
    $jenis_kend = isset($input['jenis_kendaraan'])? trim($input['jenis_kendaraan']): '';

    $stmt_u = mysqli_prepare($koneksi, "UPDATE pengguna SET nama_lengkap = ?, no_telepon = ? WHERE id_pengguna = ?");
    mysqli_stmt_bind_param($stmt_u, "ssi", $nama, $no_telepon, $id_driver);
    mysqli_stmt_execute($stmt_u);
    mysqli_stmt_close($stmt_u);

    $chk = mysqli_query($koneksi, "SELECT id_pengguna FROM detail_driver WHERE id_pengguna = $id_driver");
    if (mysqli_num_rows($chk) > 0) {
        $stmt_d = mysqli_prepare($koneksi, "UPDATE detail_driver SET plat_nomor = ?, jenis_kendaraan = ? WHERE id_pengguna = ?");
        mysqli_stmt_bind_param($stmt_d, "ssi", $plat_nomor, $jenis_kend, $id_driver);
    } else {
        $stmt_d = mysqli_prepare($koneksi, "INSERT INTO detail_driver (id_pengguna, plat_nomor, jenis_kendaraan) VALUES (?, ?, ?)");
        mysqli_stmt_bind_param($stmt_d, "iss", $id_driver, $plat_nomor, $jenis_kend);
    }
    mysqli_stmt_execute($stmt_d);
    mysqli_stmt_close($stmt_d);
    api_respond(true, 'Profil berhasil diperbarui');
}

// ============================================================
// ACTION: get_notifications
// ============================================================
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
    while ($row = mysqli_fetch_assoc($res_notif)) { $notifs[] = $row; }
    api_respond(true, 'Berhasil memuat notifikasi', $notifs);
}

// ============================================================
// ACTION: get_daily_vehicle
// ============================================================
elseif ($action === 'get_daily_vehicle') {
    $stmt = mysqli_prepare($koneksi, "SELECT id, vehicle_type, license_plate, capacity, notes, date FROM driver_daily_vehicle WHERE driver_id = ? AND date = CURDATE() LIMIT 1");
    if (!$stmt) {
        api_respond(true, 'Kendaraan belum didaftarkan', null);
    }
    mysqli_stmt_bind_param($stmt, "i", $id_driver);
    mysqli_stmt_execute($stmt);
    $vehicle = mysqli_fetch_assoc(mysqli_stmt_get_result($stmt));
    mysqli_stmt_close($stmt);
    api_respond(true, $vehicle ? 'Kendaraan hari ini ditemukan' : 'Kendaraan belum didaftarkan', $vehicle ?? null);
}

// ============================================================
// ACTION: save_daily_vehicle
// ============================================================
elseif ($action === 'save_daily_vehicle') {
    $input = json_decode(file_get_contents('php://input'), true);
    if (!$input) $input = $_POST;

    $vehicle_type  = isset($input['vehicle_type'])  ? trim($input['vehicle_type'])  : '';
    $license_plate = isset($input['license_plate']) ? trim($input['license_plate']) : '';
    $capacity      = isset($input['capacity'])      ? trim($input['capacity'])      : '';
    $notes         = isset($input['notes'])         ? trim($input['notes'])         : '';

    if (empty($vehicle_type) || empty($license_plate)) {
        api_respond(false, 'Jenis kendaraan dan plat nomor wajib diisi', null, 400);
    }

    $sql = "INSERT INTO driver_daily_vehicle (driver_id, vehicle_type, license_plate, capacity, notes, date)
            VALUES (?, ?, ?, ?, ?, CURDATE())
            ON DUPLICATE KEY UPDATE
              vehicle_type = VALUES(vehicle_type),
              license_plate = VALUES(license_plate),
              capacity = VALUES(capacity),
              notes = VALUES(notes)";
    $stmt = mysqli_prepare($koneksi, $sql);
    if (!$stmt) {
        api_respond(false, 'Tabel kendaraan belum tersedia. Jalankan migrasi database terlebih dahulu.', null, 500);
    }
    mysqli_stmt_bind_param($stmt, "issss", $id_driver, $vehicle_type, $license_plate, $capacity, $notes);
    if (mysqli_stmt_execute($stmt)) {
        mysqli_stmt_close($stmt);
        api_respond(true, 'Kendaraan hari ini berhasil disimpan', [
            'vehicle_type'  => $vehicle_type,
            'license_plate' => $license_plate,
            'capacity'      => $capacity,
            'notes'         => $notes,
        ]);
    } else {
        api_respond(false, 'Gagal menyimpan: ' . mysqli_error($koneksi), null, 500);
    }
}

// ============================================================
// ACTION: get_driver_status
// ============================================================
elseif ($action === 'get_driver_status') {
    $stmt = mysqli_prepare($koneksi, "SELECT COALESCE(driver_status, 'offline') as driver_status FROM pengguna WHERE id_pengguna = ? AND level = 'driver'");
    mysqli_stmt_bind_param($stmt, "i", $id_driver);
    mysqli_stmt_execute($stmt);
    $res = mysqli_stmt_get_result($stmt);
    $row = mysqli_fetch_assoc($res);
    mysqli_stmt_close($stmt);

    $driverStatus = $row['driver_status'] ?? 'offline';
    api_respond(true, 'Berhasil mengambil status driver', [
        'driver_status' => $driverStatus
    ]);
}

// ============================================================
// ACTION: update_driver_status
// ============================================================
elseif ($action === 'update_driver_status') {
    $input = json_decode(file_get_contents('php://input'), true);
    if (!$input) $input = $_POST;

    $status = isset($input['driver_status']) ? trim(strtolower($input['driver_status'])) : '';
    $valid_statuses = ['online', 'offline'];

    if (!in_array($status, $valid_statuses)) {
        api_respond(false, 'Status tidak valid. Pilih: online atau offline', null, 400);
    }

    $stmt = mysqli_prepare($koneksi, "UPDATE pengguna SET driver_status = ? WHERE id_pengguna = ? AND level = 'driver'");
    mysqli_stmt_bind_param($stmt, "si", $status, $id_driver);
    if (mysqli_stmt_execute($stmt)) {
        mysqli_stmt_close($stmt);
        api_respond(true, 'Status driver berhasil diperbarui', [
            'driver_status' => $status
        ]);
    } else {
        api_respond(false, 'Gagal memperbarui status: ' . mysqli_error($koneksi), null, 500);
    }
}

else {
    api_respond(false, 'Action tidak valid', null, 400);
}
?>
