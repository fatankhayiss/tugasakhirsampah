<?php
// modules/api/profile_api.php
// Endpoint: GET profil user, POST update profil
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Accept, Authorization');

ini_set('display_errors', 0);
error_reporting(E_ALL);

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

if (!function_exists('getallheaders')) {
    function getallheaders() {
        $headers = [];
        foreach ($_SERVER as $name => $value) {
            if (substr($name, 0, 5) == 'HTTP_') {
                $headers[str_replace(' ', '-', ucwords(strtolower(str_replace('_', ' ', substr($name, 5)))))] = $value;
            }
        }
        return $headers;
    }
}

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
    if (!$token && isset($_GET['token'])) {
        $token = $_GET['token'];
    }
    if (!$token && isset($_POST['token'])) {
        $token = $_POST['token'];
    }
    if (!$token) return null;

    $stmt = mysqli_prepare($koneksi, "SELECT id_pengguna, nama_lengkap, username, level, alamat, no_telepon, email, saldo, foto_profil, tanggal_daftar, latitude, longitude FROM pengguna WHERE api_token = ? LIMIT 1");
    mysqli_stmt_bind_param($stmt, "s", $token);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);
    $user = mysqli_fetch_assoc($result);
    mysqli_stmt_close($stmt);
    return $user;
}

$user = get_user_from_token($koneksi);
if (!$user) {
    api_respond(false, 'Unauthorized. Token tidak valid atau tidak ditemukan.', null, 401);
}

// =====================
// GET — Ambil profil
// =====================
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $user_id = (int)$user['id_pengguna'];

    // Total berat sampah yang pernah disetor
    $waste_query = "SELECT COALESCE(SUM(ds.berat_kg), 0) as total_kg
                    FROM transaksi t
                    JOIN detail_setoran ds ON ds.id_transaksi_setor = t.id_transaksi
                    WHERE t.id_warga = ? AND t.tipe_transaksi = 'setor'";
    $stmt = mysqli_prepare($koneksi, $waste_query);
    mysqli_stmt_bind_param($stmt, "i", $user_id);
    mysqli_stmt_execute($stmt);
    $wr = mysqli_stmt_get_result($stmt);
    $waste_row = mysqli_fetch_assoc($wr);
    $total_waste = floatval($waste_row['total_kg']);
    mysqli_stmt_close($stmt);

    // Total transaksi setor (count)
    $count_query = "SELECT COUNT(*) as total FROM transaksi WHERE id_warga = ? AND tipe_transaksi = 'setor'";
    $stmt2 = mysqli_prepare($koneksi, $count_query);
    mysqli_stmt_bind_param($stmt2, "i", $user_id);
    mysqli_stmt_execute($stmt2);
    $cr = mysqli_stmt_get_result($stmt2);
    $count_row = mysqli_fetch_assoc($cr);
    $total_setor = (int)$count_row['total'];
    mysqli_stmt_close($stmt2);

    $profile = [
        'id' => (int)$user['id_pengguna'],
        'nama_lengkap' => $user['nama_lengkap'],
        'username' => $user['username'],
        'level' => $user['level'],
        'alamat' => $user['alamat'],
        'no_telepon' => $user['no_telepon'],
        'email' => $user['email'],
        'saldo' => floatval($user['saldo']),
        'total_waste_kg' => $total_waste,
        'total_setor' => $total_setor,
        'foto_profil' => $user['foto_profil'],
        'tanggal_daftar' => $user['tanggal_daftar'],
        'latitude' => isset($user['latitude']) ? floatval($user['latitude']) : null,
        'longitude' => isset($user['longitude']) ? floatval($user['longitude']) : null,
    ];

    api_respond(true, 'Profil berhasil diambil', $profile);
}

