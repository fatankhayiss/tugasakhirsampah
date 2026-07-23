<?php
require_once __DIR__ . '/../../config/database.php';

header('Content-Type: application/json');

function respond($success, $message = '', $data = null, $code = 200) {
    http_response_code($code);
    echo json_encode([
        'success' => $success,
        'message' => $message,
        'data'    => $data
    ]);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    respond(false, 'Metode tidak diizinkan. Gunakan POST.', null, 405);
}

$id = isset($_POST['id_deteksi']) ? intval($_POST['id_deteksi']) : 0;
$kategori = isset($_POST['kategori_sampah']) ? trim($_POST['kategori_sampah']) : '';
$berat = isset($_POST['berat']) ? floatval($_POST['berat']) : 1.0;

if ($id <= 0 || empty($kategori)) {
    respond(false, 'ID deteksi atau kategori sampah tidak valid.', null, 400);
}

if ($berat <= 0) $berat = 1.0;

$koneksi = mysqli_connect(DB_HOST, DB_USER, DB_PASS, DB_NAME, DB_PORT);
if (!$koneksi) {
    respond(false, 'Koneksi database gagal.', null, 500);
}

$kat_esc = mysqli_real_escape_string($koneksi, $kategori);

// Retrieve harga_per_kg for this category
$harga = 250.0; // default
$sql_harga = "SELECT harga_per_kg FROM jenis_sampah 
              WHERE nama_sampah = '$kat_esc' OR kategori = '$kat_esc'
              LIMIT 1";
$res_harga = mysqli_query($koneksi, $sql_harga);
if ($res_harga && mysqli_num_rows($res_harga) > 0) {
    $row_harga = mysqli_fetch_assoc($res_harga);
    if ($row_harga['harga_per_kg'] !== null) {
        $harga = (float)$row_harga['harga_per_kg'];
    }
}

$estimasi = $berat * $harga;

$sql = "UPDATE deteksi 
        SET kategori_sampah = '$kat_esc', 
            berat = $berat, 
            estimasi_poin = $estimasi 
        WHERE id_deteksi = $id";

if (mysqli_query($koneksi, $sql)) {
    if (mysqli_affected_rows($koneksi) > 0 || mysqli_errno($koneksi) === 0) {
        respond(true, 'Data deteksi berhasil diperbarui', [
            'id_deteksi'      => $id,
            'kategori_sampah' => $kategori,
            'berat'           => $berat,
            'estimasi_poin'   => $estimasi
        ]);
    } else {
        respond(false, 'Gagal memperbarui data atau ID tidak ditemukan.', null, 404);
    }
} else {
    respond(false, 'Gagal menyimpan perubahan.', null, 500);
}
