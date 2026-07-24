<?php
// modules/api/notifikasi_api.php
// Endpoint: List notifikasi, mark as read
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, PUT, OPTIONS');
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
    if (!$token) {
        $raw = file_get_contents('php://input');
        $json = json_decode($raw, true);
        if ($json && isset($json['token'])) $token = $json['token'];
    }
    if (!$token) return null;

    $stmt = mysqli_prepare($koneksi, "SELECT id_pengguna FROM pengguna WHERE api_token = ? LIMIT 1");
    mysqli_stmt_bind_param($stmt, "s", $token);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);
    $user = mysqli_fetch_assoc($result);
    mysqli_stmt_close($stmt);
    return $user;
}

$auth_user = get_auth_user($koneksi);
if (!$auth_user) {
    api_respond(false, 'Unauthorized', null, 401);
}

$user_id = (int)$auth_user['id_pengguna'];

function sanitize_notif_payload($row) {
    $title = trim(strip_tags($row['judul'] ?? ''));
    $message = trim(strip_tags($row['pesan'] ?? ''));
    $type = strtolower(trim($row['tipe'] ?? 'info'));

    // Detect and sanitize any raw JSON/JS/PHP traceback or placeholder text
    if (strpos($message, '{') !== false || strpos($message, 'function') !== false || strpos($message, 'var ') !== false || strpos($message, 'console.') !== false || strpos($message, '<?php') !== false) {
        $message = preg_replace('/\{.*?\}/s', '', $message);
        $message = trim($message);
    }

    // Direct mappings for legacy or raw status strings
    $msg_upper = strtoupper($message);
    $title_upper = strtoupper($title);

    if ($msg_upper === 'ORDER CREATED' || $msg_upper === 'SUBMITTED' || $title_upper === 'ORDER CREATED') {
        $title = 'Permintaan Dikirim';
        $message = 'Permintaan penjemputan berhasil dibuat.';
    } elseif ($msg_upper === 'ADMIN APPROVED' || $msg_upper === 'MENUNGGU_KONFIRMASI' || $title_upper === 'ADMIN APPROVED') {
        $title = 'Permintaan Dikonfirmasi';
        $message = 'Permintaan Anda telah dikonfirmasi.';
    } elseif ($msg_upper === 'PICKER ASSIGNED' || $msg_upper === 'DRIVER_DITUGASKAN' || $title_upper === 'PICKER ASSIGNED') {
        $title = 'Picker Ditugaskan';
        $message = 'Picker telah ditugaskan.';
    } elseif ($msg_upper === 'PICKER ON THE WAY' || $msg_upper === 'DRIVER_MENUJU_LOKASI' || $title_upper === 'PICKER ON THE WAY') {
        $title = 'Picker Menuju Lokasi';
        $message = 'Picker sedang menuju lokasi Anda.';
    } elseif ($msg_upper === 'PICKER NEARBY' || $msg_upper === 'DRIVER_TIBA' || $title_upper === 'PICKER NEARBY') {
        $title = 'Picker Hampir Tiba';
        $message = 'Picker sudah dekat.';
    } elseif ($msg_upper === 'WEIGHT VALIDATION' || $msg_upper === 'PENIMBANGAN' || $title_upper === 'WEIGHT VALIDATION') {
        $title = 'Penimbangan Berat';
        $message = 'Picker sedang melakukan penimbangan.';
    } elseif ($msg_upper === 'WASTE PICKED UP' || $msg_upper === 'SAMPAH_DIJEMPUT' || $title_upper === 'WASTE PICKED UP') {
        $title = 'Sampah Dijemput';
        $message = 'Sampah berhasil dijemput.';
    } elseif ($msg_upper === 'HEADING TO WASTE BANK' || $msg_upper === 'MENUJU_BANK_SAMPAH' || $title_upper === 'HEADING TO WASTE BANK') {
        $title = 'Menuju Bank Sampah';
        $message = 'Sampah sedang dibawa ke Bank Sampah.';
    } elseif ($msg_upper === 'ADMIN VALIDATION' || $msg_upper === 'VALIDASI_BANK_SAMPAH' || $title_upper === 'ADMIN VALIDATION') {
        $title = 'Waiting Validation';
        $message = 'Sedang divalidasi oleh Admin.';
    } elseif ($msg_upper === 'POINT CALCULATION' || $msg_upper === 'POIN_DIPROSES' || $title_upper === 'POINT CALCULATION') {
        $title = 'Poin Diproses';
        $message = 'Poin sedang dihitung.';
    } elseif ($msg_upper === 'COMPLETED' || $msg_upper === 'SELESAI' || $title_upper === 'COMPLETED') {
        $title = 'Completed';
        $message = "Penjemputan selesai. Poin telah ditambahkan ke akun Anda.";
    } elseif ($msg_upper === 'CANCELLED' || $msg_upper === 'DIBATALKAN' || $title_upper === 'CANCELLED') {
        $title = 'Penjemputan Dibatalkan';
        $message = 'Permintaan penjemputan berhasil dibatalkan.';
    }

    if (empty($title)) $title = 'Notifikasi Sistem';
    if (empty($message)) $message = 'Aktivitas Anda telah diperbarui.';

    return [
        'id' => (int)$row['id_notifikasi'],
        'judul' => $title,
        'pesan' => $message,
        'tipe' => $type,
        'is_read' => (bool)$row['is_read'],
        'read_at' => $row['read_at'],
        'related_id' => $row['related_id'] ? (int)$row['related_id'] : null,
        'created_at' => $row['created_at'],
    ];
}

