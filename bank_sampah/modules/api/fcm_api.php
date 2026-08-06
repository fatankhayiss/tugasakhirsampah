<?php
// modules/api/fcm_api.php
// Endpoint: Update FCM Token untuk user
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
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
    
    if (!$token) {
        $raw = file_get_contents('php://input');
        $json = json_decode($raw, true);
        if ($json && isset($json['api_token'])) $token = $json['api_token'];
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

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $auth_user = get_auth_user($koneksi);
    if (!$auth_user) {
        api_respond(false, 'Unauthorized', null, 401);
    }

    $input_json = json_decode(file_get_contents('php://input'), true);
    $action = isset($_POST['action']) ? trim($_POST['action']) : (isset($input_json['action']) ? trim($input_json['action']) : '');

    if ($action === 'update_token') {
        $fcm_token = isset($_POST['fcm_token']) ? trim($_POST['fcm_token']) : (isset($input_json['fcm_token']) ? trim($input_json['fcm_token']) : '');

        if (empty($fcm_token)) {
            api_respond(false, 'FCM Token tidak boleh kosong', null, 400);
        }

        $user_id = $auth_user['id_pengguna'];
        $query = "UPDATE pengguna SET fcm_token = ? WHERE id_pengguna = ?";
        $stmt = mysqli_prepare($koneksi, $query);
        mysqli_stmt_bind_param($stmt, "si", $fcm_token, $user_id);

        if (mysqli_stmt_execute($stmt)) {
            api_respond(true, 'FCM Token berhasil diperbarui');
        } else {
            api_respond(false, 'Gagal memperbarui FCM Token: ' . mysqli_error($koneksi), null, 500);
        }
        mysqli_stmt_close($stmt);
    } else {
        api_respond(false, 'Action tidak valid', null, 400);
    }
} else {
    api_respond(false, 'Method not allowed', null, 405);
}
?>