// =====================
// POST — Update profil
// =====================
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $user_id = (int)$user['id_pengguna'];

    $nama = isset($_POST['nama_lengkap']) ? trim($_POST['nama_lengkap']) : null;
    $username = isset($_POST['username']) ? trim($_POST['username']) : null;
    $alamat = isset($_POST['alamat']) ? trim($_POST['alamat']) : null;
    $no_telepon = isset($_POST['no_telepon']) ? trim($_POST['no_telepon']) : null;
    $email = isset($_POST['email']) ? trim($_POST['email']) : null;
    $remove_foto = isset($_POST['remove_foto']) ? trim($_POST['remove_foto']) : null;
    
    $latitude = isset($_POST['latitude']) ? floatval($_POST['latitude']) : null;
    $longitude = isset($_POST['longitude']) ? floatval($_POST['longitude']) : null;

    // Cek duplikat Username jika diubah (kecuali untuk driver)
    if ($username !== null && $username !== '' && $user['level'] !== 'driver') {
        $stmt_check = mysqli_prepare($koneksi, "SELECT id_pengguna FROM pengguna WHERE username = ? AND id_pengguna != ? LIMIT 1");
        mysqli_stmt_bind_param($stmt_check, "si", $username, $user_id);
        mysqli_stmt_execute($stmt_check);
        $res_check = mysqli_stmt_get_result($stmt_check);
        if (mysqli_fetch_assoc($res_check)) {
            mysqli_stmt_close($stmt_check);
            api_respond(false, 'Username sudah digunakan.', null, 400);
        }
        mysqli_stmt_close($stmt_check);
    }

    // Cek duplikat Email jika diubah
    if ($email !== null && $email !== '') {
        $stmt_check_email = mysqli_prepare($koneksi, "SELECT id_pengguna FROM pengguna WHERE email = ? AND id_pengguna != ? LIMIT 1");
        mysqli_stmt_bind_param($stmt_check_email, "si", $email, $user_id);
        mysqli_stmt_execute($stmt_check_email);
        $res_check_email = mysqli_stmt_get_result($stmt_check_email);
        if (mysqli_fetch_assoc($res_check_email)) {
            mysqli_stmt_close($stmt_check_email);
            api_respond(false, 'Email sudah terdaftar.', null, 400);
        }
        mysqli_stmt_close($stmt_check_email);
    }

    $updates = [];
    $types = '';
    $values = [];

    if ($nama !== null) {
        $updates[] = "nama_lengkap = ?";
        $types .= 's';
        $values[] = $nama;
    }
    if ($username !== null && $username !== '') {
        $updates[] = "username = ?";
        $types .= 's';
        $values[] = $username;
    }
    if ($alamat !== null) {
        $updates[] = "alamat = ?";
        $types .= 's';
        $values[] = $alamat;
    }
    if ($no_telepon !== null) {
        $updates[] = "no_telepon = ?";
        $types .= 's';
        $values[] = $no_telepon;
    }
    if ($email !== null) {
        $updates[] = "email = ?";
        $types .= 's';
        $values[] = $email;
    }
    if ($latitude !== null) {
        $updates[] = "latitude = ?";
        $types .= 'd';
        $values[] = $latitude;
    }
    if ($longitude !== null) {
        $updates[] = "longitude = ?";
        $types .= 'd';
        $values[] = $longitude;
    }
    if ($remove_foto === '1' || $remove_foto === 'true') {
        $updates[] = "foto_profil = NULL";
    }

    // Handle foto upload
    if (isset($_FILES['foto_profil']) && $_FILES['foto_profil']['error'] === UPLOAD_ERR_OK) {
        $file = $_FILES['foto_profil'];
        $finfo = finfo_open(FILEINFO_MIME_TYPE);
        $mime = finfo_file($finfo, $file['tmp_name']);
        finfo_close($finfo);
        $allowedMime = ['image/jpeg', 'image/png', 'image/webp', 'image/jpg'];
        
        // Also allow fallback if finfo returns octet-stream but extension is valid
        $ext = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
        $validExts = ['jpg', 'jpeg', 'png', 'webp'];
        
        if (in_array($mime, $allowedMime) || in_array($ext, $validExts)) {
            $uploadDir = __DIR__ . '/../../assets/uploads/profil/';
            if (!is_dir($uploadDir)) mkdir($uploadDir, 0755, true);
            $ext = pathinfo($file['name'], PATHINFO_EXTENSION);
            $filename = 'profil_' . $user_id . '_' . time() . '.' . preg_replace('/[^a-zA-Z0-9]/', '', $ext);
            $target = $uploadDir . $filename;
            if (move_uploaded_file($file['tmp_name'], $target)) {
                $foto_path = 'assets/uploads/profil/' . $filename;
                $updates[] = "foto_profil = ?";
                $types .= 's';
                $values[] = $foto_path;
            }
        }
    }

    if (empty($updates)) {
        api_respond(false, 'Tidak ada data yang diupdate', null, 400);
    }

    $types .= 'i';
    $values[] = $user_id;

    $sql = "UPDATE pengguna SET " . implode(', ', $updates) . " WHERE id_pengguna = ?";
    $stmt = mysqli_prepare($koneksi, $sql);
    mysqli_stmt_bind_param($stmt, $types, ...$values);

    if (mysqli_stmt_execute($stmt)) {
        api_respond(true, 'Profil berhasil diupdate');
    } else {
        api_respond(false, 'Gagal mengupdate profil: ' . mysqli_error($koneksi), null, 500);
    }
    mysqli_stmt_close($stmt);
}
?>
