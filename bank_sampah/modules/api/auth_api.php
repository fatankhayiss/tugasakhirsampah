<?php
// modules/api/auth_api.php
// Endpoint: Login & Register untuk Mobile (warga) dan Driver
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

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    api_respond(false, 'Method not allowed', null, 405);
}

$action = isset($_POST['action']) ? $_POST['action'] : (isset($_GET['action']) ? $_GET['action'] : 'login');

// =====================
// LOGIN
// =====================
if ($action === 'login') {
    $username = isset($_POST['username']) ? trim($_POST['username']) : '';
    $password = isset($_POST['password']) ? $_POST['password'] : '';

    if (empty($username) || empty($password)) {
        api_respond(false, 'Username/no telepon dan password wajib diisi', null, 400);
    }

    // Cari user berdasarkan username, email, ATAU no_telepon
    $query = "SELECT id_pengguna, nama_lengkap, username, password, level, alamat, no_telepon, email, saldo, foto_profil, tanggal_daftar
              FROM pengguna
              WHERE username = ? OR email = ? OR no_telepon = ?
              LIMIT 1";
    $stmt = mysqli_prepare($koneksi, $query);
    mysqli_stmt_bind_param($stmt, "sss", $username, $username, $username);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);

    if ($user = mysqli_fetch_assoc($result)) {
        if (password_verify($password, $user['password'])) {
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
            api_respond(false, 'Password salah', null, 401);
        }
    } else {
        api_respond(false, 'Username atau nomor telepon tidak ditemukan', null, 401);
    }
    mysqli_stmt_close($stmt);
}

// =====================
// REGISTER (untuk warga baru)
// =====================
elseif ($action === 'register') {
    $nama = isset($_POST['nama_lengkap']) ? trim($_POST['nama_lengkap']) : '';
    $email = isset($_POST['email']) ? trim($_POST['email']) : '';
    $password = isset($_POST['password']) ? $_POST['password'] : '';
    $no_telepon = isset($_POST['no_telepon']) ? trim($_POST['no_telepon']) : '';
    $alamat = isset($_POST['alamat']) ? trim($_POST['alamat']) : '';
    $req_username = isset($_POST['username']) ? trim($_POST['username']) : '';

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

    // Cek apakah username sudah ada
    $check = "SELECT id_pengguna FROM pengguna WHERE username = ? OR (no_telepon = ? AND no_telepon IS NOT NULL AND no_telepon != '')";
    $stmt_check = mysqli_prepare($koneksi, $check);
    $check_val = !empty($no_telepon) ? $no_telepon : $username;
    mysqli_stmt_bind_param($stmt_check, "ss", $username, $check_val);
    mysqli_stmt_execute($stmt_check);
    $check_result = mysqli_stmt_get_result($stmt_check);

    if (mysqli_num_rows($check_result) > 0) {
        api_respond(false, 'Username atau nomor telepon sudah terdaftar', null, 409);
    }
    mysqli_stmt_close($stmt_check);

    $hashed_password = password_hash($password, PASSWORD_DEFAULT);
    $token = bin2hex(random_bytes(32));

    $requested_level = (isset($_POST['level']) && $_POST['level'] === 'driver') ? 'driver' : 'warga';

    $insert = "INSERT INTO pengguna (nama_lengkap, username, password, level, alamat, no_telepon, email, saldo, api_token)
               VALUES (?, ?, ?, ?, ?, ?, ?, 0.00, ?)";
    $stmt_insert = mysqli_prepare($koneksi, $insert);
    mysqli_stmt_bind_param($stmt_insert, "ssssssss", $nama, $username, $hashed_password, $requested_level, $alamat, $no_telepon, $email, $token);

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
            'saldo' => 0.0,
            'total_waste_kg' => 0.0,
            'foto_profil' => null,
            'token' => $token,
        ];
        api_respond(true, 'Registrasi berhasil', $user_data, 201);
    } else {
        api_respond(false, 'Gagal mendaftarkan pengguna: ' . mysqli_error($koneksi), null, 500);
    }
    mysqli_stmt_close($stmt_insert);
}

else {
    api_respond(false, 'Action tidak valid. Gunakan: login atau register', null, 400);
}
?>
