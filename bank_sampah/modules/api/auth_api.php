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

    $action = isset($_POST['action']) ? $_POST['action'] : (isset($_GET['action']) ? $_GET['action'] : 'login');

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
        $query = "SELECT id_pengguna, nama_lengkap, username, password, level, alamat, no_telepon, email, saldo, foto_profil, tanggal_daftar, status
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
                ];

                if ($user['level'] === 'driver') {
                    $driver_query = "SELECT tipe_kendaraan, jenis_kendaraan, plat_nomor, kapasitas_berat, kecamatan, kab_kota, wilayah, kode_pos
                                     FROM detail_driver WHERE id_pengguna = ? LIMIT 1";
                    $stmt_driver = mysqli_prepare($koneksi, $driver_query);
                    mysqli_stmt_bind_param($stmt_driver, "i", $user['id_pengguna']);
                    mysqli_stmt_execute($stmt_driver);
                    $driver_result = mysqli_stmt_get_result($stmt_driver);
                    if ($driver_row = mysqli_fetch_assoc($driver_result)) {
                        $user_data['tipe_kendaraan'] = $driver_row['tipe_kendaraan'];
                        $user_data['jenis_kendaraan'] = $driver_row['jenis_kendaraan'];
                        $user_data['plat_nomor'] = $driver_row['plat_nomor'];
                        $user_data['kapasitas_berat'] = floatval($driver_row['kapasitas_berat']);
                        $user_data['kecamatan'] = $driver_row['kecamatan'];
                        $user_data['kab_kota'] = $driver_row['kab_kota'];
                        $user_data['wilayah'] = $driver_row['wilayah'];
                        $user_data['kode_pos'] = $driver_row['kode_pos'];
                    }
                    mysqli_stmt_close($stmt_driver);
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

        // Data tambahan untuk driver
        $kecamatan = isset($_POST['kecamatan']) ? trim($_POST['kecamatan']) : '';
        $kab_kota = isset($_POST['kab_kota']) ? trim($_POST['kab_kota']) : '';
        $wilayah = isset($_POST['wilayah']) ? trim($_POST['wilayah']) : '';
        $kode_pos = isset($_POST['kode_pos']) ? trim($_POST['kode_pos']) : '';
        $tipe_kendaraan = isset($_POST['tipe_kendaraan']) ? trim($_POST['tipe_kendaraan']) : '';
        $jenis_kendaraan = isset($_POST['jenis_kendaraan']) ? trim($_POST['jenis_kendaraan']) : '';
        $plat_nomor = isset($_POST['plat_nomor']) ? trim($_POST['plat_nomor']) : '';
        $kapasitas_berat = isset($_POST['kapasitas_berat']) ? floatval($_POST['kapasitas_berat']) : 0.00;

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

        $insert = "INSERT INTO pengguna (nama_lengkap, username, password, level, alamat, no_telepon, email, google_uid, saldo, api_token, status)
                   VALUES (?, ?, ?, ?, ?, ?, ?, ?, 0.00, ?, 'aktif')";
        $stmt_insert = mysqli_prepare($koneksi, $insert);
        mysqli_stmt_bind_param($stmt_insert, "sssssssss", $nama, $username, $hashed_password, $requested_level, $alamat, $no_telepon, $email, $google_uid, $token);

        if (mysqli_stmt_execute($stmt_insert)) {
            $new_id = mysqli_insert_id($koneksi);

            // Buat notifikasi selamat datang sesuai level
            if ($requested_level === 'driver') {
                $notif_pesan = "Akun Driver Anda telah berhasil terdaftar. Selamat bertugas menjemput sampah!";
                
                // Simpan ke detail_driver
                $insert_detail = "INSERT INTO detail_driver (id_pengguna, kecamatan, kab_kota, wilayah, kode_pos, tipe_kendaraan, jenis_kendaraan, plat_nomor, kapasitas_berat) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
                $stmt_detail = mysqli_prepare($koneksi, $insert_detail);
                if ($stmt_detail) {
                    mysqli_stmt_bind_param($stmt_detail, "isssssssd", $new_id, $kecamatan, $kab_kota, $wilayah, $kode_pos, $tipe_kendaraan, $jenis_kendaraan, $plat_nomor, $kapasitas_berat);
                    mysqli_stmt_execute($stmt_detail);
                    mysqli_stmt_close($stmt_detail);
                }
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
        $query = "SELECT id_pengguna, nama_lengkap, username, level, alamat, no_telepon, email, google_uid, saldo, foto_profil, tanggal_daftar, status
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

            $insert = "INSERT INTO pengguna (nama_lengkap, username, password, level, alamat, no_telepon, email, google_uid, foto_profil, saldo, api_token, status)
                       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 0.00, ?, 'aktif')";
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

    else {
        api_respond(false, 'Action tidak valid. Gunakan: login atau register', null, 400);
    }
} catch (Throwable $e) {
    api_respond(false, 'Error Database/Sistem: ' . $e->getMessage(), null, 500);
}
?>
