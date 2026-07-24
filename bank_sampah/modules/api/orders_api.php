<?php
// modules/api/orders_api.php
// Endpoint CRUD orders penjemputan
// GET  — List orders (filter by user_id, driver_id, status)
// POST — Buat order baru (warga)
// PUT  — Update status order (driver / admin)
error_reporting(0);
ini_set('display_errors', '0');
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

if (!isset($raw_input) || empty($raw_input)) {
    $raw_input = file_get_contents('php://input');
}

function api_respond($success, $message, $data = null, $code = 200) {
    if (ob_get_length()) ob_clean();
    if ($code !== 200) {
        http_response_code($code);
    }
    header('Content-Type: application/json; charset=utf-8');
    $response = ['success' => $success, 'message' => $message];
    if ($data !== null) $response['data'] = $data;
    echo json_encode($response, JSON_UNESCAPED_UNICODE);
    exit;
}

function get_auth_user($koneksi) {
    global $raw_input;
    $token = null;
    if (isset($_SERVER['HTTP_AUTHORIZATION'])) {
        $token = str_replace('Bearer ', '', $_SERVER['HTTP_AUTHORIZATION']);
    } elseif (isset($_SERVER['REDIRECT_HTTP_AUTHORIZATION'])) {
        $token = str_replace('Bearer ', '', $_SERVER['REDIRECT_HTTP_AUTHORIZATION']);
    } else {
        $headers = function_exists('getallheaders') ? getallheaders() : [];
        foreach ($headers as $key => $value) {
            if (strtolower($key) === 'authorization') {
                $token = str_replace('Bearer ', '', $value);
                break;
            }
        }
    }
    if (!$token && isset($_GET['token'])) $token = $_GET['token'];
    if (!$token && isset($_POST['token'])) $token = $_POST['token'];
    if (!$token && !empty($raw_input)) {
        $json = json_decode($raw_input, true);
        if ($json && isset($json['token'])) $token = $json['token'];
    }
    
    if (!$token) return null;

    $stmt = mysqli_prepare($koneksi, "SELECT id_pengguna, level FROM pengguna WHERE api_token = ? LIMIT 1");
    if (!$stmt) {
        @file_put_contents('C:/Users/Kevin/.gemini/antigravity-ide/brain/438c7f10-cb6b-47c1-a497-f19002dee1b4/scratch/debug.log', "Prepare failed: " . mysqli_error($koneksi) . "\n", FILE_APPEND);
        return null;
    }
    mysqli_stmt_bind_param($stmt, "s", $token);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);
    $user = $result ? mysqli_fetch_assoc($result) : null;
    mysqli_stmt_close($stmt);
    return $user;
}

$auth_user = get_auth_user($koneksi);

