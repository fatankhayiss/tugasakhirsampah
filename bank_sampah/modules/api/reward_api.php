<?php
// modules/api/reward_api.php
// Endpoint: Citizen Reward Redemption module (Tukar Poin)
// Interfaces:
// Citizen APIs:
// GET /reward/balance (?action=balance)
// GET /reward/redemption/history (?action=history)
// POST /reward/redemption/request (?action=request)
// GET /reward/redemption/detail/{id} (?action=detail&id=...)
// Admin APIs:
// GET /admin/reward/redemption (?action=admin_list)
// GET /admin/reward/redemption/{id} (?action=admin_detail&id=...)
// PUT /admin/reward/redemption/process (?action=admin_process)
// PUT /admin/reward/redemption/complete (?action=admin_complete)
// PUT /admin/reward/redemption/reject (?action=admin_reject)

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

// Auto-create table reward_redemptions if not exists
$create_table_sql = "CREATE TABLE IF NOT EXISTS reward_redemptions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  destination_type VARCHAR(50) NOT NULL,
  provider VARCHAR(100) NOT NULL,
  account_name VARCHAR(150) NOT NULL,
  account_number VARCHAR(100) NOT NULL,
  redeem_point INT NOT NULL,
  conversion_rate INT DEFAULT 10,
  estimated_amount DOUBLE NOT NULL,
  status VARCHAR(50) DEFAULT 'pending',
  admin_note TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  processed_at DATETIME NULL,
  completed_at DATETIME NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;";
mysqli_query($koneksi, $create_table_sql);

// Helper: ambil user dari token
function get_user_from_token($koneksi) {
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
    if (!$token) return null;

    $stmt = mysqli_prepare($koneksi, "SELECT id_pengguna, nama_lengkap, username, level, saldo FROM pengguna WHERE api_token = ? LIMIT 1");
    mysqli_stmt_bind_param($stmt, "s", $token);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);
    $user = mysqli_fetch_assoc($result);
    mysqli_stmt_close($stmt);
    return $user;
}

$user = get_user_from_token($koneksi);
$user_id = $user ? (int)$user['id_pengguna'] : (isset($_GET['user_id']) ? (int)$_GET['user_id'] : null);
if (!$user_id && isset($_POST['user_id'])) $user_id = (int)$_POST['user_id'];

// Check action parameter or REST path
$action = $_GET['action'] ?? '';
$path = $_SERVER['REQUEST_URI'] ?? '';

if (empty($action)) {
    if (strpos($path, '/reward/balance') !== false) $action = 'balance';
    elseif (strpos($path, '/reward/redemption/history') !== false) $action = 'history';
    elseif (strpos($path, '/reward/redemption/request') !== false) $action = 'request';
    elseif (strpos($path, '/reward/redemption/detail') !== false) $action = 'detail';
    elseif (strpos($path, '/admin/reward/redemption/process') !== false) $action = 'admin_process';
    elseif (strpos($path, '/admin/reward/redemption/complete') !== false) $action = 'admin_complete';
    elseif (strpos($path, '/admin/reward/redemption/reject') !== false) $action = 'admin_reject';
    elseif (strpos($path, '/admin/reward/redemption') !== false) $action = 'admin_list';
}

if (!$user && in_array($action, ['balance', 'request'])) {
    api_respond(false, 'Unauthorized. Token tidak valid atau tidak ditemukan.', null, 401);
}

// ==========================================
// CITIZEN API: GET /reward/balance
// ==========================================
if ($action === 'balance') {
    $stmt = mysqli_prepare($koneksi, "SELECT saldo FROM pengguna WHERE id_pengguna = ?");
    mysqli_stmt_bind_param($stmt, "i", $user_id);
    mysqli_stmt_execute($stmt);
    $r = mysqli_stmt_get_result($stmt);
    $row = mysqli_fetch_assoc($r);
    mysqli_stmt_close($stmt);

    $points = $row ? floatval($row['saldo']) : 0;
    $conversion_rate = 10; // 1 Poin = Rp 10
    $money = $points * $conversion_rate;

    api_respond(true, 'Reward balance retrieved', [
        'current_point' => (int)$points,
        'conversion_rate' => $conversion_rate,
        'current_money_conversion' => $money
    ]);
}

