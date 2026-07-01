<?php
// modules/driver/hapus.php
check_user_level(['admin']);

if (isset($_GET['id']) && !empty($_GET['id'])) {
    $id_pengguna = sanitize_input($_GET['id']);

    // Mulai transaksi untuk memastikan konsistensi data
    mysqli_begin_transaction($koneksi);

    try {
        // Hapus dari detail_driver terlebih dahulu (jika tidak ada ON DELETE CASCADE, ini wajib)
        $query_delete_detail = "DELETE FROM detail_driver WHERE id_pengguna = ?";
        $stmt_detail = mysqli_prepare($koneksi, $query_delete_detail);
        mysqli_stmt_bind_param($stmt_detail, "i", $id_pengguna);
        mysqli_stmt_execute($stmt_detail);
        mysqli_stmt_close($stmt_detail);

        // Hapus dari pengguna
        $query_delete_pengguna = "DELETE FROM pengguna WHERE id_pengguna = ? AND level = 'driver'";
        $stmt_pengguna = mysqli_prepare($koneksi, $query_delete_pengguna);
        mysqli_stmt_bind_param($stmt_pengguna, "i", $id_pengguna);
        mysqli_stmt_execute($stmt_pengguna);
        
        // Cek apakah ada baris yang terhapus (memastikan yang dihapus adalah driver dan ada di database)
        if (mysqli_stmt_affected_rows($stmt_pengguna) > 0) {
            mysqli_commit($koneksi);
            $_SESSION['success_message'] = "Data driver berhasil dihapus.";
        } else {
            mysqli_rollback($koneksi);
            $_SESSION['error_message'] = "Data driver tidak ditemukan atau tidak bisa dihapus.";
        }
        mysqli_stmt_close($stmt_pengguna);

    } catch (Exception $e) {
        mysqli_rollback($koneksi);
        $_SESSION['error_message'] = "Terjadi kesalahan saat menghapus data: " . $e->getMessage();
        error_log("Error delete driver (ID: $id_pengguna): " . $e->getMessage());
    }

} else {
    $_SESSION['error_message'] = "ID Driver tidak valid.";
}

redirect(BASE_URL . 'index.php?page=driver/data');
?>