// =====================
// GET — List orders
// =====================
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $user_id = isset($_GET['user_id']) ? (int)$_GET['user_id'] : null;
    $driver_id = isset($_GET['driver_id']) ? (int)$_GET['driver_id'] : null;
    $status = isset($_GET['status']) ? $_GET['status'] : null;
    $raw_id = isset($_GET['id']) ? trim($_GET['id']) : null;
    $has_id_param = ($raw_id !== null && $raw_id !== '');
    $order_id = $has_id_param ? (int)preg_replace('/[^\d]/', '', $raw_id) : null;
    $page = max(1, (int)($_GET['page'] ?? 1));
    $limit = max(1, (int)($_GET['limit'] ?? 20));
    $offset = ($page - 1) * $limit;

    // Detail single order if id query parameter was provided
    if ($has_id_param) {
        if (!$order_id) {
            api_respond(false, 'Order tidak ditemukan', null, 404);
        }
        $sql = "SELECT o.*, 
                       w.nama_lengkap as nama_warga, w.no_telepon as telp_warga, w.alamat as alamat_warga, w.foto_profil as foto_warga,
                       d.nama_lengkap as nama_driver, d.no_telepon as telp_driver, d.foto_profil as foto_driver, d.username as driver_username, d.driver_status as driver_online_status,
                       COALESCE(dv.vehicle_name, dv.vehicle_type) as jenis_kendaraan,
                       dv.license_plate as plat_nomor
                FROM orders o
                LEFT JOIN pengguna w ON o.id_warga = w.id_pengguna
                LEFT JOIN pengguna d ON o.id_driver = d.id_pengguna
                LEFT JOIN driver_daily_vehicle dv ON d.id_pengguna = dv.driver_id AND dv.date = CURDATE()
                WHERE o.id_order = ?";
        $stmt = mysqli_prepare($koneksi, $sql);
        mysqli_stmt_bind_param($stmt, "i", $order_id);
        mysqli_stmt_execute($stmt);
        $result = mysqli_stmt_get_result($stmt);
        $order = mysqli_fetch_assoc($result);
        mysqli_stmt_close($stmt);

        if (!$order) {
            api_respond(false, 'Order tidak ditemukan', null, 404);
        }

        // Get order items
        $items_sql = "SELECT oi.*, js.nama_sampah, js.harga_per_kg
                      FROM order_items oi
                      LEFT JOIN jenis_sampah js ON oi.id_jenis_sampah = js.id_jenis_sampah
                      WHERE oi.id_order = ?";
        $stmt_i = mysqli_prepare($koneksi, $items_sql);
        mysqli_stmt_bind_param($stmt_i, "i", $order_id);
        mysqli_stmt_execute($stmt_i);
        $ir = mysqli_stmt_get_result($stmt_i);
        $items = [];
        while ($item = mysqli_fetch_assoc($ir)) {
            $items[] = [
                'id' => (int)$item['id_order_item'],
                'nama_sampah' => $item['nama_sampah'],
                'harga_per_kg' => floatval($item['harga_per_kg']),
                'estimasi_berat_kg' => floatval($item['estimasi_berat_kg']),
                'berat_aktual_kg' => $item['berat_aktual_kg'] !== null ? floatval($item['berat_aktual_kg']) : null,
            ];
        }
        mysqli_stmt_close($stmt_i);

        $base_url = "http://192.168.110.61/tugasakhirsampah/bank_sampah/";
        $base_upload_url = $base_url . "assets/uploads/";

        $foto_warga = $order['foto_warga'];
        if ($foto_warga) {
            if (str_starts_with($foto_warga, 'http://') || str_starts_with($foto_warga, 'https://')) {
                $foto_warga_full = $foto_warga;
            } elseif (str_starts_with($foto_warga, 'assets/')) {
                $foto_warga_full = $base_url . $foto_warga;
            } else {
                $foto_warga_full = $base_upload_url . $foto_warga;
            }
        } else {
            $foto_warga_full = null;
        }

        $foto_driver = $order['foto_driver'];
        if ($foto_driver) {
            if (str_starts_with($foto_driver, 'http://') || str_starts_with($foto_driver, 'https://')) {
                $foto_driver_full = $foto_driver;
            } elseif (str_starts_with($foto_driver, 'assets/')) {
                $foto_driver_full = $base_url . $foto_driver;
            } else {
                $foto_driver_full = $base_upload_url . $foto_driver;
            }
        } else {
            $foto_driver_full = null;
        }

        $vehicle_display = $order['jenis_kendaraan'] ?? $order['tipe_kendaraan'] ?? 'Motor Box';
        $plat_nomor_display = $order['plat_nomor'] ?? '-';

        $data = [
            'id' => (int)($order['id_order'] ?? 0),
            'id_order' => (int)($order['id_order'] ?? 0),
            'id_warga' => isset($order['id_warga']) ? (int)$order['id_warga'] : null,
            'nama_warga' => $order['nama_warga'] ?? '',
            'telp_warga' => $order['telp_warga'] ?? null,
            'foto_warga' => $foto_warga_full,
            'id_driver' => !empty($order['id_driver']) ? (int)$order['id_driver'] : null,
            'picker_id' => !empty($order['id_driver']) ? (int)$order['id_driver'] : null,
            'nama_driver' => $order['nama_driver'] ?? null,
            'picker_full_name' => $order['nama_driver'] ?? null,
            'telp_driver' => $order['telp_driver'] ?? null,
            'picker_phone' => $order['telp_driver'] ?? null,
            'foto_driver' => $foto_driver_full,
            'profile_photo' => $foto_driver_full,
            'photo_url' => $foto_driver_full,
            'avatar' => $foto_driver_full,
            'driver_username' => $order['driver_username'] ?? null,
            'picker_username' => $order['driver_username'] ?? null,
            'driver_online_status' => $order['driver_online_status'] ?? 'offline',
            'picker_online_status' => $order['driver_online_status'] ?? 'offline',
            'online_status' => $order['driver_online_status'] ?? 'offline',
            'jenis_kendaraan' => $vehicle_display,
            'plat_nomor' => $plat_nomor_display,
            'alamat_jemput' => $order['alamat_jemput'] ?? '',
            'latitude' => !empty($order['latitude']) ? floatval($order['latitude']) : null,
            'longitude' => !empty($order['longitude']) ? floatval($order['longitude']) : null,
            'waktu_jemput_dari' => $order['waktu_jemput_dari'] ?? '',
            'waktu_jemput_sampai' => $order['waktu_jemput_sampai'] ?? '',
            'tanggal_order' => $order['tanggal_order'] ?? $order['created_at'] ?? '',
            'estimasi_berat' => $order['estimasi_berat'] ?? '0',
            'berat_aktual' => (isset($order['berat_aktual']) && $order['berat_aktual'] !== null) ? floatval($order['berat_aktual']) : null,
            'estimasi_poin' => (int)($order['estimasi_poin'] ?? 0),
            'status' => $order['status'] ?? 'MENUNGGU_KONFIRMASI',
            'catatan' => $order['catatan'] ?? '',
            'created_at' => $order['created_at'] ?? '',
            'updated_at' => $order['updated_at'] ?? '',
            'items' => $items,
        ];

        // Get Activity Log
        $activity_sql = "SELECT status, assigned_at, departed_at, arrived_at, pickup_started_at, pickup_finished_at, arrived_bank_at, unloaded_at, note FROM detail_driver WHERE id_order = ? LIMIT 1";
        $stmt_act = mysqli_prepare($koneksi, $activity_sql);
        mysqli_stmt_bind_param($stmt_act, "i", $order_id);
        mysqli_stmt_execute($stmt_act);
        $act_res = mysqli_stmt_get_result($stmt_act);
        $activity_log = mysqli_fetch_assoc($act_res);
        mysqli_stmt_close($stmt_act);

        if (!$activity_log) {
            $activity_log = [
                'status' => $data['status'],
                'assigned_at' => null,
                'departed_at' => null,
                'arrived_at' => null,
                'pickup_started_at' => null,
                'pickup_finished_at' => null,
                'arrived_bank_at' => null,
                'unloaded_at' => null,
                'note' => null
            ];
        }

        $data['activity_log'] = $activity_log;

        api_respond(true, 'Detail order', $data);
    }

    // List orders
    $where = [];
    $params = [];
    $types = '';

    if ($user_id) {
        $where[] = "o.id_warga = ?";
        $params[] = $user_id;
        $types .= 'i';
    }
    if ($driver_id) {
        $where[] = "(o.id_driver = ? OR o.id_driver IS NULL)";
        $params[] = $driver_id;
        $types .= 'i';
    }
    if ($status) {
        $statuses = explode(',', $status);
        $placeholders = implode(',', array_fill(0, count($statuses), '?'));
        $where[] = "o.status IN ($placeholders)";
        foreach ($statuses as $s) {
            $params[] = trim($s);
            $types .= 's';
        }
    }

    $where_sql = !empty($where) ? 'WHERE ' . implode(' AND ', $where) : '';

    // Count
    $count_sql = "SELECT COUNT(*) as total FROM orders o $where_sql";
    if (!empty($params)) {
        $stmt_c = mysqli_prepare($koneksi, $count_sql);
        mysqli_stmt_bind_param($stmt_c, $types, ...$params);
        mysqli_stmt_execute($stmt_c);
        $cr = mysqli_stmt_get_result($stmt_c);
    } else {
        $cr = mysqli_query($koneksi, $count_sql);
    }
    $total = (int)mysqli_fetch_assoc($cr)['total'];
    if (isset($stmt_c)) mysqli_stmt_close($stmt_c);

    // Data
    $sql = "SELECT o.*, w.nama_lengkap as nama_warga, w.no_telepon as telp_warga,
                   d.nama_lengkap as nama_driver
            FROM orders o
            LEFT JOIN pengguna w ON o.id_warga = w.id_pengguna
            LEFT JOIN pengguna d ON o.id_driver = d.id_pengguna
            $where_sql
            ORDER BY o.created_at DESC
            LIMIT ? OFFSET ?";
    $params[] = $limit;
    $params[] = $offset;
    $types .= 'ii';

    $stmt = mysqli_prepare($koneksi, $sql);
    if (!empty($types)) {
        mysqli_stmt_bind_param($stmt, $types, ...$params);
    }
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);

    $orders = [];
    while ($row = mysqli_fetch_assoc($result)) {
        // Get items count
        $oi_sql = "SELECT COUNT(*) as cnt FROM order_items WHERE id_order = ?";
        $stmt_oi = mysqli_prepare($koneksi, $oi_sql);
        $oid = (int)$row['id_order'];
        mysqli_stmt_bind_param($stmt_oi, "i", $oid);
        mysqli_stmt_execute($stmt_oi);
        $oi_r = mysqli_stmt_get_result($stmt_oi);
        $items_count = (int)mysqli_fetch_assoc($oi_r)['cnt'];
        mysqli_stmt_close($stmt_oi);

        $orders[] = [
            'id' => (int)$row['id_order'],
            'nama_warga' => $row['nama_warga'],
            'telp_warga' => $row['telp_warga'],
            'nama_driver' => $row['nama_driver'],
            'alamat_jemput' => $row['alamat_jemput'],
            'waktu_jemput_dari' => $row['waktu_jemput_dari'] ?? '',
            'waktu_jemput_sampai' => $row['waktu_jemput_sampai'] ?? '',
            'tanggal_order' => $row['tanggal_order'] ?? $row['created_at'] ?? '',
            'waktu_jemput' => ($row['waktu_jemput_dari'] ?? '') . ' - ' . ($row['waktu_jemput_sampai'] ?? ''),
            'estimasi_berat' => $row['estimasi_berat'],
            'berat_aktual' => $row['berat_aktual'] !== null ? floatval($row['berat_aktual']) : null,
            'estimasi_poin' => (int)$row['estimasi_poin'],
            'status' => $row['status'],
            'catatan' => $row['catatan'],
            'items_count' => $items_count,
            'created_at' => $row['created_at'],
            'updated_at' => $row['updated_at'] ?? '',
        ];
    }
    mysqli_stmt_close($stmt);

    api_respond(true, 'Daftar orders', [
        'total' => $total,
        'page' => $page,
        'limit' => $limit,
        'items' => $orders,
    ]);
}

