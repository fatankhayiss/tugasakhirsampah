<?php
// modules/penyetor/proses_simpan.php
check_user_level(['admin']); 

// Handle toggle status via GET
if (isset($_GET['action']) && $_GET['action'] === 'toggle_status') {
    $id = (int)$_GET['id'];
    $res = mysqli_query($koneksi, "SELECT status FROM pengguna WHERE id_pengguna = $id AND level = 'warga'");
    if ($row = mysqli_fetch_assoc($res)) {
        $new_status = ($row['status'] === 'aktif') ? 'nonaktif' : 'aktif';
        mysqli_query($koneksi, "UPDATE pengguna SET status = '$new_status' WHERE id_pengguna = $id");
        $_SESSION['success_message'] = "Status akun Penyetor berhasil diubah menjadi " . ($new_status === 'aktif' ? 'Aktif' : 'Nonaktif') . ".";
    } else {
        $_SESSION['error_message'] = "Penyetor tidak ditemukan.";
    }
    redirect(BASE_URL . 'index.php?page=penyetor/data');
}

if ($_SERVER['REQUEST_METHOD'] == 'POST') {

    // ==========================================
    // PROSES TAMBAH PENYETOR BARU
    // ==========================================
    if (isset($_POST['simpan_penyetor'])) {
        $username = trim(sanitize_input($_POST['username']));
        $nama_lengkap = trim(sanitize_input($_POST['nama_lengkap']));
        $email = trim(sanitize_input($_POST['email']));
        $no_telepon = trim(sanitize_input($_POST['no_telepon']));
        $alamat = isset($_POST['alamat']) ? trim(sanitize_input($_POST['alamat'])) : ''; 
        $password = sanitize_input($_POST['password']);
        
        $level = 'warga'; // Role Penyetor tetap 'warga' di DB
        $status = 'aktif';

        if (empty($username) || empty($nama_lengkap) || empty($email) || empty($no_telepon) || empty($password)) {
            $_SESSION['error_message'] = "Semua field bertanda bintang (*) wajib diisi.";
            redirect(BASE_URL . 'index.php?page=penyetor/tambah');
        }

        // 1. Cek keunikan username secara independen
        $stmt_u = mysqli_prepare($koneksi, "SELECT id_pengguna FROM pengguna WHERE username = ?");
        mysqli_stmt_bind_param($stmt_u, "s", $username);
        mysqli_stmt_execute($stmt_u);
        mysqli_stmt_store_result($stmt_u);
        if (mysqli_stmt_num_rows($stmt_u) > 0) {
            $_SESSION['error_message'] = "Username sudah digunakan. Silakan gunakan username lain.";
            mysqli_stmt_close($stmt_u);
            redirect(BASE_URL . 'index.php?page=penyetor/tambah');
        }
        mysqli_stmt_close($stmt_u);

        // 2. Cek keunikan email secara independen
        $stmt_e = mysqli_prepare($koneksi, "SELECT id_pengguna FROM pengguna WHERE email = ?");
        mysqli_stmt_bind_param($stmt_e, "s", $email);
        mysqli_stmt_execute($stmt_e);
        mysqli_stmt_store_result($stmt_e);
        if (mysqli_stmt_num_rows($stmt_e) > 0) {
            $_SESSION['error_message'] = "Email sudah digunakan. Silakan gunakan email lain.";
            mysqli_stmt_close($stmt_e);
            redirect(BASE_URL . 'index.php?page=penyetor/tambah');
        }
        mysqli_stmt_close($stmt_e);

        $hashed_password = password_hash($password, PASSWORD_DEFAULT);
        $saldo_awal = 0.00;
        $default_avatar = 'assets/uploads/default_avatar.png'; // Menggunakan foto profil default

        $query_insert = "INSERT INTO pengguna (nama_lengkap, username, password, level, alamat, no_telepon, email, foto_profil, status, saldo) 
                          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        $stmt_insert = mysqli_prepare($koneksi, $query_insert);
        mysqli_stmt_bind_param($stmt_insert, "sssssssssd", $nama_lengkap, $username, $hashed_password, $level, $alamat, $no_telepon, $email, $default_avatar, $status, $saldo_awal);

        if (mysqli_stmt_execute($stmt_insert)) {
            $_SESSION['success_message'] = "Data Penyetor baru berhasil ditambahkan. Username login: {$username}.";
        } else {
            $_SESSION['error_message'] = "Gagal menambahkan data Penyetor: " . mysqli_error($koneksi);
            error_log("Error insert penyetor: " . mysqli_error($koneksi));
        }
        mysqli_stmt_close($stmt_insert);
        redirect(BASE_URL . 'index.php?page=penyetor/data');

    // ==========================================
    // PROSES UPDATE DATA PENYETOR
    // ==========================================
    } elseif (isset($_POST['update_penyetor'])) {
        if (!isset($_POST['id_pengguna']) || empty($_POST['id_pengguna'])) {
            $_SESSION['error_message'] = "ID Penyetor tidak valid untuk update.";
            redirect(BASE_URL . 'index.php?page=penyetor/data');
        }
        $id_pengguna = sanitize_input($_POST['id_pengguna']);
        
        $username = trim(sanitize_input($_POST['username']));
        $nama_lengkap = trim(sanitize_input($_POST['nama_lengkap']));
        $email = trim(sanitize_input($_POST['email']));
        $no_telepon = trim(sanitize_input($_POST['no_telepon']));
        $alamat = isset($_POST['alamat']) ? trim(sanitize_input($_POST['alamat'])) : '';
        $status = sanitize_input($_POST['status']);
        $password_baru = isset($_POST['password']) ? trim($_POST['password']) : '';

        if (empty($username) || empty($nama_lengkap) || empty($email) || empty($no_telepon) || empty($status)) {
            $_SESSION['error_message'] = "Username, Nama Lengkap, Email, No. Telepon, dan Status wajib diisi.";
            redirect(BASE_URL . 'index.php?page=penyetor/edit&id=' . $id_pengguna);
        }

        // 1. Cek keunikan username secara independen
        $stmt_u = mysqli_prepare($koneksi, "SELECT id_pengguna FROM pengguna WHERE username = ? AND id_pengguna != ?");
        mysqli_stmt_bind_param($stmt_u, "si", $username, $id_pengguna);
        mysqli_stmt_execute($stmt_u);
        mysqli_stmt_store_result($stmt_u);
        if (mysqli_stmt_num_rows($stmt_u) > 0) {
            $_SESSION['error_message'] = "Username sudah digunakan. Silakan gunakan username lain.";
            mysqli_stmt_close($stmt_u);
            redirect(BASE_URL . 'index.php?page=penyetor/edit&id=' . $id_pengguna);
        }
        mysqli_stmt_close($stmt_u);

        // 2. Cek keunikan email secara independen
        $stmt_e = mysqli_prepare($koneksi, "SELECT id_pengguna FROM pengguna WHERE email = ? AND id_pengguna != ?");
        mysqli_stmt_bind_param($stmt_e, "si", $email, $id_pengguna);
        mysqli_stmt_execute($stmt_e);
        mysqli_stmt_store_result($stmt_e);
        if (mysqli_stmt_num_rows($stmt_e) > 0) {
            $_SESSION['error_message'] = "Email sudah digunakan. Silakan gunakan email lain.";
            mysqli_stmt_close($stmt_e);
            redirect(BASE_URL . 'index.php?page=penyetor/edit&id=' . $id_pengguna);
        }
        mysqli_stmt_close($stmt_e);

        if (!empty($password_baru)) {
            // Update beserta password
            $hashed_password = password_hash($password_baru, PASSWORD_DEFAULT);
            $query_update = "UPDATE pengguna SET nama_lengkap = ?, username = ?, email = ?, no_telepon = ?, alamat = ?, status = ?, password = ? WHERE id_pengguna = ? AND level = 'warga'";
            $stmt_update = mysqli_prepare($koneksi, $query_update);
            mysqli_stmt_bind_param($stmt_update, "sssssssi", $nama_lengkap, $username, $email, $no_telepon, $alamat, $status, $hashed_password, $id_pengguna);
        } else {
            // Update tanpa password
            $query_update = "UPDATE pengguna SET nama_lengkap = ?, username = ?, email = ?, no_telepon = ?, alamat = ?, status = ? WHERE id_pengguna = ? AND level = 'warga'";
            $stmt_update = mysqli_prepare($koneksi, $query_update);
            mysqli_stmt_bind_param($stmt_update, "ssssssi", $nama_lengkap, $username, $email, $no_telepon, $alamat, $status, $id_pengguna);
        }

        if (mysqli_stmt_execute($stmt_update)) {
            $_SESSION['success_message'] = "Data Penyetor berhasil diperbarui.";
        } else {
            $_SESSION['error_message'] = "Gagal memperbarui data Penyetor: " . mysqli_error($koneksi);
            error_log("Error update penyetor (ID: $id_pengguna): " . mysqli_error($koneksi));
        }
        mysqli_stmt_close($stmt_update);
        redirect(BASE_URL . 'index.php?page=penyetor/data');

    } else {
        $_SESSION['error_message'] = "Aksi tidak valid.";
        redirect(BASE_URL . 'index.php?page=penyetor/data');
    }

} else {
    $_SESSION['error_message'] = "Metode request tidak diizinkan.";
    redirect(BASE_URL . 'index.php?page=penyetor/data');
}
?>