// =====================
// GET — List notifikasi
// =====================
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $page = max(1, (int)($_GET['page'] ?? 1));
    $limit = max(1, (int)($_GET['limit'] ?? 50));
    $offset = ($page - 1) * $limit;

    // Count unread
    $unread_sql = "SELECT COUNT(*) as cnt FROM notifikasi WHERE id_pengguna = ? AND is_read = 0";
    $stmt_u = mysqli_prepare($koneksi, $unread_sql);
    mysqli_stmt_bind_param($stmt_u, "i", $user_id);
    mysqli_stmt_execute($stmt_u);
    $ur = mysqli_stmt_get_result($stmt_u);
    $unread_count = (int)mysqli_fetch_assoc($ur)['cnt'];
    mysqli_stmt_close($stmt_u);

    // Get notifications
    $sql = "SELECT * FROM notifikasi WHERE id_pengguna = ? ORDER BY created_at DESC LIMIT ? OFFSET ?";
    $stmt = mysqli_prepare($koneksi, $sql);
    mysqli_stmt_bind_param($stmt, "iii", $user_id, $limit, $offset);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);

    $items = [];
    while ($row = mysqli_fetch_assoc($result)) {
        $items[] = sanitize_notif_payload($row);
    }
    mysqli_stmt_close($stmt);

    api_respond(true, 'Daftar notifikasi', [
        'unread_count' => $unread_count,
        'items' => $items,
    ]);
}

// =====================
// PUT — Mark as read
// =====================
if ($_SERVER['REQUEST_METHOD'] === 'PUT') {
    $raw = file_get_contents('php://input');
    $data = json_decode($raw, true);
    if (!$data) parse_str($raw, $data);

    $notif_id = isset($data['id_notifikasi']) ? (int)$data['id_notifikasi'] : 0;
    $mark_all = isset($data['mark_all']) ? (bool)$data['mark_all'] : false;

    if ($mark_all) {
        $sql = "UPDATE notifikasi SET is_read = 1, read_at = CURRENT_TIMESTAMP WHERE id_pengguna = ? AND is_read = 0";
        $stmt = mysqli_prepare($koneksi, $sql);
        mysqli_stmt_bind_param($stmt, "i", $user_id);
    } elseif ($notif_id > 0) {
        $sql = "UPDATE notifikasi SET is_read = 1, read_at = CURRENT_TIMESTAMP WHERE id_notifikasi = ? AND id_pengguna = ?";
        $stmt = mysqli_prepare($koneksi, $sql);
        mysqli_stmt_bind_param($stmt, "ii", $notif_id, $user_id);
    } else {
        api_respond(false, 'Kirim id_notifikasi atau mark_all=true', null, 400);
    }

    if (mysqli_stmt_execute($stmt)) {
        $affected = mysqli_stmt_affected_rows($stmt);
        api_respond(true, "Berhasil menandai $affected notifikasi sebagai dibaca");
    } else {
        api_respond(false, 'Gagal mengupdate notifikasi', null, 500);
    }
    mysqli_stmt_close($stmt);
}
?>
