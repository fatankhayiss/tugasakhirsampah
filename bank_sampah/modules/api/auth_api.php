<?php
// modules/api/auth_api.php
// Endpoint: Login & Register untuk Mobile (warga) dan Driver
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
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

try {
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        api_respond(false, 'Method not allowed', null, 405);
    }

    $action = isset($_POST['action']) ? trim($_POST['action']) : (isset($_GET['action']) ? trim($_GET['action']) : 'login');

    // =====================
    // LOGIN
    // =====================
    if ($action === 'login') {
        $input_json = json_decode(file_get_contents('php://input'), true);
        $username = isset($_POST['username']) ? trim($_POST['username']) : (isset($input_json['username']) ? trim($input_json['username']) : (isset($input_json['phone_number']) ? trim($input_json['phone_number']) : ''));
        $password = isset($_POST['password']) ? $_POST['password'] : (isset($input_json['password']) ? $input_json['password'] : '');

        if (empty($username)) {
            api_respond(false, 'Username atau Nomor HP belum diisi', null, 400);
        }
        if (empty($password)) {
            api_respond(false, 'Password belum diisi', null, 400);
        }

        // Clean phone for matching e.g. 0821-4045-7048 -> 082140457048
        $clean_phone = preg_replace('/[^0-9]/', '', $username);
        if (empty($clean_phone)) {
            $clean_phone = $username;
        }

        // Cari user berdasarkan username, email, nama_lengkap, ATAU no_telepon (baik mentah maupun angka saja)
        $query = "SELECT id_pengguna, nama_lengkap, username, password, level, alamat, no_telepon, email, status, saldo, foto_profil, tanggal_daftar, latitude, longitude
                  FROM pengguna
                  WHERE username = ? OR email = ? OR no_telepon = ? OR nama_lengkap = ? OR username = ? OR no_telepon = ?
                  LIMIT 1";
        $stmt = mysqli_prepare($koneksi, $query);
        mysqli_stmt_bind_param($stmt, "ssssss", $username, $username, $username, $username, $clean_phone, $clean_phone);
        mysqli_stmt_execute($stmt);
        $result = mysqli_stmt_get_result($stmt);

        if ($user = mysqli_fetch_assoc($result)) {
            // Verifikasi Password (dukung password_hash maupun fallback text jika ada)
            if (password_verify($password, $user['password']) || $password === $user['password']) {
                // Verifikasi status aktif khusus untuk driver
                if ($user['level'] === 'driver' && isset($user['status']) && strtolower($user['status']) !== 'aktif' && strtolower($user['status']) !== 'active') {
                    api_respond(false, 'Akun Driver belum aktif. Silakan hubungi Admin.', null, 403);
                }

                // Generate token sederhana
                $token = bin2hex(random_bytes(32));

                // Simpan token ke database
                $update_token = "UPDATE pengguna SET api_token = ? WHERE id_pengguna = ?";
                $stmt_token = mysqli_prepare($koneksi, $update_token);
                mysqli_stmt_bind_param($stmt_token, "si", $token, $user['id_pengguna']);
                mysqli_stmt_execute($stmt_token);
                mysqli_stmt_close($stmt_token);

                // Hitung total sampah yang pernah disetor (dalam kg)
                $total_waste_query = "SELECT COALESCE(SUM(ds.berat_kg), 0) as total_kg
                                      FROM transaksi t
                                      JOIN detail_setoran ds ON ds.id_transaksi_setor = t.id_transaksi
                                      WHERE t.id_warga = ? AND t.tipe_transaksi = 'setor'";
                $stmt_waste = mysqli_prepare($koneksi, $total_waste_query);
                mysqli_stmt_bind_param($stmt_waste, "i", $user['id_pengguna']);
                mysqli_stmt_execute($stmt_waste);
                $waste_result = mysqli_stmt_get_result($stmt_waste);
                $waste_row = mysqli_fetch_assoc($waste_result);
                $total_waste = floatval($waste_row['total_kg']);
                mysqli_stmt_close($stmt_waste);

                unset($user['password']); // Jangan kirim password

                $user_data = [
                    'id' => (int)$user['id_pengguna'],
                    'nama_lengkap' => $user['nama_lengkap'],
                    'username' => $user['username'],
                    'level' => $user['level'],
                    'alamat' => $user['alamat'],
                    'no_telepon' => $user['no_telepon'],
                    'email' => $user['email'],
                    'saldo' => floatval($user['saldo']),
                    'total_waste_kg' => $total_waste,
                    'foto_profil' => $user['foto_profil'],
                    'tanggal_daftar' => $user['tanggal_daftar'],
                    'status' => $user['status'] ?? 'aktif',
                    'token' => $token,
                    'latitude' => isset($user['latitude']) ? floatval($user['latitude']) : null,
                    'longitude' => isset($user['longitude']) ? floatval($user['longitude']) : null,
                ];

                if ($user['level'] === 'driver') {
                    $stmt_st = mysqli_prepare($koneksi, "UPDATE pengguna SET driver_status = 'online' WHERE id_pengguna = ?");
                    if ($stmt_st) {
                        mysqli_stmt_bind_param($stmt_st, "i", $user['id_pengguna']);
                        mysqli_stmt_execute($stmt_st);
                        mysqli_stmt_close($stmt_st);
                    }
                    $user_data['driver_status'] = 'online';

                    // detail_driver has been refactored to an activity log table, so we no longer fetch profile data from it.
                    // Driver vehicle profile is managed separately via driver_daily_vehicle.
                }

                api_respond(true, 'Login berhasil', $user_data);
            } else {
                api_respond(false, 'Password salah.', null, 401);
            }
        } else {
            api_respond(false, 'Akun tidak ditemukan.', null, 404);
        }
        mysqli_stmt_close($stmt);
    }

    // =====================
    // REGISTER (untuk warga baru)
    // =====================
    elseif ($action === 'register') {
        $input_json = json_decode(file_get_contents('php://input'), true);
        $nama = isset($_POST['nama_lengkap']) ? trim($_POST['nama_lengkap']) : (isset($input_json['nama_lengkap']) ? trim($input_json['nama_lengkap']) : '');
        $email = isset($_POST['email']) ? trim($_POST['email']) : (isset($input_json['email']) ? trim($input_json['email']) : '');
        $password = isset($_POST['password']) ? $_POST['password'] : (isset($input_json['password']) ? $input_json['password'] : '');
        $no_telepon = isset($_POST['no_telepon']) ? trim($_POST['no_telepon']) : (isset($input_json['no_telepon']) ? trim($input_json['no_telepon']) : '');
        $alamat = isset($_POST['alamat']) ? trim($_POST['alamat']) : (isset($input_json['alamat']) ? trim($input_json['alamat']) : '');
        $req_username = isset($_POST['username']) ? trim($_POST['username']) : (isset($input_json['username']) ? trim($input_json['username']) : '');
        $google_uid = isset($_POST['google_uid']) ? trim($_POST['google_uid']) : (isset($input_json['google_uid']) ? trim($input_json['google_uid']) : null);
        
        $latitude = isset($_POST['latitude']) ? floatval($_POST['latitude']) : (isset($input_json['latitude']) ? floatval($input_json['latitude']) : null);
        $longitude = isset($_POST['longitude']) ? floatval($_POST['longitude']) : (isset($input_json['longitude']) ? floatval($input_json['longitude']) : null);

        // Data tambahan untuk driver
        // Removed detailed driver registration fields to simplify as requested.

        if (empty($nama) || empty($password)) {
            api_respond(false, 'Nama dan password wajib diisi', null, 400);
        }

        if (strlen($password) < 6) {
            api_respond(false, 'Password minimal 6 karakter', null, 400);
        }

        // Gunakan username dari request jika ada, jika tidak gunakan no_telepon, jika tidak generate dari nama
        if (!empty($req_username)) {
            $username = $req_username;
        } else {
            $username = !empty($no_telepon) ? $no_telepon : strtolower(str_replace(' ', '', $nama)) . rand(100, 999);
        }

        // Cek apakah username, nomor telepon, email, atau google_uid sudah terdaftar
        $check = "SELECT id_pengguna FROM pengguna WHERE username = ? OR (no_telepon = ? AND no_telepon IS NOT NULL AND no_telepon != '') OR (email = ? AND email IS NOT NULL AND email != '') OR (google_uid = ? AND google_uid IS NOT NULL AND google_uid != '')";
        $stmt_check = mysqli_prepare($koneksi, $check);
        $check_val = !empty($no_telepon) ? $no_telepon : $username;
        mysqli_stmt_bind_param($stmt_check, "ssss", $username, $check_val, $email, $google_uid);
        mysqli_stmt_execute($stmt_check);
        $check_result = mysqli_stmt_get_result($stmt_check);

        if (mysqli_num_rows($check_result) > 0) {
            api_respond(false, 'Username, nomor telepon, atau email sudah terdaftar', null, 409);
        }
        mysqli_stmt_close($stmt_check);

        $hashed_password = password_hash($password, PASSWORD_DEFAULT);
        $token = bin2hex(random_bytes(32));

        $requested_level = (isset($_POST['level']) && $_POST['level'] === 'driver') ? 'driver' : 'warga';

        $insert = "INSERT INTO pengguna (nama_lengkap, username, password, level, alamat, no_telepon, email, google_uid, saldo, api_token, latitude, longitude)
                   VALUES (?, ?, ?, ?, ?, ?, ?, ?, 0.00, ?, ?, ?)";
        $stmt_insert = mysqli_prepare($koneksi, $insert);
        mysqli_stmt_bind_param($stmt_insert, "sssssssssdd", $nama, $username, $hashed_password, $requested_level, $alamat, $no_telepon, $email, $google_uid, $token, $latitude, $longitude);

        if (mysqli_stmt_execute($stmt_insert)) {
            $new_id = mysqli_insert_id($koneksi);

            // Buat notifikasi selamat datang sesuai level
            if ($requested_level === 'driver') {
                $notif_pesan = "Akun Driver Anda telah berhasil terdaftar. Selamat bertugas menjemput sampah!";
                
                // detail_driver no longer holds profile data.
            } else {
                $notif_pesan = "Akun Anda telah berhasil terdaftar. Mulai setor sampah dan kumpulkan poin!";
            }
            
            $notif_sql = "INSERT INTO notifikasi (id_pengguna, judul, pesan, tipe) VALUES (?, 'Selamat datang di iTrashy!', ?, 'info')";
            $stmt_notif = mysqli_prepare($koneksi, $notif_sql);
            if ($stmt_notif) {
                mysqli_stmt_bind_param($stmt_notif, "is", $new_id, $notif_pesan);
                mysqli_stmt_execute($stmt_notif);
                mysqli_stmt_close($stmt_notif);
            }

            $user_data = [
                'id' => $new_id,
                'nama_lengkap' => $nama,
                'username' => $username,
                'level' => $requested_level,
                'alamat' => $alamat,
                'kecamatan' => $kecamatan,
                'kab_kota' => $kab_kota,
                'wilayah' => $wilayah,
                'no_telepon' => $no_telepon,
                'email' => $email,
                'google_uid' => $google_uid,
                'saldo' => 0.0,
                'total_waste_kg' => 0.0,
                'foto_profil' => null,
                'status' => 'aktif',
                'token' => $token,
                'latitude' => $latitude,
                'longitude' => $longitude,
            ];
            api_respond(true, 'Registrasi berhasil', $user_data, 201);
        } else {
            api_respond(false, 'Gagal mendaftarkan pengguna: ' . mysqli_error($koneksi), null, 500);
        }
        mysqli_stmt_close($stmt_insert);
    }

    // =====================
    // GOOGLE LOGIN (untuk warga)
    // =====================
    elseif ($action === 'google_login') {
        $input_json = json_decode(file_get_contents('php://input'), true);
        $google_uid = isset($_POST['google_uid']) ? trim($_POST['google_uid']) : (isset($input_json['google_uid']) ? trim($input_json['google_uid']) : '');
        $email = isset($_POST['email']) ? trim($_POST['email']) : (isset($input_json['email']) ? trim($input_json['email']) : '');
        $nama = isset($_POST['nama_lengkap']) ? trim($_POST['nama_lengkap']) : (isset($input_json['nama_lengkap']) ? trim($input_json['nama_lengkap']) : (isset($input_json['name']) ? trim($input_json['name']) : 'User Warga'));
        $foto_profil = isset($_POST['foto_profil']) ? trim($_POST['foto_profil']) : (isset($input_json['photo_url']) ? trim($input_json['photo_url']) : null);

        if (empty($google_uid) && empty($email)) {
            api_respond(false, 'Google UID atau Email wajib diisi', null, 400);
        }

        // Cari user berdasarkan google_uid atau email
        $query = "SELECT id_pengguna, nama_lengkap, username, level, alamat, no_telepon, email, google_uid, saldo, foto_profil, tanggal_daftar, latitude, longitude
                  FROM pengguna
                  WHERE (google_uid = ? AND google_uid IS NOT NULL AND google_uid != '') OR (email = ? AND email IS NOT NULL AND email != '')
                  LIMIT 1";
        $stmt = mysqli_prepare($koneksi, $query);
        mysqli_stmt_bind_param($stmt, "ss", $google_uid, $email);
        mysqli_stmt_execute($stmt);
        $result = mysqli_stmt_get_result($stmt);

        if ($user = mysqli_fetch_assoc($result)) {
            // Jika google_uid di db belum ada / kosong, update link ke akun ini
            if (empty($user['google_uid']) && !empty($google_uid)) {
                $up_sql = "UPDATE pengguna SET google_uid = ? WHERE id_pengguna = ?";
                $stmt_up = mysqli_prepare($koneksi, $up_sql);
                mysqli_stmt_bind_param($stmt_up, "si", $google_uid, $user['id_pengguna']);
                mysqli_stmt_execute($stmt_up);
                mysqli_stmt_close($stmt_up);
                $user['google_uid'] = $google_uid;
            }

            // Generate token
            $token = bin2hex(random_bytes(32));
            $update_token = "UPDATE pengguna SET api_token = ? WHERE id_pengguna = ?";
            $stmt_token = mysqli_prepare($koneksi, $update_token);
            mysqli_stmt_bind_param($stmt_token, "si", $token, $user['id_pengguna']);
            mysqli_stmt_execute($stmt_token);
            mysqli_stmt_close($stmt_token);

            // Hitung total sampah
            $total_waste_query = "SELECT COALESCE(SUM(ds.berat_kg), 0) as total_kg
                                  FROM transaksi t
                                  JOIN detail_setoran ds ON ds.id_transaksi_setor = t.id_transaksi
                                  WHERE t.id_warga = ? AND t.tipe_transaksi = 'setor'";
            $stmt_waste = mysqli_prepare($koneksi, $total_waste_query);
            mysqli_stmt_bind_param($stmt_waste, "i", $user['id_pengguna']);
            mysqli_stmt_execute($stmt_waste);
            $waste_result = mysqli_stmt_get_result($stmt_waste);
            $waste_row = mysqli_fetch_assoc($waste_result);
            $total_waste = floatval($waste_row['total_kg']);
            mysqli_stmt_close($stmt_waste);

            $user_data = [
                'id' => (int)$user['id_pengguna'],
                'nama_lengkap' => $user['nama_lengkap'],
                'username' => $user['username'],
                'level' => $user['level'],
                'alamat' => $user['alamat'],
                'no_telepon' => $user['no_telepon'],
                'email' => $user['email'],
                'google_uid' => $user['google_uid'],
                'saldo' => floatval($user['saldo']),
                'total_waste_kg' => $total_waste,
                'foto_profil' => $user['foto_profil'] ?? $foto_profil,
                'tanggal_daftar' => $user['tanggal_daftar'],
                'status' => $user['status'] ?? 'aktif',
                'token' => $token,
                'latitude' => isset($user['latitude']) ? floatval($user['latitude']) : null,
                'longitude' => isset($user['longitude']) ? floatval($user['longitude']) : null,
            ];
            api_respond(true, 'Login berhasil', $user_data, 200);
        } else {
            // User belum ada -> buat otomatis (Level warga)
            if (empty($email)) {
                api_respond(false, 'Email Google diperlukan untuk pendaftaran otomatis', null, 400);
            }
            $email_parts = explode('@', $email);
            $username_base = strtolower(preg_replace('/[^a-zA-Z0-9]/', '', $email_parts[0]));
            if (empty($username_base)) {
                $username_base = 'user';
            }
            $username = $username_base . rand(100, 999);

            $c_usr = mysqli_query($koneksi, "SELECT id_pengguna FROM pengguna WHERE username = '$username'");
            if (mysqli_num_rows($c_usr) > 0) {
                $username = $username_base . rand(1000, 9999);
            }

            $password_random = password_hash(bin2hex(random_bytes(16)), PASSWORD_DEFAULT);
            $token = bin2hex(random_bytes(32));
            $level = 'warga';
            $alamat_default = '';
            $no_telp_default = '';

            $insert = "INSERT INTO pengguna (nama_lengkap, username, password, level, alamat, no_telepon, email, google_uid, foto_profil, saldo, api_token)
                       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 0.00, ?)";
            $stmt_insert = mysqli_prepare($koneksi, $insert);
            mysqli_stmt_bind_param($stmt_insert, "ssssssssss", $nama, $username, $password_random, $level, $alamat_default, $no_telp_default, $email, $google_uid, $foto_profil, $token);

            if (mysqli_stmt_execute($stmt_insert)) {
                $new_id = mysqli_insert_id($koneksi);
                $notif_pesan = "Akun Anda telah berhasil terdaftar melalui akun Google. Mulai setor sampah dan kumpulkan poin!";
                $notif_sql = "INSERT INTO notifikasi (id_pengguna, judul, pesan, tipe) VALUES (?, 'Selamat datang di iTrashy!', ?, 'info')";
                $stmt_notif = mysqli_prepare($koneksi, $notif_sql);
                if ($stmt_notif) {
                    mysqli_stmt_bind_param($stmt_notif, "is", $new_id, $notif_pesan);
                    mysqli_stmt_execute($stmt_notif);
                    mysqli_stmt_close($stmt_notif);
                }

                $user_data = [
                    'id' => $new_id,
                    'nama_lengkap' => $nama,
                    'username' => $username,
                    'level' => $level,
                    'alamat' => $alamat_default,
                    'no_telepon' => $no_telp_default,
                    'email' => $email,
                    'google_uid' => $google_uid,
                    'saldo' => 0.0,
                    'total_waste_kg' => 0.0,
                    'foto_profil' => $foto_profil,
                    'tanggal_daftar' => date('Y-m-d H:i:s'),
                    'status' => 'aktif',
                    'token' => $token,
                ];
                api_respond(true, 'Registrasi berhasil', $user_data, 201);
            } else {
                api_respond(false, 'Gagal mendaftarkan akun Google: ' . mysqli_error($koneksi), null, 500);
            }
        }
    }

    // =====================
    // FORGOT PASSWORD
    // =====================
    elseif ($action === 'forgot_password') {
        $input_json = json_decode(file_get_contents('php://input'), true);
        $email = isset($_POST['email']) ? trim($_POST['email']) : (isset($input_json['email']) ? trim($input_json['email']) : '');

        if (empty($email)) {
            api_respond(false, 'Email wajib diisi.', null, 400);
        }

        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            api_respond(false, 'Format email tidak valid.', null, 400);
        }

        $query = "SELECT id_pengguna, email, google_uid, password, nama_lengkap FROM pengguna WHERE email = ? LIMIT 1";
        $stmt = mysqli_prepare($koneksi, $query);
        mysqli_stmt_bind_param($stmt, "s", $email);
        mysqli_stmt_execute($stmt);
        $result = mysqli_stmt_get_result($stmt);
        $user = mysqli_fetch_assoc($result);
        mysqli_stmt_close($stmt);

        if (!$user) {
            api_respond(false, 'Email tidak ditemukan.', null, 404);
        }

        // Jika akun terdaftar via Google Login, tolak permintaan reset password & kembalikan kode GOOGLE_ACCOUNT
        if (!empty($user['google_uid'])) {
            api_respond(false, 'This account uses Google Sign-In. Please continue using Google to sign in.', ['code' => 'GOOGLE_ACCOUNT'], 400);
        }

        // Pastikan tabel password_resets ada dengan kolom email, otp_code, dan reset_token
        mysqli_query($koneksi, "CREATE TABLE IF NOT EXISTS `password_resets` (
          `id` INT(11) NOT NULL AUTO_INCREMENT,
          `user_id` INT(11) NOT NULL,
          `email` VARCHAR(255) NULL,
          `token` VARCHAR(255) NOT NULL,
          `otp_code` VARCHAR(10) NULL,
          `reset_token` VARCHAR(255) NULL,
          `created_at` DATETIME NOT NULL,
          `expired_at` DATETIME NOT NULL,
          `used` TINYINT(1) NOT NULL DEFAULT 0,
          PRIMARY KEY (`id`),
          KEY `idx_user_id` (`user_id`),
          KEY `idx_email` (`email`),
          KEY `idx_expired_at` (`expired_at`),
          CONSTRAINT `fk_password_resets_user` FOREIGN KEY (`user_id`) REFERENCES `pengguna` (`id_pengguna`) ON DELETE CASCADE ON UPDATE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;");

        try { @mysqli_query($koneksi, "ALTER TABLE `password_resets` ADD COLUMN `email` VARCHAR(255) NULL AFTER `user_id`"); } catch (Throwable $e) {}
        try { @mysqli_query($koneksi, "ALTER TABLE `password_resets` ADD COLUMN `otp_code` VARCHAR(10) NULL AFTER `token`"); } catch (Throwable $e) {}
        try { @mysqli_query($koneksi, "ALTER TABLE `password_resets` ADD COLUMN `reset_token` VARCHAR(255) NULL AFTER `otp_code`"); } catch (Throwable $e) {}

        // Resend generates a new OTP. Old OTP becomes invalid.
        $stmt_inv = mysqli_prepare($koneksi, "UPDATE password_resets SET used = 1 WHERE user_id = ? AND used = 0");
        mysqli_stmt_bind_param($stmt_inv, "i", $user['id_pengguna']);
        mysqli_stmt_execute($stmt_inv);
        mysqli_stmt_close($stmt_inv);

        $otp_code = sprintf("%06d", mt_rand(100000, 999999));
        $token = bin2hex(random_bytes(32));
        $created_at = date('Y-m-d H:i:s');
        $expired_at = date('Y-m-d H:i:s', time() + 300); // EXACTLY 5 MINUTES

        $insert_reset = "INSERT INTO password_resets (user_id, email, token, otp_code, created_at, expired_at, used) VALUES (?, ?, ?, ?, ?, ?, 0)";
        $stmt_reset = mysqli_prepare($koneksi, $insert_reset);
        mysqli_stmt_bind_param($stmt_reset, "isssss", $user['id_pengguna'], $email, $token, $otp_code, $created_at, $expired_at);
        mysqli_stmt_execute($stmt_reset);
        mysqli_stmt_close($stmt_reset);

        error_log("[OTP_DEBUG] OTP Generated -> Code: {$otp_code} for user_id: {$user['id_pengguna']} ({$email})");
        error_log("[OTP_DEBUG] Database Insert -> Stored in password_resets for {$email}. Expiration: {$expired_at} (300 seconds)");

        require_once __DIR__ . '/../../config/mail.php';
        $subject = "Kode Verifikasi Reset Password";
        $html_body = "
        <!DOCTYPE html>
        <html lang='id'>
        <head>
            <meta charset='UTF-8'>
            <style>
                body { font-family: 'Plus Jakarta Sans', Arial, sans-serif; background-color: #F8FAF9; color: #1E293B; margin: 0; padding: 20px; }
                .container { max-width: 520px; margin: 0 auto; background-color: #FFFFFF; border-radius: 16px; padding: 32px; box-shadow: 0 4px 20px rgba(0,0,0,0.05); border: 1px solid #E2E8F0; }
                .header { text-align: center; margin-bottom: 24px; }
                .header h2 { color: #2E9E5B; font-size: 24px; margin: 0; font-weight: 800; }
                .otp-box { background-color: #EBF8F2; border: 2px dashed #34C759; border-radius: 12px; padding: 22px; text-align: center; margin: 24px 0; }
                .otp-code { font-size: 34px; font-weight: 800; color: #1B8E5F; letter-spacing: 8px; margin: 0; }
                .text { font-size: 15px; line-height: 1.6; color: #475569; margin: 12px 0; }
                .footer { margin-top: 32px; font-size: 12px; color: #94A3B8; text-align: center; border-top: 1px solid #F1F5F9; padding-top: 16px; }
            </style>
        </head>
        <body>
            <div class='container'>
                <div class='header'>
                    <h2>I-Trashy Security</h2>
                </div>
                <p class='text'>Halo,</p>
                <p class='text'>Gunakan kode OTP berikut untuk mereset password akun Anda.</p>
                <div class='otp-box'>
                    <p class='otp-code'>{$otp_code}</p>
                </div>
                <p class='text'><strong>Kode berlaku selama 5 menit.</strong></p>
                <p class='text'>Jika Anda tidak meminta reset password, abaikan email ini.</p>
                <div class='footer'>
                    &copy; " . date('Y') . " Bank Sampah I-Trashy. All rights reserved.
                </div>
            </div>
        </body>
        </html>";

        $alt_body = "Halo,\r\n\r\nGunakan kode OTP berikut untuk mereset password akun Anda.\r\n\r\n{$otp_code}\r\n\r\nKode berlaku selama 5 menit.\r\nJika Anda tidak meminta reset password, abaikan email ini.";

        $send_result = send_smtp_email($email, $user['nama_lengkap'] ?: 'User', $subject, $html_body, $alt_body);

        if (!$send_result['success']) {
            // Hapus atau tandai record OTP batal jika pengiriman email gagal
            mysqli_query($koneksi, "UPDATE password_resets SET used = 1 WHERE user_id = {$user['id_pengguna']} AND used = 0");
            error_log("[SMTP_ERROR] Forgot Password flow aborted: SMTP delivery failed to {$email}: " . $send_result['error']);
            api_respond(false, 'Gagal mengirim email OTP: ' . $send_result['error'], ['smtp_error' => $send_result['error']], 500);
        }

        api_respond(true, 'Kode verifikasi berhasil dikirim ke email ' . $email . '.', [
            'email' => $email,
            'expires_in_seconds' => 300
        ]);
    }

    // =====================
    // VERIFY OTP
    // =====================
    elseif ($action === 'verify_otp') {
        $input_json = json_decode(file_get_contents('php://input'), true);
        $email = isset($_POST['email']) ? trim($_POST['email']) : (isset($input_json['email']) ? trim($input_json['email']) : '');
        $otp_code = isset($_POST['otp_code']) ? trim($_POST['otp_code']) : (isset($_POST['otp']) ? trim($_POST['otp']) : (isset($input_json['otp_code']) ? trim($input_json['otp_code']) : (isset($input_json['otp']) ? trim($input_json['otp']) : '')));

        if (empty($email) || empty($otp_code)) {
            api_respond(false, 'Email dan kode verifikasi wajib diisi.', null, 400);
        }

        $query = "SELECT id_pengguna FROM pengguna WHERE email = ? LIMIT 1";
        $stmt = mysqli_prepare($koneksi, $query);
        mysqli_stmt_bind_param($stmt, "s", $email);
        mysqli_stmt_execute($stmt);
        $result = mysqli_stmt_get_result($stmt);
        $user = mysqli_fetch_assoc($result);
        mysqli_stmt_close($stmt);

        if (!$user) {
            api_respond(false, 'Email tidak ditemukan.', null, 404);
        }

        $query_reset = "SELECT * FROM password_resets WHERE user_id = ? AND (otp_code = ? OR token = ?) ORDER BY id DESC LIMIT 1";
        $stmt_r = mysqli_prepare($koneksi, $query_reset);
        mysqli_stmt_bind_param($stmt_r, "iss", $user['id_pengguna'], $otp_code, $otp_code);
        mysqli_stmt_execute($stmt_r);
        $res_r = mysqli_stmt_get_result($stmt_r);
        $record = mysqli_fetch_assoc($res_r);
        mysqli_stmt_close($stmt_r);

        if (!$record) {
            error_log("[OTP_VERIFY_LOG] Failed: Invalid OTP code ({$otp_code}) for user_id: {$user['id_pengguna']}");
            api_respond(false, 'Kode verifikasi tidak valid.', null, 400);
        }

        if ((int)$record['used'] === 1) {
            error_log("[OTP_VERIFY_LOG] Failed: OTP code ({$otp_code}) already used for user_id: {$user['id_pengguna']}");
            api_respond(false, 'Kode verifikasi tidak valid atau sudah digunakan.', null, 400);
        }

        if (strtotime($record['expired_at']) < time()) {
            error_log("[OTP_VERIFY_LOG] Failed: OTP code ({$otp_code}) expired on {$record['expired_at']} (Current time: " . date('Y-m-d H:i:s') . ")");
            api_respond(false, 'Kode verifikasi telah kedaluwarsa.', ['expired' => true], 400);
        }

        $reset_token = bin2hex(random_bytes(32));
        $update_reset = "UPDATE password_resets SET used = 1, reset_token = ? WHERE id = ?";
        $stmt_up = mysqli_prepare($koneksi, $update_reset);
        mysqli_stmt_bind_param($stmt_up, "si", $reset_token, $record['id']);
        mysqli_stmt_execute($stmt_up);
        mysqli_stmt_close($stmt_up);

        error_log("[OTP_VERIFY_LOG] Success: OTP code ({$otp_code}) verified for user_id: {$user['id_pengguna']} ({$email}). Reset token generated.");

        api_respond(true, 'Kode verifikasi benar.', [
            'email' => $email,
            'reset_token' => $reset_token
        ]);
    }

    // =====================
    // RESET PASSWORD
    // =====================
    elseif ($action === 'reset_password') {
        $input_json = json_decode(file_get_contents('php://input'), true);
        $email = isset($_POST['email']) ? trim($_POST['email']) : (isset($input_json['email']) ? trim($input_json['email']) : '');
        $reset_token = isset($_POST['reset_token']) ? trim($_POST['reset_token']) : (isset($input_json['reset_token']) ? trim($input_json['reset_token']) : '');
        $new_password = isset($_POST['new_password']) ? $_POST['new_password'] : (isset($_POST['password']) ? $_POST['password'] : (isset($input_json['new_password']) ? $input_json['new_password'] : (isset($input_json['password']) ? $input_json['password'] : '')));

        if (empty($email) || empty($new_password)) {
            api_respond(false, 'Email dan password baru wajib diisi.', null, 400);
        }
        if (strlen($new_password) < 8) {
            api_respond(false, 'Password minimal 8 karakter.', null, 400);
        }

        $query = "SELECT id_pengguna FROM pengguna WHERE email = ? LIMIT 1";
        $stmt = mysqli_prepare($koneksi, $query);
        mysqli_stmt_bind_param($stmt, "s", $email);
        mysqli_stmt_execute($stmt);
        $result = mysqli_stmt_get_result($stmt);
        $user = mysqli_fetch_assoc($result);
        mysqli_stmt_close($stmt);

        if (!$user) {
            api_respond(false, 'Email tidak ditemukan.', null, 404);
        }

        $query_token = "SELECT * FROM password_resets WHERE user_id = ? AND (reset_token = ? OR (reset_token IS NOT NULL AND reset_token != '')) AND used = 1 ORDER BY id DESC LIMIT 1";
        $stmt_t = mysqli_prepare($koneksi, $query_token);
        mysqli_stmt_bind_param($stmt_t, "is", $user['id_pengguna'], $reset_token);
        mysqli_stmt_execute($stmt_t);
        $res_t = mysqli_stmt_get_result($stmt_t);
        $reset_record = mysqli_fetch_assoc($res_t);
        mysqli_stmt_close($stmt_t);

        if (!$reset_record || (!empty($reset_token) && $reset_record['reset_token'] !== $reset_token)) {
            api_respond(false, 'Sesi pemulihan password tidak valid atau telah berakhir. Silakan ulangi proses lupa password.', null, 400);
        }

        $hashed_password = password_hash($new_password, PASSWORD_BCRYPT);
        $update_user = "UPDATE pengguna SET password = ?, api_token = NULL WHERE id_pengguna = ?";
        $stmt_u = mysqli_prepare($koneksi, $update_user);
        mysqli_stmt_bind_param($stmt_u, "si", $hashed_password, $user['id_pengguna']);
        mysqli_stmt_execute($stmt_u);
        mysqli_stmt_close($stmt_u);

        $delete_resets = "DELETE FROM password_resets WHERE user_id = ?";
        $stmt_del = mysqli_prepare($koneksi, $delete_resets);
        mysqli_stmt_bind_param($stmt_del, "i", $user['id_pengguna']);
        mysqli_stmt_execute($stmt_del);
        mysqli_stmt_close($stmt_del);

        error_log("[RESET_PASSWORD_LOG] Success: Password successfully updated and hashed for user_id: {$user['id_pengguna']} ({$email})");

        api_respond(true, 'Password berhasil diperbarui.');
    }

    // =====================
    // LOGOUT
    // =====================
    elseif ($action === 'logout') {
        $headers = getallheaders();
        $auth_header = '';
        foreach ($headers as $k => $v) {
            if (strtolower($k) === 'authorization') {
                $auth_header = $v;
                break;
            }
        }
        if (!empty($auth_header)) {
            $parts = explode(' ', $auth_header);
            if (count($parts) == 2 && $parts[0] === 'Bearer') {
                $token = $parts[1];
                $stmt = mysqli_prepare($koneksi, "UPDATE pengguna SET driver_status = 'offline' WHERE api_token = ? AND level = 'driver'");
                if ($stmt) {
                    mysqli_stmt_bind_param($stmt, "s", $token);
                    mysqli_stmt_execute($stmt);
                    mysqli_stmt_close($stmt);
                }
            }
        }
        api_respond(true, 'Logout berhasil');
    }

    else {
        api_respond(false, 'Action tidak valid. Gunakan: login atau register', null, 400);
    }
} catch (Throwable $e) {
    api_respond(false, 'Error Database/Sistem: ' . $e->getMessage(), null, 500);
}
?>
