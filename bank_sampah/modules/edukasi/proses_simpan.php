<?php
check_user_level(['admin']);

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    $_SESSION['error_message'] = 'Metode request tidak diizinkan.';
    redirect(BASE_URL . 'index.php?page=edukasi/data');
    exit;
}

/* =======================
   HELPER
======================= */
function ensure_dir($path) {
    if (!is_dir($path)) {
        mkdir($path, 0755, true);
    }
}
function is_allowed_image($mime) {
    return in_array($mime, ['image/jpeg','image/png','image/webp']);
}
function is_allowed_video($mime) {
    return in_array($mime, ['video/mp4','video/webm','video/ogg']);
}

/* =======================
   INPUT DASAR
======================= */
$judul = sanitize_input($_POST['judul'] ?? '');
$konten_raw = $_POST['konten'] ?? '';

// konten dari file teks
if (empty($konten_raw) && isset($_FILES['konten_file']) && $_FILES['konten_file']['error'] === UPLOAD_ERR_OK) {
    if ($_FILES['konten_file']['size'] > 1024 * 1024) {
        $_SESSION['error_message'] = 'Ukuran file teks maksimal 1MB.';
        redirect(BASE_URL . 'index.php?page=edukasi/data');
        exit;
    }
    $konten_raw = file_get_contents($_FILES['konten_file']['tmp_name']);
}

$konten = str_replace(["\r\n", "\r"], "\n", $konten_raw);
$video_url = trim($_POST['video_url'] ?? '');
$author_id = (int)($_SESSION['user_id'] ?? 0);

if (empty($judul) || empty(trim($konten))) {
    $_SESSION['error_message'] = 'Judul dan Konten wajib diisi.';
    redirect(BASE_URL . 'index.php?page=edukasi/data');
    exit;
}

/* =======================
   UPLOAD DIR
======================= */
$uploadBase = __DIR__ . '/../../assets/uploads/edukasi/';
ensure_dir($uploadBase);

/* =======================
   UPLOAD GAMBAR
======================= */
$gambar_rel = null;
if (!empty($_FILES['gambar']['name']) && $_FILES['gambar']['error'] === UPLOAD_ERR_OK) {
    $mime = mime_content_type($_FILES['gambar']['tmp_name']);
    if (!is_allowed_image($mime)) {
        $_SESSION['error_message'] = 'Tipe gambar tidak didukung.';
        redirect(BASE_URL . 'index.php?page=edukasi/data');
        exit;
    }

    if ($_FILES['gambar']['size'] > 5 * 1024 * 1024) {
        $_SESSION['error_message'] = 'Ukuran gambar maksimal 5MB.';
        redirect(BASE_URL . 'index.php?page=edukasi/data');
        exit;
    }

    $ext = pathinfo($_FILES['gambar']['name'], PATHINFO_EXTENSION);
    $fname = 'img_' . time() . '_' . bin2hex(random_bytes(5)) . '.' . $ext;
    move_uploaded_file($_FILES['gambar']['tmp_name'], $uploadBase . $fname);
    $gambar_rel = 'assets/uploads/edukasi/' . $fname;
}

/* =======================
   UPLOAD VIDEO
======================= */
$video_path_rel = null;
if (!empty($_FILES['video_file']['name']) && $_FILES['video_file']['error'] === UPLOAD_ERR_OK) {
    $mime = mime_content_type($_FILES['video_file']['tmp_name']);
    if (!is_allowed_video($mime)) {
        $_SESSION['error_message'] = 'Tipe video tidak didukung.';
        redirect(BASE_URL . 'index.php?page=edukasi/data');
        exit;
    }

    if ($_FILES['video_file']['size'] > 50 * 1024 * 1024) {
        $_SESSION['error_message'] = 'Ukuran video maksimal 50MB.';
        redirect(BASE_URL . 'index.php?page=edukasi/data');
        exit;
    }

    $ext = pathinfo($_FILES['video_file']['name'], PATHINFO_EXTENSION);
    $fname = 'vid_' . time() . '_' . bin2hex(random_bytes(5)) . '.' . $ext;
    move_uploaded_file($_FILES['video_file']['tmp_name'], $uploadBase . $fname);
    $video_path_rel = 'assets/uploads/edukasi/' . $fname;
    $video_url = '';
}

/* =======================
   SIMPAN / UPDATE
======================= */
if (isset($_POST['simpan_edukasi'])) {

    // INSERT
    $sql = "INSERT INTO edukasi 
            (judul, konten, gambar, video_url, video_path, author_id)
            VALUES (?, ?, ?, ?, ?, ?)";

    $stmt = mysqli_prepare($koneksi, $sql);
    mysqli_stmt_bind_param($stmt, 'sssssi',
        $judul, $konten, $gambar_rel, $video_url, $video_path_rel, $author_id
    );

    mysqli_stmt_execute($stmt);
    mysqli_stmt_close($stmt);

    $_SESSION['success_message'] = 'Konten edukasi berhasil ditambahkan.';
    redirect(BASE_URL . 'index.php?page=edukasi/data');
    exit;

} elseif (isset($_POST['update_edukasi'])) {

    // UPDATE
    $id = (int)($_POST['id_edukasi'] ?? 0);
    if ($id <= 0) {
        $_SESSION['error_message'] = 'ID tidak valid.';
        redirect(BASE_URL . 'index.php?page=edukasi/data');
        exit;
    }

    $sql = "UPDATE edukasi 
            SET judul = ?, konten = ?, video_url = ?, updated_at = NOW()";

    $params = [$judul, $konten, $video_url];
    $types  = 'sss';

    if ($gambar_rel !== null) {
        $sql .= ", gambar = ?";
        $types .= 's';
        $params[] = $gambar_rel;
    }

    if ($video_path_rel !== null) {
        $sql .= ", video_path = ?";
        $types .= 's';
        $params[] = $video_path_rel;
    }

    $sql .= " WHERE id_edukasi = ?";
    $types .= 'i';
    $params[] = $id;

    $stmt = mysqli_prepare($koneksi, $sql);
    mysqli_stmt_bind_param($stmt, $types, ...$params);
    mysqli_stmt_execute($stmt);
    mysqli_stmt_close($stmt);

    $_SESSION['success_message'] = 'Konten edukasi berhasil diperbarui.';
    redirect(BASE_URL . 'index.php?page=edukasi/data');
    exit;
}

/* =======================
   FALLBACK
======================= */
$_SESSION['error_message'] = 'Aksi tidak valid.';
redirect(BASE_URL . 'index.php?page=edukasi/data');
exit;
