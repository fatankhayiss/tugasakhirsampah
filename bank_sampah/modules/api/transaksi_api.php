<?php
// modules/api/transaksi_api.php
// Endpoint: Riwayat transaksi warga (setor & tarik saldo)
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
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

// Auth via token
function get_user_id_from_token($koneksi) {
    $token = null;
    $headers = getallheaders();
    foreach ($headers as $key => $value) {
        if (strtolower($key) === 'authorization') {
            $token = str_replace('Bearer ', '', $value);
            break;
        }
    }
    if (!$token && isset($_GET['token'])) $token = $_GET['token'];
    if (!$token) return null;

    $stmt = mysqli_prepare($koneksi, "SELECT id_pengguna FROM pengguna WHERE api_token = ? LIMIT 1");
    mysqli_stmt_bind_param($stmt, "s", $token);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);
    $row = mysqli_fetch_assoc($result);
    mysqli_stmt_close($stmt);
    return $row ? (int)$row['id_pengguna'] : null;
}

$user_id = get_user_id_from_token($koneksi);
if (!$user_id) {
    // Fallback: allow user_id param (for admin tools)
    $user_id = isset($_GET['user_id']) ? (int)$_GET['user_id'] : null;
}
if (!$user_id) {
    api_respond(false, 'Unauthorized', null, 401);
}

$page = max(1, (int)($_GET['page'] ?? 1));
$limit = max(1, (int)($_GET['limit'] ?? 20));
$offset = ($page - 1) * $limit;
$tipe = isset($_GET['tipe']) ? $_GET['tipe'] : null; // 'setor' atau 'tarik_saldo'

// Build query
$where = "WHERE t.id_warga = ?";
$params = [$user_id];
$types = 'i';

if ($tipe && in_array($tipe, ['setor', 'tarik_saldo'])) {
    $where .= " AND t.tipe_transaksi = ?";
    $params[] = $tipe;
    $types .= 's';
}

// Count total
$count_sql = "SELECT COUNT(*) as total FROM transaksi t $where";
$stmt_c = mysqli_prepare($koneksi, $count_sql);
mysqli_stmt_bind_param($stmt_c, $types, ...$params);
mysqli_stmt_execute($stmt_c);
$cr = mysqli_stmt_get_result($stmt_c);
$total = (int)mysqli_fetch_assoc($cr)['total'];
mysqli_stmt_close($stmt_c);

// Get data
$sql = "SELECT t.id_transaksi, t.tipe_transaksi, t.total_nilai, t.tanggal_transaksi, t.keterangan,
               p.nama_lengkap as petugas
        FROM transaksi t
        LEFT JOIN pengguna p ON t.id_petugas_pencatat = p.id_pengguna
        $where
        ORDER BY t.tanggal_transaksi DESC
        LIMIT ? OFFSET ?";
$params[] = $limit;
$params[] = $offset;
$types .= 'ii';

$stmt = mysqli_prepare($koneksi, $sql);
mysqli_stmt_bind_param($stmt, $types, ...$params);
mysqli_stmt_execute($stmt);
$result = mysqli_stmt_get_result($stmt);

$items = [];
while ($row = mysqli_fetch_assoc($result)) {
    $item = [
        'id' => (int)$row['id_transaksi'],
        'tipe' => $row['tipe_transaksi'],
        'total_nilai' => floatval($row['total_nilai']),
        'tanggal' => $row['tanggal_transaksi'],
        'keterangan' => $row['keterangan'],
        'petugas' => $row['petugas'],
    ];

    // Jika tipe setor, ambil detail setoran
    if ($row['tipe_transaksi'] === 'setor') {
        $detail_sql = "SELECT ds.berat_kg, ds.harga_saat_setor, ds.subtotal_nilai, js.nama_sampah
                       FROM detail_setoran ds
                       JOIN jenis_sampah js ON ds.id_jenis_sampah = js.id_jenis_sampah
                       WHERE ds.id_transaksi_setor = ?";
        $stmt_d = mysqli_prepare($koneksi, $detail_sql);
        $trx_id = (int)$row['id_transaksi'];
        mysqli_stmt_bind_param($stmt_d, "i", $trx_id);
        mysqli_stmt_execute($stmt_d);
        $dr = mysqli_stmt_get_result($stmt_d);
        $details = [];
        $total_berat = 0;
        while ($d = mysqli_fetch_assoc($dr)) {
            $details[] = [
                'nama_sampah' => $d['nama_sampah'],
                'berat_kg' => floatval($d['berat_kg']),
                'harga_per_kg' => floatval($d['harga_saat_setor']),
                'subtotal' => floatval($d['subtotal_nilai']),
            ];
            $total_berat += floatval($d['berat_kg']);
        }
        $item['details'] = $details;
        $item['total_berat_kg'] = $total_berat;
        mysqli_stmt_close($stmt_d);
    }

    $items[] = $item;
}
mysqli_stmt_close($stmt);

api_respond(true, 'Riwayat transaksi', [
    'total' => $total,
    'page' => $page,
    'limit' => $limit,
    'items' => $items,
]);
?>