// ==========================================
// CITIZEN API: GET /reward/redemption/history
// ==========================================
if ($action === 'history') {
    $status_filter = $_GET['status'] ?? '';
    $sql = "SELECT * FROM reward_redemptions WHERE user_id = ?";
    $params = [$user_id];
    $types = 'i';

    if (!empty($status_filter)) {
        $status_list = explode(',', $status_filter);
        $placeholders = implode(',', array_fill(0, count($status_list), '?'));
        $sql .= " AND status IN ($placeholders)";
        foreach ($status_list as $st) {
            $params[] = trim(strtolower($st));
            $types .= 's';
        }
    }
    $sql .= " ORDER BY created_at DESC";

    $stmt = mysqli_prepare($koneksi, $sql);
    mysqli_stmt_bind_param($stmt, $types, ...$params);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);

    $items = [];
    while ($row = mysqli_fetch_assoc($result)) {
        $items[] = [
            'id' => (string)$row['id'],
            'user_id' => (int)$row['user_id'],
            'destination_type' => $row['destination_type'],
            'provider' => $row['provider'],
            'account_name' => $row['account_name'],
            'account_number' => $row['account_number'],
            'redeem_point' => (int)$row['redeem_point'],
            'conversion_rate' => (int)$row['conversion_rate'],
            'estimated_amount' => floatval($row['estimated_amount']),
            'status' => $row['status'],
            'admin_note' => $row['admin_note'],
            'created_at' => $row['created_at'],
            'processed_at' => $row['processed_at'],
            'completed_at' => $row['completed_at']
        ];
    }
    mysqli_stmt_close($stmt);

    api_respond(true, 'Redemption history retrieved', ['items' => $items]);
}

// ==========================================
// CITIZEN API: POST /reward/redemption/request
// ==========================================
if ($action === 'request') {
    // Read input from POST or raw JSON
    $input = $_POST;
    if (empty($input)) {
        $json_input = json_decode(file_get_contents('php://input'), true);
        if (is_array($json_input)) $input = $json_input;
    }

    $dest_type = trim($input['destination_type'] ?? '');
    $provider = trim($input['provider'] ?? '');
    $acc_num = trim($input['account_number'] ?? '');
    $acc_name = trim($input['account_name'] ?? '');
    $redeem_point = (int)($input['redeem_point'] ?? 0);

    if (empty($dest_type) || empty($provider) || empty($acc_num) || empty($acc_name) || $redeem_point <= 0) {
        api_respond(false, 'Data penukaran poin tidak lengkap atau jumlah poin tidak valid', null, 400);
    }

    // Check user points
    $stmt = mysqli_prepare($koneksi, "SELECT saldo FROM pengguna WHERE id_pengguna = ?");
    mysqli_stmt_bind_param($stmt, "i", $user_id);
    mysqli_stmt_execute($stmt);
    $r = mysqli_stmt_get_result($stmt);
    $row = mysqli_fetch_assoc($r);
    mysqli_stmt_close($stmt);

    $current_points = floatval($row['saldo'] ?? 0);
    if ($redeem_point > $current_points) {
        api_respond(false, 'Poin Anda tidak mencukupi untuk melakukan penukaran ini', null, 400);
    }

    $conversion_rate = 10;
    $estimated_amount = $redeem_point * $conversion_rate;
    $status = 'pending';

    // Begin transaction
    mysqli_begin_transaction($koneksi);
    try {
        // Deduct user points immediately when requested
        $stmt_deduct = mysqli_prepare($koneksi, "UPDATE pengguna SET saldo = saldo - ? WHERE id_pengguna = ?");
        mysqli_stmt_bind_param($stmt_deduct, "di", $redeem_point, $user_id);
        mysqli_stmt_execute($stmt_deduct);
        mysqli_stmt_close($stmt_deduct);

        // Insert request
        $stmt_insert = mysqli_prepare($koneksi, "INSERT INTO reward_redemptions (user_id, destination_type, provider, account_name, account_number, redeem_point, conversion_rate, estimated_amount, status, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())");
        mysqli_stmt_bind_param($stmt_insert, "issssiids", $user_id, $dest_type, $provider, $acc_name, $acc_num, $redeem_point, $conversion_rate, $estimated_amount, $status);
        mysqli_stmt_execute($stmt_insert);
        $new_id = mysqli_insert_id($koneksi);
        mysqli_stmt_close($stmt_insert);

        mysqli_commit($koneksi);

        api_respond(true, 'Permintaan tukar poin berhasil dikirim', [
            'id' => (string)$new_id,
            'destination_type' => $dest_type,
            'provider' => $provider,
            'redeem_point' => $redeem_point,
            'estimated_amount' => $estimated_amount,
            'status' => $status
        ]);
    } catch (Exception $e) {
        mysqli_rollback($koneksi);
        api_respond(false, 'Gagal memproses penukaran poin: ' . $e->getMessage(), null, 500);
    }
}

