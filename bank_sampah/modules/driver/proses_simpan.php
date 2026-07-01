<?php
// modules/driver/proses_simpan.php
check_user_level(['admin']); 

if ($_SERVER['REQUEST_METHOD'] == 'POST') {

    // Proses Tambah Driver Baru
    if (isset($_POST['simpan_driver'])) {
        $nama_lengkap = sanitize_input($_POST['nama_lengkap']);
        $no_telepon = sanitize_input($_POST['no_telepon']);
        $alamat = isset($_POST['alamat']) ? sanitize_input($_POST['alamat']) : ''; 
        $password = sanitize_input($_POST['password']);
        
        $tipe_kendaraan = sanitize_input($_POST['tipe_kendaraan']);
        $jenis_kendaraan = sanitize_input($_POST['jenis_kendaraan']);
        $plat_nomor = sanitize_input($_POST['plat_nomor']);
        $kapasitas_berat = isset($_POST['kapasitas_berat']) ? floatval($_POST['kapasitas_berat']) : 0;
        
        $wilayah = isset($_POST['wilayah']) ? sanitize_input($_POST['wilayah']) : '';
        $kecamatan = isset($_POST['kecamatan']) ? sanitize_input($_POST['kecamatan']) : '';
        $kab_kota = isset($_POST['kab_kota']) ? sanitize_input($_POST['kab_kota']) : '';
        $kode_pos = isset($_POST['kode_pos']) ? sanitize_input($_POST['kode_pos']) : '';

        $level = 'driver'; 

        if (empty($nama_lengkap) || empty($no_telepon) || empty($password) || empty($tipe_kendaraan) || empty($jenis_kendaraan) || empty($plat_nomor)) {
            $_SESSION['error_message'] = "Semua field yang bertanda bintang (*) wajib diisi.";
            redirect(BASE_URL . 'index.php?page=driver/tambah');
        }

        // Gunakan nomor telepon (setelah dibersihkan) sebagai username
        $username = preg_replace('/[^0-9]/', '', $no_telepon); 
        if (empty($username)) {
            $_SESSION['error_message'] = "Format nomor telepon tidak valid untuk dijadikan username (harus mengandung angka).";
            redirect(BASE_URL . 'index.php?page=driver/tambah');
        }
        
        $hashed_password = password_hash($password, PASSWORD_DEFAULT);
        $saldo_awal = 0.00;

        // Cek keunikan username (dari no_telepon)
        $query_cek_username = "SELECT id_pengguna FROM pengguna WHERE username = ?";
        $stmt_cek_username = mysqli_prepare($koneksi, $query_cek_username);
        mysqli_stmt_bind_param($stmt_cek_username, "s", $username);
        mysqli_stmt_execute($stmt_cek_username);
        mysqli_stmt_store_result($stmt_cek_username);

        if (mysqli_stmt_num_rows($stmt_cek_username) > 0) {
            $_SESSION['error_message'] = "Nomor telepon '{$no_telepon}' (yang menjadi username '{$username}') sudah terdaftar. Gunakan nomor lain.";
            mysqli_stmt_close($stmt_cek_username);
            redirect(BASE_URL . 'index.php?page=driver/tambah');
        }
        mysqli_stmt_close($stmt_cek_username);

        // Mulai transaksi
        mysqli_begin_transaction($koneksi);

        try {
            $query_insert_pengguna = "INSERT INTO pengguna (nama_lengkap, username, password, level, alamat, no_telepon, saldo) 
                             VALUES (?, ?, ?, ?, ?, ?, ?)";
            $stmt_insert = mysqli_prepare($koneksi, $query_insert_pengguna);
            mysqli_stmt_bind_param($stmt_insert, "ssssssd", $nama_lengkap, $username, $hashed_password, $level, $alamat, $no_telepon, $saldo_awal);
            mysqli_stmt_execute($stmt_insert);
            $id_pengguna_baru = mysqli_insert_id($koneksi);
            mysqli_stmt_close($stmt_insert);

            // Insert ke detail_driver
            $query_insert_detail = "INSERT INTO detail_driver (id_pengguna, tipe_kendaraan, jenis_kendaraan, plat_nomor, kapasitas_berat, wilayah, kecamatan, kab_kota, kode_pos) 
                                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
            $stmt_detail = mysqli_prepare($koneksi, $query_insert_detail);
            mysqli_stmt_bind_param($stmt_detail, "isssdssss", $id_pengguna_baru, $tipe_kendaraan, $jenis_kendaraan, $plat_nomor, $kapasitas_berat, $wilayah, $kecamatan, $kab_kota, $kode_pos);
            mysqli_stmt_execute($stmt_detail);
            mysqli_stmt_close($stmt_detail);

            mysqli_commit($koneksi);
            $_SESSION['success_message'] = "Data driver baru berhasil ditambahkan. Username login: {$username}.";
        } catch (Exception $e) {
            mysqli_rollback($koneksi);
            $_SESSION['error_message'] = "Gagal menambahkan data driver: " . $e->getMessage();
            error_log("Error insert driver: " . $e->getMessage());
        }

        redirect(BASE_URL . 'index.php?page=driver/data');

    // Proses Update Data Driver
    } elseif (isset($_POST['update_driver'])) {
        if (!isset($_POST['id_pengguna']) || empty($_POST['id_pengguna'])) {
            $_SESSION['error_message'] = "ID Driver tidak valid untuk update.";
            redirect(BASE_URL . 'index.php?page=driver/data');
        }
        $id_pengguna = sanitize_input($_POST['id_pengguna']);
        
        $nama_lengkap = sanitize_input($_POST['nama_lengkap']);
        $no_telepon_baru = sanitize_input($_POST['no_telepon']);
        $alamat_baru = isset($_POST['alamat']) ? sanitize_input($_POST['alamat']) : '';
        
        $tipe_kendaraan = sanitize_input($_POST['tipe_kendaraan']);
        $jenis_kendaraan = sanitize_input($_POST['jenis_kendaraan']);
        $plat_nomor = sanitize_input($_POST['plat_nomor']);
        $kapasitas_berat = isset($_POST['kapasitas_berat']) ? floatval($_POST['kapasitas_berat']) : 0;
        
        $wilayah = isset($_POST['wilayah']) ? sanitize_input($_POST['wilayah']) : '';
        $kecamatan = isset($_POST['kecamatan']) ? sanitize_input($_POST['kecamatan']) : '';
        $kab_kota = isset($_POST['kab_kota']) ? sanitize_input($_POST['kab_kota']) : '';
        $kode_pos = isset($_POST['kode_pos']) ? sanitize_input($_POST['kode_pos']) : '';

        if (empty($nama_lengkap) || empty($no_telepon_baru) || empty($tipe_kendaraan) || empty($jenis_kendaraan) || empty($plat_nomor)) {
            $_SESSION['error_message'] = "Field bertanda bintang wajib diisi.";
            redirect(BASE_URL . 'index.php?page=driver/edit&id=' . $id_pengguna);
        }

        // Username baru akan berasal dari no_telepon_baru
        $username_baru = preg_replace('/[^0-9]/', '', $no_telepon_baru);
        if (empty($username_baru)) {
            $_SESSION['error_message'] = "Format nomor telepon baru tidak valid untuk dijadikan username.";
            redirect(BASE_URL . 'index.php?page=driver/edit&id=' . $id_pengguna);
        }

        // Cek apakah username baru (dari no_telepon baru) sudah digunakan oleh PENGGUNA LAIN
        $query_cek_username_update = "SELECT id_pengguna FROM pengguna WHERE username = ? AND id_pengguna != ?";
        $stmt_cek_username_upd = mysqli_prepare($koneksi, $query_cek_username_update);
        mysqli_stmt_bind_param($stmt_cek_username_upd, "si", $username_baru, $id_pengguna);
        mysqli_stmt_execute($stmt_cek_username_upd);
        mysqli_stmt_store_result($stmt_cek_username_upd);

        if (mysqli_stmt_num_rows($stmt_cek_username_upd) > 0) {
            $_SESSION['error_message'] = "Nomor telepon baru '{$no_telepon_baru}' (yang menjadi username '{$username_baru}') sudah digunakan oleh pengguna lain.";
            mysqli_stmt_close($stmt_cek_username_upd);
            redirect(BASE_URL . 'index.php?page=driver/edit&id=' . $id_pengguna);
        }
        mysqli_stmt_close($stmt_cek_username_upd);

        $password_baru = isset($_POST['password']) ? trim($_POST['password']) : '';

        // Mulai transaksi
        mysqli_begin_transaction($koneksi);

        try {
            if (!empty($password_baru)) {
                // Update beserta password
                $hashed_password = password_hash($password_baru, PASSWORD_DEFAULT);
                $query_update = "UPDATE pengguna SET nama_lengkap = ?, username = ?, no_telepon = ?, alamat = ?, password = ? WHERE id_pengguna = ? AND level = 'driver'";
                $stmt_update = mysqli_prepare($koneksi, $query_update);
                mysqli_stmt_bind_param($stmt_update, "sssssi", $nama_lengkap, $username_baru, $no_telepon_baru, $alamat_baru, $hashed_password, $id_pengguna);
            } else {
                // Update tanpa password
                $query_update = "UPDATE pengguna SET nama_lengkap = ?, username = ?, no_telepon = ?, alamat = ? WHERE id_pengguna = ? AND level = 'driver'";
                $stmt_update = mysqli_prepare($koneksi, $query_update);
                mysqli_stmt_bind_param($stmt_update, "ssssi", $nama_lengkap, $username_baru, $no_telepon_baru, $alamat_baru, $id_pengguna);
            }
            mysqli_stmt_execute($stmt_update);
            mysqli_stmt_close($stmt_update);

            // Update detail_driver (Cek apakah data detail_driver untuk id_pengguna ini sudah ada atau belum, karena bisa jadi driver lama yang belum ada detailnya)
            $query_cek_detail = "SELECT id_detail FROM detail_driver WHERE id_pengguna = ?";
            $stmt_cek = mysqli_prepare($koneksi, $query_cek_detail);
            mysqli_stmt_bind_param($stmt_cek, "i", $id_pengguna);
            mysqli_stmt_execute($stmt_cek);
            mysqli_stmt_store_result($stmt_cek);
            $has_detail = mysqli_stmt_num_rows($stmt_cek) > 0;
            mysqli_stmt_close($stmt_cek);

            if ($has_detail) {
                // Update
                $query_update_detail = "UPDATE detail_driver SET tipe_kendaraan=?, jenis_kendaraan=?, plat_nomor=?, kapasitas_berat=?, wilayah=?, kecamatan=?, kab_kota=?, kode_pos=? WHERE id_pengguna=?";
                $stmt_det = mysqli_prepare($koneksi, $query_update_detail);
                mysqli_stmt_bind_param($stmt_det, "sssdssssi", $tipe_kendaraan, $jenis_kendaraan, $plat_nomor, $kapasitas_berat, $wilayah, $kecamatan, $kab_kota, $kode_pos, $id_pengguna);
                mysqli_stmt_execute($stmt_det);
                mysqli_stmt_close($stmt_det);
            } else {
                // Insert
                $query_insert_detail = "INSERT INTO detail_driver (id_pengguna, tipe_kendaraan, jenis_kendaraan, plat_nomor, kapasitas_berat, wilayah, kecamatan, kab_kota, kode_pos) 
                                        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
                $stmt_det = mysqli_prepare($koneksi, $query_insert_detail);
                mysqli_stmt_bind_param($stmt_det, "isssdssss", $id_pengguna, $tipe_kendaraan, $jenis_kendaraan, $plat_nomor, $kapasitas_berat, $wilayah, $kecamatan, $kab_kota, $kode_pos);
                mysqli_stmt_execute($stmt_det);
                mysqli_stmt_close($stmt_det);
            }

            mysqli_commit($koneksi);
            $_SESSION['success_message'] = "Data driver berhasil diperbarui.";
        } catch (Exception $e) {
            mysqli_rollback($koneksi);
            $_SESSION['error_message'] = "Gagal memperbarui data driver: " . $e->getMessage();
            error_log("Error update driver (ID: $id_pengguna): " . $e->getMessage());
        }

        redirect(BASE_URL . 'index.php?page=driver/data');

    } else {
        $_SESSION['error_message'] = "Aksi tidak valid.";
        redirect(BASE_URL . 'index.php?page=driver/data');
    }

} else {
    $_SESSION['error_message'] = "Metode request tidak diizinkan.";
    redirect(BASE_URL . 'index.php?page=driver/data');
}
?>
