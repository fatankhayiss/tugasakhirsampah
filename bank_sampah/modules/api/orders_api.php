<?php
// modules/api/orders_api.php
// Endpoint CRUD orders penjemputan
// GET  — List orders (filter by user_id, driver_id, status)
// POST — Buat order baru (warga)
// PUT  — Update status order (driver / admin)
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

function get_auth_user($koneksi) {
    $token = null;
    $headers = getallheaders();
    foreach ($headers as $key => $value) {
        if (strtolower($key) === 'authorization') {
            $token = str_replace('Bearer ', '', $value);
            break;
        }
    }
    if (!$token && isset($_GET['token'])) $token = $_GET['token'];
    if (!$token && isset($_POST['token'])) $token = $_POST['token'];
    // Also check raw JSON body for PUT requests
    if (!$token) {
        $raw = file_get_contents('php://input');
        $json = json_decode($raw, true);
        if ($json && isset($json['token'])) $token = $json['token'];
    }
    if (!$token) return null;

    $stmt = mysqli_prepare($koneksi, "SELECT id_pengguna, level FROM pengguna WHERE api_token = ? LIMIT 1");
    mysqli_stmt_bind_param($stmt, "s", $token);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);
    $user = mysqli_fetch_assoc($result);
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
    $order_id = isset($_GET['id']) ? (int)$_GET['id'] : null;
    $page = max(1, (int)($_GET['page'] ?? 1));
    $limit = max(1, (int)($_GET['limit'] ?? 20));
    $offset = ($page - 1) * $limit;

    // Detail single order
    if ($order_id) {
        $sql = "SELECT o.*, w.nama_lengkap as nama_warga, w.no_telepon as telp_warga, w.alamat as alamat_warga,
                       d.nama_lengkap as nama_driver
                FROM orders o
                JOIN pengguna w ON o.id_warga = w.id_pengguna
                LEFT JOIN pengguna d ON o.id_driver = d.id_pengguna
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
                      JOIN jenis_sampah js ON oi.id_jenis_sampah = js.id_jenis_sampah
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

        $data = [
            'id' => (int)$order['id_order'],
            'nama_warga' => $order['nama_warga'],
            'telp_warga' => $order['telp_warga'],
            'nama_driver' => $order['nama_driver'],
            'alamat_jemput' => $order['alamat_jemput'],
            'latitude' => $order['latitude'] ? floatval($order['latitude']) : null,
            'longitude' => $order['longitude'] ? floatval($order['longitude']) : null,
            'waktu_jemput_dari' => $order['waktu_jemput_dari'],
            'waktu_jemput_sampai' => $order['waktu_jemput_sampai'],
            'estimasi_berat' => $order['estimasi_berat'],
            'estimasi_poin' => (int)$order['estimasi_poin'],
            'status' => $order['status'],
            'catatan' => $order['catatan'],
            'created_at' => $order['created_at'],
            'updated_at' => $order['updated_at'],
            'items' => $items,
        ];

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
            JOIN pengguna w ON o.id_warga = w.id_pengguna
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
            'waktu_jemput' => $row['waktu_jemput_dari'] . ' - ' . $row['waktu_jemput_sampai'],
            'estimasi_berat' => $row['estimasi_berat'],
            'estimasi_poin' => (int)$row['estimasi_poin'],
            'status' => $row['status'],
            'catatan' => $row['catatan'],
            'items_count' => $items_count,
            'created_at' => $row['created_at'],
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
    $lat = isset($_POST['latitude']) ? $_POST['latitude'] : null;
    $lng = isset($_POST['longitude']) ? $_POST['longitude'] : null;
    $waktu_dari = isset($_POST['waktu_jemput_dari']) ? $_POST['waktu_jemput_dari'] : null;
    $waktu_sampai = isset($_POST['waktu_jemput_sampai']) ? $_POST['waktu_jemput_sampai'] : null;
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
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'pending')";
    $stmt = mysqli_prepare($koneksi, $sql);
    mysqli_stmt_bind_param($stmt, "issddsssi", $user_id, $alamat, $lat, $lng, $waktu_dari, $waktu_sampai, $estimasi_berat, $estimasi_poin, $catatan);

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
    $notif_sql = "INSERT INTO notifikasi (id_pengguna, judul, pesan, tipe) VALUES (?, 'Order penjemputan berhasil dibuat', 'Pesanan Anda telah dikonfirmasi. Menunggu driver menerima.', 'pickup')";
    $stmt_n = mysqli_prepare($koneksi, $notif_sql);
    mysqli_stmt_bind_param($stmt_n, "i", $user_id);
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

    $raw = file_get_contents('php://input');
    $data = json_decode($raw, true);
    if (!$data) {
        // Try parse_str for form data
        parse_str($raw, $data);
    }

    $order_id = isset($data['id_order']) ? (int)$data['id_order'] : 0;
    $new_status = isset($data['status']) ? $data['status'] : '';

    if (!$order_id || empty($new_status)) {
        api_respond(false, 'id_order dan status wajib diisi', null, 400);
    }

    $valid_statuses = ['pending', 'accepted', 'on_the_way', 'picked_up', 'validating', 'completed', 'cancelled'];
    if (!in_array($new_status, $valid_statuses)) {
        api_respond(false, 'Status tidak valid', null, 400);
    }

    $driver_id = (int)$auth_user['id_pengguna'];
    $berat_aktual = isset($data['berat_aktual']) ? $data['berat_aktual'] : (isset($data['estimasi_berat']) ? $data['estimasi_berat'] : null);

    // Jika driver accept, assign driver_id
    if ($new_status === 'accepted') {
        $sql = "UPDATE orders SET status = ?, id_driver = ? WHERE id_order = ?";
        $stmt = mysqli_prepare($koneksi, $sql);
        mysqli_stmt_bind_param($stmt, "sii", $new_status, $driver_id, $order_id);
    } elseif ($berat_aktual !== null) {
        $sql = "UPDATE orders SET status = ?, estimasi_berat = ? WHERE id_order = ?";
        $stmt = mysqli_prepare($koneksi, $sql);
        mysqli_stmt_bind_param($stmt, "ssi", $new_status, $berat_aktual, $order_id);
    } else {
        $sql = "UPDATE orders SET status = ? WHERE id_order = ?";
        $stmt = mysqli_prepare($koneksi, $sql);
        mysqli_stmt_bind_param($stmt, "si", $new_status, $order_id);
    }

    if (mysqli_stmt_execute($stmt)) {
        // Buat notifikasi untuk warga
        $get_warga = "SELECT id_warga FROM orders WHERE id_order = ?";
        $stmt_w = mysqli_prepare($koneksi, $get_warga);
        mysqli_stmt_bind_param($stmt_w, "i", $order_id);
        mysqli_stmt_execute($stmt_w);
        $wr = mysqli_stmt_get_result($stmt_w);
        $warga_row = mysqli_fetch_assoc($wr);
        mysqli_stmt_close($stmt_w);

        if ($warga_row) {
            $notif_messages = [
                'accepted' => ['Driver sedang menuju lokasi Anda', 'Penjemputan Anda telah diterima oleh driver.', 'pickup'],
                'on_the_way' => ['Driver dalam perjalanan', 'Driver sedang menuju ke lokasi penjemputan Anda.', 'pickup'],
                'picked_up' => ['Sampah berhasil dijemput', 'Driver telah menjemput sampah Anda. Menunggu proses verifikasi.', 'pickup'],
                'validating' => ['Validasi Bank Sampah', 'Sampah Anda telah sampai di Bank Sampah dan sedang dalam proses pengecekan akhir oleh Admin.', 'pickup'],
                'completed' => ['Penjemputan selesai', 'Penjemputan sampah Anda telah selesai. Poin akan segera ditambahkan.', 'reward'],
                'cancelled' => ['Penjemputan dibatalkan', 'Pesanan penjemputan Anda telah dibatalkan.', 'info'],
            ];

            if (isset($notif_messages[$new_status])) {
                $nm = $notif_messages[$new_status];
                $notif_sql = "INSERT INTO notifikasi (id_pengguna, judul, pesan, tipe) VALUES (?, ?, ?, ?)";
                $stmt_n = mysqli_prepare($koneksi, $notif_sql);
                $warga_id = (int)$warga_row['id_warga'];
                mysqli_stmt_bind_param($stmt_n, "isss", $warga_id, $nm[0], $nm[1], $nm[2]);
                mysqli_stmt_execute($stmt_n);
                mysqli_stmt_close($stmt_n);
            }
        }

        api_respond(true, 'Status order berhasil diupdate');
    } else {
        api_respond(false, 'Gagal mengupdate status: ' . mysqli_error($koneksi), null, 500);
    }
    mysqli_stmt_close($stmt);
}
?>