// =====================
// POST — Buat order baru
// =====================
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (!$auth_user) {
        api_respond(false, 'Unauthorized', null, 401);
    }

    $user_id = (int)$auth_user['id_pengguna'];
    $alamat = isset($_POST['alamat_jemput']) ? trim($_POST['alamat_jemput']) : '';
    $lat = isset($_POST['latitude']) ? floatval($_POST['latitude']) : null;
    $lng = isset($_POST['longitude']) ? floatval($_POST['longitude']) : null;
    $waktu_dari = isset($_POST['waktu_jemput_dari']) ? trim($_POST['waktu_jemput_dari']) : null;
    $waktu_sampai = isset($_POST['waktu_jemput_sampai']) ? trim($_POST['waktu_jemput_sampai']) : null;
    $estimasi_berat = isset($_POST['estimasi_berat']) ? trim($_POST['estimasi_berat']) : null;
    $estimasi_poin = isset($_POST['estimasi_poin']) ? (int)$_POST['estimasi_poin'] : 0;
    $catatan = isset($_POST['catatan']) ? trim($_POST['catatan']) : null;
    $items_json = isset($_POST['items']) ? $_POST['items'] : '[]';

    if (empty($alamat)) {
        api_respond(false, 'Alamat penjemputan wajib diisi', null, 400);
    }

    $items = json_decode($items_json, true);
    if (!is_array($items) || empty($items)) {
        api_respond(false, 'Minimal satu jenis sampah harus dipilih', null, 400);
    }

    // Insert order
    $sql = "INSERT INTO orders (id_warga, alamat_jemput, latitude, longitude, waktu_jemput_dari, waktu_jemput_sampai, estimasi_berat, estimasi_poin, catatan, status)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'MENUNGGU_KONFIRMASI')";
    $stmt = mysqli_prepare($koneksi, $sql);
    mysqli_stmt_bind_param($stmt, "isddsssis", $user_id, $alamat, $lat, $lng, $waktu_dari, $waktu_sampai, $estimasi_berat, $estimasi_poin, $catatan);

    if (!mysqli_stmt_execute($stmt)) {
        api_respond(false, 'Gagal membuat order: ' . mysqli_error($koneksi), null, 500);
    }
    $order_id = mysqli_insert_id($koneksi);
    mysqli_stmt_close($stmt);

    // Insert order items
    foreach ($items as $item) {
        $id_jenis = (int)($item['id_jenis_sampah'] ?? 0);
        $est_berat = floatval($item['estimasi_berat_kg'] ?? 0);

        if ($id_jenis > 0) {
            $item_sql = "INSERT INTO order_items (id_order, id_jenis_sampah, estimasi_berat_kg) VALUES (?, ?, ?)";
            $stmt_item = mysqli_prepare($koneksi, $item_sql);
            mysqli_stmt_bind_param($stmt_item, "iid", $order_id, $id_jenis, $est_berat);
            mysqli_stmt_execute($stmt_item);
            mysqli_stmt_close($stmt_item);
        }
    }

    // Buat notifikasi untuk warga
    $notif_sql = "INSERT INTO notifikasi (id_pengguna, judul, pesan, tipe, related_id) VALUES (?, 'Permintaan Dikirim', 'Permintaan penjemputan berhasil dibuat.', 'pickup', ?)";
    $stmt_n = mysqli_prepare($koneksi, $notif_sql);
    mysqli_stmt_bind_param($stmt_n, "ii", $user_id, $order_id);
    mysqli_stmt_execute($stmt_n);
    mysqli_stmt_close($stmt_n);

    api_respond(true, 'Order berhasil dibuat', ['id_order' => $order_id], 201);
}

