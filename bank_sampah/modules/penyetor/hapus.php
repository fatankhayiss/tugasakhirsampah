<?php
// modules/penyetor/hapus.php
check_user_level(['admin']); // Hanya admin

if (!isset($_GET['id']) || empty($_GET['id'])) {
    $_SESSION['error_message'] = "ID Penyetor tidak valid untuk dihapus.";
    redirect(BASE_URL . 'index.php?page=penyetor/data');
}

$id_penyetor = sanitize_input($_GET['id']);

$query_delete = "DELETE FROM pengguna WHERE id_pengguna = ? AND level = 'warga'";
$stmt = mysqli_prepare($koneksi, $query_delete);
mysqli_stmt_bind_param($stmt, "i", $id_penyetor);

if (mysqli_stmt_execute($stmt)) {
    if (mysqli_stmt_affected_rows($stmt) > 0) {
        $_SESSION['success_message'] = "Data Penyetor berhasil dihapus.";
    } else {
        $_SESSION['error_message'] = "Data Penyetor tidak ditemukan atau sudah terhapus.";
    }
} else {
    $_SESSION['error_message'] = "Gagal menghapus data Penyetor: " . mysqli_error($koneksi);
    error_log("Error delete penyetor (ID: $id_penyetor): " . mysqli_error($koneksi));
}
mysqli_stmt_close($stmt);

redirect(BASE_URL . 'index.php?page=penyetor/data');
?>
