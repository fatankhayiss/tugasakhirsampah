<?php
// modules/edukasi/hapus.php
check_user_level(['admin']);

$id = isset($_GET['id']) ? (int)$_GET['id'] : 0;
if ($id <= 0) { $_SESSION['error_message'] = 'ID tidak valid.'; redirect(BASE_URL . 'index.php?page=edukasi/data'); }

// fetch for cleanup
$res = mysqli_query($koneksi, "SELECT gambar, video_path FROM edukasi WHERE id_edukasi = $id");
$row = $res ? mysqli_fetch_assoc($res) : null;

$ok = mysqli_query($koneksi, "DELETE FROM edukasi WHERE id_edukasi = $id");
if ($ok) {
    if ($row) {
        if (!empty($row['gambar'])) { $p = __DIR__ . '/../../' . $row['gambar']; if (strpos($p, realpath(__DIR__ . '/../../assets/uploads/edukasi/')) !== false && file_exists($p)) {@unlink($p);} }
        if (!empty($row['video_path'])) { $p = __DIR__ . '/../../' . $row['video_path']; if (strpos($p, realpath(__DIR__ . '/../../assets/uploads/edukasi/')) !== false && file_exists($p)) {@unlink($p);} }
    }
    $_SESSION['success_message'] = 'Konten edukasi dihapus.';
} else {
    $_SESSION['error_message'] = 'Gagal menghapus konten: ' . mysqli_error($koneksi);
}
redirect(BASE_URL . 'index.php?page=edukasi/data');