// =====================
// PUT — Update status order
// =====================
if ($_SERVER['REQUEST_METHOD'] === 'PUT') {
    if (!$auth_user) {
        api_respond(false, 'Unauthorized', null, 401);
    }

    $data = json_decode($raw_input, true);
    if (!is_array($data)) {
        $data = [];
        parse_str($raw_input, $data);
    }

    $order_id = 0;
    if (isset($data['id_order'])) {
        $order_id = (int)$data['id_order'];
    } elseif (isset($_POST['id_order'])) {
        $order_id = (int)$_POST['id_order'];
    } elseif (isset($_GET['id_order'])) {
        $order_id = (int)$_GET['id_order'];
    }

    $new_status = '';
    if (isset($data['status'])) {
        $new_status = (string)$data['status'];
    } elseif (isset($_POST['status'])) {
        $new_status = (string)$_POST['status'];
    } elseif (isset($_GET['status'])) {
        $new_status = (string)$_GET['status'];
    }
    if (!$order_id || empty($new_status)) {
        api_respond(false, 'id_order dan status wajib diisi', null, 400);
    }

    $valid_statuses = ['MENUNGGU_KONFIRMASI', 'DRIVER_DITUGASKAN', 'DRIVER_MENUJU_LOKASI', 'DRIVER_TIBA', 'PENIMBANGAN', 'SAMPAH_DIJEMPUT', 'VALIDASI_BANK_SAMPAH', 'SELESAI', 'DIBATALKAN'];
    if (!in_array($new_status, $valid_statuses)) {
        api_respond(false, 'Status tidak valid', null, 400);
    }

    $driver_id = (int)$auth_user['id_pengguna'];
    $raw_berat = isset($data['berat_aktual']) && !empty($data['berat_aktual']) ? trim((string)$data['berat_aktual']) : null;

    // Update query depending on params
    if ($new_status === 'DRIVER_DITUGASKAN') {
        $sql = "UPDATE orders SET status = ?, id_driver = ? WHERE id_order = ?";
        $stmt = mysqli_prepare($koneksi, $sql);
        if ($stmt) mysqli_stmt_bind_param($stmt, "sii", $new_status, $driver_id, $order_id);
    } elseif ($raw_berat !== null) {
        $sql = "UPDATE orders SET status = ?, berat_aktual = ? WHERE id_order = ?";
        $stmt = mysqli_prepare($koneksi, $sql);
        if ($stmt) mysqli_stmt_bind_param($stmt, "ssi", $new_status, $raw_berat, $order_id);
    } else {
        $sql = "UPDATE orders SET status = ? WHERE id_order = ?";
        $stmt = mysqli_prepare($koneksi, $sql);
        if ($stmt) mysqli_stmt_bind_param($stmt, "si", $new_status, $order_id);
    }

    if (!$stmt) {
        api_respond(false, 'Gagal menyiapkan query update: ' . mysqli_error($koneksi), null, 500);
    }

    if (mysqli_stmt_execute($stmt)) {
        @mysqli_stmt_close($stmt);
        $stmt = null;

        // --- ACTIVITY LOG INJECTION ---
        $timestamp_col = '';
        if ($new_status === 'DRIVER_DITUGASKAN') $timestamp_col = 'assigned_at';
        elseif ($new_status === 'DRIVER_MENUJU_LOKASI') $timestamp_col = 'departed_at';
        elseif ($new_status === 'DRIVER_TIBA') $timestamp_col = 'arrived_at';
        elseif ($new_status === 'SAMPAH_DIJEMPUT') $timestamp_col = 'pickup_finished_at'; 
        elseif ($new_status === 'VALIDASI_BANK_SAMPAH') $timestamp_col = 'arrived_bank_at';
        elseif ($new_status === 'SELESAI') $timestamp_col = 'unloaded_at';
        
        $pid = $driver_id;
        
        $act_chk = mysqli_query($koneksi, "SELECT id_detail_driver FROM detail_driver WHERE id_order = $order_id");
        if (mysqli_num_rows($act_chk) > 0) {
            $q_upd = "UPDATE detail_driver SET status = '$new_status'";
            if (!empty($timestamp_col)) $q_upd .= ", $timestamp_col = NOW()";
            $q_upd .= " WHERE id_order = $order_id";
            mysqli_query($koneksi, $q_upd);
        } else {
            $q_ins = "INSERT INTO detail_driver (id_order, id_picker, status";
            $v_ins = "VALUES ($order_id, $pid, '$new_status'";
            if (!empty($timestamp_col)) {
                $q_ins .= ", $timestamp_col";
                $v_ins .= ", NOW()";
            }
            $q_ins .= ") " . $v_ins . ")";
            mysqli_query($koneksi, $q_ins);
        }
        // --- END ACTIVITY LOG INJECTION ---

        // Auto-update driver status based on order status transition
        $driver_query = "SELECT id_driver FROM orders WHERE id_order = ?";
        $stmt_dr = mysqli_prepare($koneksi, $driver_query);
        if ($stmt_dr) {
            mysqli_stmt_bind_param($stmt_dr, "i", $order_id);
            mysqli_stmt_execute($stmt_dr);
            $dr_res = mysqli_stmt_get_result($stmt_dr);
            if ($dr_row = mysqli_fetch_assoc($dr_res)) {
                $target_driver_id = (int)$dr_row['id_driver'];
                if ($target_driver_id > 0) {
                    if ($new_status === 'DRIVER_MENUJU_LOKASI') {
                        mysqli_query($koneksi, "UPDATE pengguna SET driver_status = 'on pickup' WHERE id_pengguna = $target_driver_id AND level = 'driver'");
                    } elseif (in_array($new_status, ['SAMPAH_DIJEMPUT', 'VALIDASI_BANK_SAMPAH', 'SELESAI'])) {
                        mysqli_query($koneksi, "UPDATE pengguna SET driver_status = 'waiting assignment' WHERE id_pengguna = $target_driver_id AND level = 'driver'");
                    }
                }
            }
            mysqli_stmt_close($stmt_dr);
        }

        // Fetch order details for notification & point calculation
        $get_order_info = "SELECT id_warga, estimasi_berat, estimasi_poin, berat_aktual FROM orders WHERE id_order = ?";
        $stmt_w = mysqli_prepare($koneksi, $get_order_info);
        $warga_row = null;
        if ($stmt_w) {
            mysqli_stmt_bind_param($stmt_w, "i", $order_id);
            mysqli_stmt_execute($stmt_w);
            $wr = mysqli_stmt_get_result($stmt_w);
            if ($wr) $warga_row = mysqli_fetch_assoc($wr);
            mysqli_stmt_close($stmt_w);
        }

        if ($warga_row && $new_status === 'SELESAI') {
            $warga_id = (int)$warga_row['id_warga'];
            $actual_wt = floatval($warga_row['berat_aktual'] ?? $warga_row['estimasi_berat'] ?? 1.0);
            $est_wt = floatval($warga_row['estimasi_berat'] ?? 1.0);
            $est_pts = (int)($warga_row['estimasi_poin'] ?? 10);
            
            $final_points = $est_wt > 0 ? (int)round(($actual_wt / $est_wt) * $est_pts) : $est_pts;
            if ($final_points <= 0) $final_points = $est_pts;

            // Credit points and balance to citizen
            $upd_poin = "UPDATE pengguna SET saldo = COALESCE(saldo, 0) + ? WHERE id_pengguna = ?";
            $stmt_p = mysqli_prepare($koneksi, $upd_poin);
            if ($stmt_p) {
                $total_rupiah = $final_points * 1000;
                mysqli_stmt_bind_param($stmt_p, "di", $total_rupiah, $warga_id);
                mysqli_stmt_execute($stmt_p);
                mysqli_stmt_close($stmt_p);
            }
        }

        if ($warga_row) {
            $notif_messages = [
                'SUBMITTED'            => ['Permintaan Dikirim', 'Permintaan penjemputan berhasil dibuat.', 'pickup'],
                'MENUNGGU_KONFIRMASI' => ['Permintaan Dikonfirmasi', 'Permintaan Anda telah dikonfirmasi.', 'pickup'],
                'DRIVER_DITUGASKAN'    => ['Picker Ditugaskan', 'Picker telah ditugaskan.', 'pickup'],
                'DRIVER_MENUJU_LOKASI'  => ['Picker Menuju Lokasi', 'Picker sedang menuju lokasi Anda.', 'pickup'],
                'DRIVER_TIBA'           => ['📍 Picker Sudah Dekat', 'Picker Anda telah tiba di sekitar lokasi penjemputan. Silakan siapkan sampah yang akan diserahkan.', 'pickup'],
                'PENIMBANGAN'          => ['Penimbangan Berat', 'Picker sedang melakukan penimbangan.', 'pickup'],
                'SAMPAH_DIJEMPUT'       => ['Sampah Dijemput', 'Sampah berhasil dijemput.', 'pickup'],
                'MENUJU_BANK_SAMPAH'   => ['Menuju Bank Sampah', 'Sampah sedang dibawa ke Bank Sampah.', 'pickup'],
                'VALIDASI_BANK_SAMPAH' => ['Waiting Validation', 'Sedang divalidasi oleh Admin.', 'pickup'],
                'POIN_DIPROSES'        => ['Poin Diproses', 'Poin sedang dihitung.', 'reward'],
                'SELESAI'              => ['Completed', "Penjemputan selesai. Poin telah ditambahkan ke akun Anda.", 'reward'],
                'DIBATALKAN'           => ['Penjemputan Dibatalkan', 'Permintaan penjemputan berhasil dibatalkan.', 'info']
            ];

            if (isset($notif_messages[$new_status])) {
                $nm = $notif_messages[$new_status];
                $notif_sql = "INSERT INTO notifikasi (id_pengguna, judul, pesan, tipe, related_id) VALUES (?, ?, ?, ?, ?)";
                $stmt_n = mysqli_prepare($koneksi, $notif_sql);
                if ($stmt_n) {
                    $warga_id = (int)$warga_row['id_warga'];
                    $n_title = (string)$nm[0];
                    $n_msg = (string)$nm[1];
                    $n_type = (string)$nm[2];
                    mysqli_stmt_bind_param($stmt_n, "isssi", $warga_id, $n_title, $n_msg, $n_type, $order_id);
                    mysqli_stmt_execute($stmt_n);
                    mysqli_stmt_close($stmt_n);
                }
            }

            if ($new_status === 'VALIDASI_BANK_SAMPAH') {
                $adm_res = mysqli_query($koneksi, "SELECT id_pengguna FROM pengguna WHERE level IN ('admin', 'petugas') OR level LIKE '%admin%'");
                if ($adm_res) {
                    while ($adm = mysqli_fetch_assoc($adm_res)) {
                        $adm_id = (int)$adm['id_pengguna'];
                        mysqli_query($koneksi, "INSERT INTO notifikasi (id_pengguna, judul, pesan, tipe, related_id) VALUES ($adm_id, 'Validasi Setoran Baru', 'Penjemputan baru menunggu validasi.', 'pickup', $order_id)");
                    }
                }
            }
        }

        $resp_msg = ($new_status === 'DIBATALKAN') ? 'Pesanan berhasil dibatalkan.' : (($new_status === 'SAMPAH_DIJEMPUT' || $raw_berat !== null) ? 'Berat berhasil dikonfirmasi.' : 'Status order berhasil diupdate');

        echo json_encode([
            'success' => true,
            'message' => $resp_msg,
            'order_status' => $new_status,
            'actual_weight' => $raw_berat
        ], JSON_UNESCAPED_UNICODE);
        exit;
    } else {
        $err = mysqli_error($koneksi);
        if ($stmt) mysqli_stmt_close($stmt);
        api_respond(false, 'Gagal mengupdate status: ' . $err, null, 500);
    }
}
?>
