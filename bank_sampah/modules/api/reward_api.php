<?php
// modules/api/reward_api.php
// Endpoint: Citizen & Admin Reward Redemption module (Tukar Poin)
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

if (($SERVER['REQUEST_METHOD'] ?? '') === 'OPTIONS' || ($_SERVER['REQUEST_METHOD'] ?? '') === 'OPTIONS') {
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

// Auto-create & migrate tables
$create_table_sql = "CREATE TABLE IF NOT EXISTS reward_redemptions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  transaction_code VARCHAR(50) NULL UNIQUE,
  user_id INT NOT NULL,
  destination_type VARCHAR(50) NOT NULL,
  provider VARCHAR(100) NOT NULL,
  account_name VARCHAR(150) NOT NULL,
  account_holder_name VARCHAR(150) NULL,
  account_number VARCHAR(100) NOT NULL,
  redeem_point INT NOT NULL,
  conversion_rate INT DEFAULT 10,
  estimated_amount DOUBLE NOT NULL,
  status VARCHAR(50) DEFAULT 'pending',
  admin_note TEXT,
  admin_id INT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  processed_at DATETIME NULL,
  completed_at DATETIME NULL,
  INDEX idx_user_id (user_id),
  INDEX idx_status (status),
  INDEX idx_transaction_code (transaction_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;";
mysqli_query($koneksi, $create_table_sql);

$migrations = [
    "ALTER TABLE reward_redemptions ADD COLUMN transaction_code VARCHAR(50) NULL UNIQUE AFTER id",
    "ALTER TABLE reward_redemptions ADD COLUMN account_holder_name VARCHAR(150) NULL AFTER account_name",
    "ALTER TABLE reward_redemptions ADD COLUMN admin_id INT NULL AFTER admin_note",
    "ALTER TABLE reward_redemptions ADD COLUMN transfer_proof VARCHAR(255) NULL AFTER status",
    "ALTER TABLE reward_redemptions ADD COLUMN rejection_reason TEXT NULL AFTER admin_note",
    "UPDATE reward_redemptions SET account_holder_name = account_name WHERE (account_holder_name IS NULL OR account_holder_name = '') AND account_name IS NOT NULL",
    "UPDATE reward_redemptions SET account_name = account_holder_name WHERE (account_name IS NULL OR account_name = '') AND account_holder_name IS NOT NULL",
    "UPDATE reward_redemptions SET transaction_code = CONCAT('RDM-', DATE_FORMAT(created_at, '%Y%m%d'), '-', LPAD(id, 6, '0')) WHERE transaction_code IS NULL OR transaction_code = ''",
    "ALTER TABLE pengguna ADD COLUMN reserved_saldo DOUBLE DEFAULT 0.00"
];

foreach ($migrations as $query) {
    try {
        @mysqli_query($koneksi, $query);
    } catch (Exception $e) {
        // Ignore duplicate column errors or other migration errors
    }
}

mysqli_query($koneksi, "CREATE TABLE IF NOT EXISTS redemption_audit_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  redemption_id INT NOT NULL,
  transaction_code VARCHAR(50) NULL,
  action VARCHAR(50) NOT NULL,
  old_status VARCHAR(50) NOT NULL,
  new_status VARCHAR(50) NOT NULL,
  admin_id INT NULL,
  reason TEXT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_redemption_id (redemption_id),
  INDEX idx_transaction_code (transaction_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");

// Helper: ambil user dari token
function get_user_from_token($koneksi) {
    $token = null;
    if (function_exists('getallheaders')) {
        $headers = getallheaders();
        foreach ($headers as $key => $value) {
            if (strtolower($key) === 'authorization') {
                $token = str_replace('Bearer ', '', $value);
                break;
            }
        }
    }
    if (!$token && isset($_SERVER['HTTP_AUTHORIZATION'])) {
        $token = str_replace('Bearer ', '', $_SERVER['HTTP_AUTHORIZATION']);
    }
    if (!$token && isset($_GET['token'])) $token = $_GET['token'];
    if (!$token && isset($_POST['token'])) $token = $_POST['token'];
    if (!$token) return null;

    $stmt = mysqli_prepare($koneksi, "SELECT id_pengguna, nama_lengkap, username, level, saldo, COALESCE(reserved_saldo, 0) as reserved_saldo FROM pengguna WHERE api_token = ? LIMIT 1");
    if (!$stmt) return null;
    mysqli_stmt_bind_param($stmt, "s", $token);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);
    $user = mysqli_fetch_assoc($result);
    mysqli_stmt_close($stmt);
    return $user;
}

function log_redemption_audit($koneksi, $redemption_id, $trx_code, $action, $old_status, $new_status, $admin_id = null, $reason = null) {
    $stmt = mysqli_prepare($koneksi, "INSERT INTO redemption_audit_logs (redemption_id, transaction_code, action, old_status, new_status, admin_id, reason, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, NOW())");
    if ($stmt) {
        mysqli_stmt_bind_param($stmt, "issssis", $redemption_id, $trx_code, $action, $old_status, $new_status, $admin_id, $reason);
        mysqli_stmt_execute($stmt);
        mysqli_stmt_close($stmt);
    }
}

function notify_citizen_redemption($koneksi, $user_id, $title, $message, $tipe = 'info') {
    $stmt = mysqli_prepare($koneksi, "INSERT INTO notifikasi (id_pengguna, judul, pesan, tipe) VALUES (?, ?, ?, ?)");
    if ($stmt) {
        mysqli_stmt_bind_param($stmt, "isss", $user_id, $title, $message, $tipe);
        mysqli_stmt_execute($stmt);
        mysqli_stmt_close($stmt);
    }
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
    elseif (strpos($path, '/admin/reward/redemption/audit_log') !== false) $action = 'audit_log';
    elseif (strpos($path, '/admin/reward/redemption') !== false) $action = 'admin_list';
}

if (!$user && in_array($action, ['balance', 'request'])) {
    api_respond(false, 'Unauthorized. Token tidak valid atau tidak ditemukan.', null, 401);
}

// ==========================================
// CITIZEN API: GET /reward/balance
// ==========================================
if ($action === 'balance') {
    $stmt = mysqli_prepare($koneksi, "SELECT saldo, COALESCE(reserved_saldo, 0) as reserved_saldo FROM pengguna WHERE id_pengguna = ?");
    mysqli_stmt_bind_param($stmt, "i", $user_id);
    mysqli_stmt_execute($stmt);
    $r = mysqli_stmt_get_result($stmt);
    $row = mysqli_fetch_assoc($r);
    mysqli_stmt_close($stmt);

    $points = $row ? floatval($row['saldo']) : 0;
    $reserved = $row ? floatval($row['reserved_saldo']) : 0;
    $conversion_rate = 1; // 1 Poin = Rp 1
    $money = $points * $conversion_rate;

    api_respond(true, 'Reward balance retrieved', [
        'current_point' => (int)$points,
        'reserved_point' => (int)$reserved,
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
        $trx_code = $row['transaction_code'] ?: sprintf("RDM-%s-%06d", date('Ymd', strtotime($row['created_at'])), $row['id']);
        $items[] = [
            'id' => (string)$row['id'],
            'transaction_code' => $trx_code,
            'transaction_number' => $trx_code,
            'user_id' => (int)$row['user_id'],
            'destination_type' => $row['destination_type'],
            'provider' => $row['provider'],
            'account_name' => $row['account_name'],
            'account_holder_name' => $row['account_holder_name'] ?: $row['account_name'],
            'account_number' => $row['account_number'],
            'redeem_point' => (int)$row['redeem_point'],
            'conversion_rate' => (int)$row['conversion_rate'],
            'estimated_amount' => floatval($row['estimated_amount']),
            'status' => $row['status'],
            'admin_note' => $row['admin_note'],
            'transfer_proof' => $row['transfer_proof'],
            'rejection_reason' => $row['rejection_reason'],
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
    $input = $_POST;
    if (empty($input)) {
        $json_input = json_decode(file_get_contents('php://input'), true);
        if (is_array($json_input)) $input = $json_input;
    }

    $dest_type = trim($input['destination_type'] ?? '');
    $provider = trim($input['provider'] ?? '');
    $acc_num = trim($input['account_number'] ?? '');
    $acc_holder = trim($input['account_holder_name'] ?? $input['account_name'] ?? '');
    $acc_name = trim($input['account_name'] ?? $acc_holder);
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

    $conversion_rate = 1;
    $estimated_amount = $redeem_point * $conversion_rate;
    $status = 'processing'; // Langsung diproses sesuai requirement baru

    mysqli_begin_transaction($koneksi);
    try {
        // Reserve the points: deduct from available saldo, add to reserved_saldo
        $stmt_deduct = mysqli_prepare($koneksi, "UPDATE pengguna SET saldo = saldo - ?, reserved_saldo = COALESCE(reserved_saldo, 0) + ? WHERE id_pengguna = ?");
        mysqli_stmt_bind_param($stmt_deduct, "ddi", $redeem_point, $redeem_point, $user_id);
        mysqli_stmt_execute($stmt_deduct);
        mysqli_stmt_close($stmt_deduct);

        // Insert request
        $stmt_insert = mysqli_prepare($koneksi, "INSERT INTO reward_redemptions (user_id, destination_type, provider, account_name, account_holder_name, account_number, redeem_point, conversion_rate, estimated_amount, status, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())");
        mysqli_stmt_bind_param($stmt_insert, "isssssiids", $user_id, $dest_type, $provider, $acc_name, $acc_holder, $acc_num, $redeem_point, $conversion_rate, $estimated_amount, $status);
        mysqli_stmt_execute($stmt_insert);
        $new_id = mysqli_insert_id($koneksi);
        mysqli_stmt_close($stmt_insert);

        $trx_code = sprintf("RDM-%s-%06d", date('Ymd'), $new_id);
        $stmt_code = mysqli_prepare($koneksi, "UPDATE reward_redemptions SET transaction_code = ? WHERE id = ?");
        mysqli_stmt_bind_param($stmt_code, "si", $trx_code, $new_id);
        mysqli_stmt_execute($stmt_code);
        mysqli_stmt_close($stmt_code);

        // Audit log & Notification with exact required text
        log_redemption_audit($koneksi, $new_id, $trx_code, 'SUBMIT_REQUEST', '', 'pending', null, 'Permintaan penukaran poin diajukan');
        notify_citizen_redemption($koneksi, $user_id, 'Tukar Poin Diterima', "Tukar poin Anda telah diterima. Kode: $trx_code", 'info');

        mysqli_commit($koneksi);

        api_respond(true, 'Permintaan tukar poin berhasil dikirim', [
            'id' => (string)$new_id,
            'transaction_code' => $trx_code,
            'transaction_number' => $trx_code,
            'destination_type' => $dest_type,
            'provider' => $provider,
            'account_name' => $acc_name,
            'account_holder_name' => $acc_holder,
            'account_number' => $acc_num,
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

    $stmt = mysqli_prepare($koneksi, "SELECT r.*, u.nama_lengkap, u.no_telepon FROM reward_redemptions r JOIN pengguna u ON r.user_id = u.id_pengguna WHERE r.id = ? LIMIT 1");
    mysqli_stmt_bind_param($stmt, "i", $id);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);
    $row = mysqli_fetch_assoc($result);
    mysqli_stmt_close($stmt);

    if (!$row) {
        api_respond(false, 'Data penukaran tidak ditemukan', null, 404);
    }

    $trx_code = $row['transaction_code'] ?: sprintf("RDM-%s-%06d", date('Ymd', strtotime($row['created_at'])), $row['id']);

    api_respond(true, 'Detail penukaran retrieved', [
        'id' => (string)$row['id'],
        'transaction_code' => $trx_code,
        'transaction_number' => $trx_code,
        'user_id' => (int)$row['user_id'],
        'citizen_name' => $row['nama_lengkap'],
        'citizen_phone' => $row['no_telepon'],
        'destination_type' => $row['destination_type'],
        'provider' => $row['provider'],
        'account_name' => $row['account_name'],
        'account_holder_name' => $row['account_holder_name'] ?: $row['account_name'],
        'account_number' => $row['account_number'],
        'redeem_point' => (int)$row['redeem_point'],
        'conversion_rate' => (int)$row['conversion_rate'],
        'estimated_amount' => floatval($row['estimated_amount']),
        'status' => $row['status'],
        'admin_note' => $row['admin_note'],
        'transfer_proof' => $row['transfer_proof'],
        'rejection_reason' => $row['rejection_reason'],
        'created_at' => $row['created_at'],
        'processed_at' => $row['processed_at'],
        'completed_at' => $row['completed_at']
    ]);
}

// ==========================================
// ADMIN APIs & AUDIT LOGS
// ==========================================
if ($action === 'admin_list') {
    $status_filter = $_GET['status'] ?? '';
    $sql = "SELECT r.*, u.nama_lengkap, u.no_telepon, u.username FROM reward_redemptions r JOIN pengguna u ON r.user_id = u.id_pengguna";
    $params = [];
    $types = '';

    if (!empty($status_filter) && $status_filter !== 'all') {
        $status_list = explode(',', $status_filter);
        $placeholders = implode(',', array_fill(0, count($status_list), '?'));
        $sql .= " WHERE r.status IN ($placeholders)";
        foreach ($status_list as $st) {
            $params[] = trim(strtolower($st));
            $types .= 's';
        }
    }
    $sql .= " ORDER BY r.created_at DESC";

    $stmt = mysqli_prepare($koneksi, $sql);
    if (!empty($params)) {
        mysqli_stmt_bind_param($stmt, $types, ...$params);
    }
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);
    $items = [];
    while ($row = mysqli_fetch_assoc($result)) {
        $trx_code = $row['transaction_code'] ?: sprintf("RDM-%s-%06d", date('Ymd', strtotime($row['created_at'])), $row['id']);
        $row['transaction_code'] = $trx_code;
        $row['transaction_number'] = $trx_code;
        $row['account_holder_name'] = $row['account_holder_name'] ?: $row['account_name'];
        $items[] = $row;
    }
    mysqli_stmt_close($stmt);
    api_respond(true, 'Redemption requests retrieved', ['items' => $items]);
}

if ($action === 'audit_log') {
    $redemption_id = (int)($_GET['redemption_id'] ?? $_GET['id'] ?? 0);
    $stmt = mysqli_prepare($koneksi, "SELECT l.*, p.nama_lengkap as admin_name FROM redemption_audit_logs l LEFT JOIN pengguna p ON l.admin_id = p.id_pengguna WHERE l.redemption_id = ? ORDER BY l.created_at ASC");
    mysqli_stmt_bind_param($stmt, "i", $redemption_id);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);
    $items = [];
    while ($row = mysqli_fetch_assoc($result)) {
        $items[] = $row;
    }
    mysqli_stmt_close($stmt);
    api_respond(true, 'Audit logs retrieved', ['items' => $items]);
}

if ($action === 'admin_process') {
    $input = $_POST;
    if (empty($input)) $input = json_decode(file_get_contents('php://input'), true) ?? [];
    $id = (int)($input['id'] ?? 0);
    $admin_id = isset($user['id_pengguna']) ? (int)$user['id_pengguna'] : (int)($input['admin_id'] ?? 0);
    if (!$id) api_respond(false, 'ID tidak valid', null, 400);

    $stmt_get = mysqli_prepare($koneksi, "SELECT * FROM reward_redemptions WHERE id = ? LIMIT 1");
    mysqli_stmt_bind_param($stmt_get, "i", $id);
    mysqli_stmt_execute($stmt_get);
    $row = mysqli_fetch_assoc(mysqli_stmt_get_result($stmt_get));
    mysqli_stmt_close($stmt_get);

    if (!$row) api_respond(false, 'Data penukaran tidak ditemukan', null, 404);
    $old_status = $row['status'];
    $trx_code = $row['transaction_code'] ?: sprintf("RDM-%s-%06d", date('Ymd', strtotime($row['created_at'])), $row['id']);

    $stmt = mysqli_prepare($koneksi, "UPDATE reward_redemptions SET status = 'processing', processed_at = NOW(), admin_id = ? WHERE id = ?");
    mysqli_stmt_bind_param($stmt, "ii", $admin_id, $id);
    mysqli_stmt_execute($stmt);
    mysqli_stmt_close($stmt);

    log_redemption_audit($koneksi, $id, $trx_code, 'PROCESS', $old_status, 'processing', $admin_id, 'Admin memproses penukaran poin');
    notify_citizen_redemption($koneksi, (int)$row['user_id'], 'Tukar Poin Diproses', "Admin sedang memproses penukaran poin Anda. Kode: $trx_code", 'info');

    api_respond(true, 'Status berhasil diubah menjadi Processing. Request dipindahkan ke daftar Ongoing/Processing.');
}

if ($action === 'admin_complete') {
    $input = $_POST;
    if (empty($input)) $input = json_decode(file_get_contents('php://input'), true) ?? [];
    $id = (int)($input['id'] ?? 0);
    $admin_id = isset($user['id_pengguna']) ? (int)$user['id_pengguna'] : (int)($input['admin_id'] ?? 0);
    if (!$id) api_respond(false, 'ID tidak valid', null, 400);

    $stmt_get = mysqli_prepare($koneksi, "SELECT * FROM reward_redemptions WHERE id = ? LIMIT 1");
    mysqli_stmt_bind_param($stmt_get, "i", $id);
    mysqli_stmt_execute($stmt_get);
    $row = mysqli_fetch_assoc(mysqli_stmt_get_result($stmt_get));
    mysqli_stmt_close($stmt_get);

    if (!$row) api_respond(false, 'Data penukaran tidak ditemukan', null, 404);
    $old_status = $row['status'];
    $trx_code = $row['transaction_code'] ?: sprintf("RDM-%s-%06d", date('Ymd', strtotime($row['created_at'])), $row['id']);
    $pts = (int)$row['redeem_point'];
    $uid = (int)$row['user_id'];

    mysqli_begin_transaction($koneksi);
    try {
        if ($old_status !== 'completed' && $old_status !== 'rejected') {
            // Finalize deduction from reserved_saldo (permanently gone)
            $stmt_fin = mysqli_prepare($koneksi, "UPDATE pengguna SET reserved_saldo = GREATEST(0, COALESCE(reserved_saldo, 0) - ?) WHERE id_pengguna = ?");
            mysqli_stmt_bind_param($stmt_fin, "di", $pts, $uid);
            mysqli_stmt_execute($stmt_fin);
            mysqli_stmt_close($stmt_fin);
        }

        $stmt = mysqli_prepare($koneksi, "UPDATE reward_redemptions SET status = 'completed', completed_at = NOW(), admin_id = ? WHERE id = ?");
        mysqli_stmt_bind_param($stmt, "ii", $admin_id, $id);
        mysqli_stmt_execute($stmt);
        mysqli_stmt_close($stmt);

        log_redemption_audit($koneksi, $id, $trx_code, 'COMPLETE', $old_status, 'completed', $admin_id, 'Penukaran poin berhasil diselesaikan dan dana telah dikirim');
        notify_citizen_redemption($koneksi, $uid, 'Tukar Poin Berhasil', "Penukaran poin berhasil. Kode: $trx_code", 'success');

        mysqli_commit($koneksi);
        api_respond(true, 'Penukaran poin berhasil selesai (Completed). Dana telah dikirim dan riwayat pengguna diperbarui.');
    } catch (Exception $e) {
        mysqli_rollback($koneksi);
        api_respond(false, 'Gagal menyelesaikan penukaran: ' . $e->getMessage(), null, 500);
    }
}

if ($action === 'admin_reject') {
    $input = $_POST;
    if (empty($input)) $input = json_decode(file_get_contents('php://input'), true) ?? [];
    $id = (int)($input['id'] ?? 0);
    $note = trim($input['admin_note'] ?? $input['reject_reason'] ?? '');
    $admin_id = isset($user['id_pengguna']) ? (int)$user['id_pengguna'] : (int)($input['admin_id'] ?? 0);
    if (!$id) api_respond(false, 'ID tidak valid', null, 400);
    if (empty($note)) api_respond(false, 'Alasan penolakan (Reject Reason) wajib diisi.', null, 400);

    $stmt_get = mysqli_prepare($koneksi, "SELECT * FROM reward_redemptions WHERE id = ? LIMIT 1");
    mysqli_stmt_bind_param($stmt_get, "i", $id);
    mysqli_stmt_execute($stmt_get);
    $row = mysqli_fetch_assoc(mysqli_stmt_get_result($stmt_get));
    mysqli_stmt_close($stmt_get);

    if (!$row) api_respond(false, 'Data penukaran tidak ditemukan', null, 404);
    $old_status = $row['status'];
    $trx_code = $row['transaction_code'] ?: sprintf("RDM-%s-%06d", date('Ymd', strtotime($row['created_at'])), $row['id']);
    $pts = (int)$row['redeem_point'];
    $uid = (int)$row['user_id'];

    mysqli_begin_transaction($koneksi);
    try {
        if ($old_status !== 'rejected' && $old_status !== 'completed') {
            // Restore points to available saldo and release from reserved_saldo
            $stmt_refund = mysqli_prepare($koneksi, "UPDATE pengguna SET saldo = saldo + ?, reserved_saldo = GREATEST(0, COALESCE(reserved_saldo, 0) - ?) WHERE id_pengguna = ?");
            mysqli_stmt_bind_param($stmt_refund, "ddi", $pts, $pts, $uid);
            mysqli_stmt_execute($stmt_refund);
            mysqli_stmt_close($stmt_refund);
        }

        $stmt_upd = mysqli_prepare($koneksi, "UPDATE reward_redemptions SET status = 'rejected', admin_note = ?, completed_at = NOW(), admin_id = ? WHERE id = ?");
        mysqli_stmt_bind_param($stmt_upd, "sii", $note, $admin_id, $id);
        mysqli_stmt_execute($stmt_upd);
        mysqli_stmt_close($stmt_upd);

        log_redemption_audit($koneksi, $id, $trx_code, 'REJECT', $old_status, 'rejected', $admin_id, $note);
        notify_citizen_redemption($koneksi, $uid, 'Tukar Poin Ditolak', "Penukaran poin ditolak. Alasan: $note. Kode: $trx_code", 'warning');

        mysqli_commit($koneksi);
        api_respond(true, 'Status diubah menjadi Rejected. Poin pengguna telah dikembalikan ke saldo aktif.');
    } catch (Exception $e) {
        mysqli_rollback($koneksi);
        api_respond(false, 'Gagal menolak penukaran: ' . $e->getMessage(), null, 500);
    }
}

api_respond(false, 'Endpoint tidak ditemukan atau action tidak valid (' . htmlspecialchars($action) . ')', null, 404);
?>