// ==========================================
// CITIZEN API: GET /reward/redemption/detail/{id}
// ==========================================
if ($action === 'detail') {
    $id = isset($_GET['id']) ? (int)$_GET['id'] : 0;
    if (!$id && preg_match('/detail\/(\d+)/', $path, $matches)) {
        $id = (int)$matches[1];
    }
    if (!$id) {
        api_respond(false, 'ID penukaran tidak valid', null, 400);
    }

    $stmt = mysqli_prepare($koneksi, "SELECT * FROM reward_redemptions WHERE id = ? LIMIT 1");
    mysqli_stmt_bind_param($stmt, "i", $id);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);
    $row = mysqli_fetch_assoc($result);
    mysqli_stmt_close($stmt);

    if (!$row) {
        api_respond(false, 'Data penukaran tidak ditemukan', null, 404);
    }

    api_respond(true, 'Detail penukaran retrieved', [
        'id' => (string)$row['id'],
        'user_id' => (int)$row['user_id'],
        'destination_type' => $row['destination_type'],
        'provider' => $row['provider'],
        'account_name' => $row['account_name'],
        'account_number' => $row['account_number'],
        'redeem_point' => (int)$row['redeem_point'],
        'conversion_rate' => (int)$row['conversion_rate'],
        'estimated_amount' => floatval($row['estimated_amount']),
        'status' => $row['status'],
        'admin_note' => $row['admin_note'],
        'created_at' => $row['created_at'],
        'processed_at' => $row['processed_at'],
        'completed_at' => $row['completed_at']
    ]);
}

// ==========================================
// ADMIN APIs
// ==========================================
if ($action === 'admin_list') {
    $stmt = mysqli_prepare($koneksi, "SELECT * FROM reward_redemptions WHERE status IN ('pending', 'processing') ORDER BY created_at DESC");
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);
    $items = [];
    while ($row = mysqli_fetch_assoc($result)) {
        $items[] = $row;
    }
    mysqli_stmt_close($stmt);
    api_respond(true, 'Pending requests retrieved', ['items' => $items]);
}

if ($action === 'admin_process') {
    $input = $_POST;
    if (empty($input)) $input = json_decode(file_get_contents('php://input'), true) ?? [];
    $id = (int)($input['id'] ?? 0);
    if (!$id) api_respond(false, 'ID tidak valid', null, 400);

    $stmt = mysqli_prepare($koneksi, "UPDATE reward_redemptions SET status = 'processing', processed_at = NOW() WHERE id = ?");
    mysqli_stmt_bind_param($stmt, "i", $id);
    mysqli_stmt_execute($stmt);
    mysqli_stmt_close($stmt);
    api_respond(true, 'Status diubah menjadi processing');
}

if ($action === 'admin_complete') {
    $input = $_POST;
    if (empty($input)) $input = json_decode(file_get_contents('php://input'), true) ?? [];
    $id = (int)($input['id'] ?? 0);
    if (!$id) api_respond(false, 'ID tidak valid', null, 400);

    $stmt = mysqli_prepare($koneksi, "UPDATE reward_redemptions SET status = 'completed', completed_at = NOW() WHERE id = ?");
    mysqli_stmt_bind_param($stmt, "i", $id);
    mysqli_stmt_execute($stmt);
    mysqli_stmt_close($stmt);
    api_respond(true, 'Status diubah menjadi completed');
}

if ($action === 'admin_reject') {
    $input = $_POST;
    if (empty($input)) $input = json_decode(file_get_contents('php://input'), true) ?? [];
    $id = (int)($input['id'] ?? 0);
    $note = trim($input['admin_note'] ?? 'Penukaran poin ditolak oleh Admin.');
    if (!$id) api_respond(false, 'ID tidak valid', null, 400);

    // Get redemption info to refund points
    $stmt = mysqli_prepare($koneksi, "SELECT user_id, redeem_point, status FROM reward_redemptions WHERE id = ? LIMIT 1");
    mysqli_stmt_bind_param($stmt, "i", $id);
    mysqli_stmt_execute($stmt);
    $r = mysqli_stmt_get_result($stmt);
    $row = mysqli_fetch_assoc($r);
    mysqli_stmt_close($stmt);

    if ($row && $row['status'] !== 'rejected') {
        $uid = (int)$row['user_id'];
        $pts = (int)$row['redeem_point'];
        // Refund points
        $stmt_refund = mysqli_prepare($koneksi, "UPDATE pengguna SET saldo = saldo + ? WHERE id_pengguna = ?");
        mysqli_stmt_bind_param($stmt_refund, "di", $pts, $uid);
        mysqli_stmt_execute($stmt_refund);
        mysqli_stmt_close($stmt_refund);
    }

    $stmt_upd = mysqli_prepare($koneksi, "UPDATE reward_redemptions SET status = 'rejected', admin_note = ?, completed_at = NOW() WHERE id = ?");
    mysqli_stmt_bind_param($stmt_upd, "si", $note, $id);
    mysqli_stmt_execute($stmt_upd);
    mysqli_stmt_close($stmt_upd);
    api_respond(true, 'Status diubah menjadi rejected dan poin dikembalikan');
}

api_respond(false, 'Endpoint tidak ditemukan atau action tidak valid (' . htmlspecialchars($action) . ')', null, 404);
?>
