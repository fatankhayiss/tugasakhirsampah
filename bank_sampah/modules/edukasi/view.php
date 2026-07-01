<?php
require_once __DIR__ . '/../../config/database.php';

if (!is_logged_in()) {
    http_response_code(403);
    echo '<div class="p-4">Akses ditolak.</div>';
    exit;
}

$id = (int)($_GET['id'] ?? 0);
if ($id <= 0) {
    http_response_code(400);
    echo '<div class="p-4">ID tidak valid.</div>';
    exit;
}

$sql = "
    SELECT e.*, p.nama_lengkap AS author_name
    FROM edukasi e
    LEFT JOIN pengguna p ON p.id_pengguna = e.author_id
    WHERE e.id_edukasi = $id
    LIMIT 1
";

$res = mysqli_query($koneksi, $sql);
if (!$res || mysqli_num_rows($res) === 0) {
    http_response_code(404);
    echo '<div class="p-4">Konten tidak ditemukan.</div>';
    exit;
}

$row = mysqli_fetch_assoc($res);

// gambar
$img = $row['gambar'];
if ($img && !preg_match('#^(https?://|/)#i', $img)) {
    $img = rtrim(BASE_URL, '/') . '/' . ltrim($img, '/');
}

// video
$video_url  = $row['video_url'];
$video_path = $row['video_path'];
if ($video_path && !preg_match('#^(https?://|/)#i', $video_path)) {
    $video_path = rtrim(BASE_URL, '/') . '/' . ltrim($video_path, '/');
}
?>

<div class="space-y-3">
    <h2 class="text-xl font-bold">
        <?= htmlspecialchars($row['judul'], ENT_QUOTES, 'UTF-8'); ?>
    </h2>

    <p class="text-sm text-gray-600">
        <?= htmlspecialchars($row['author_name'] ?? '-', ENT_QUOTES, 'UTF-8'); ?>
        • <?= format_tanggal_indonesia($row['created_at'], true); ?>
    </p>

    <?php if ($img): ?>
        <img src="<?= htmlspecialchars($img, ENT_QUOTES, 'UTF-8'); ?>"
             class="w-full max-h-[50vh] object-cover rounded"
             alt="gambar">
    <?php endif; ?>

    <div class="prose max-w-none">
        <?= nl2br(htmlspecialchars($row['konten'], ENT_QUOTES, 'UTF-8')); ?>
    </div>

    <?php if ($video_url): ?>
        <div class="mt-3">
            <?php
            $embed = '';
            if (strpos($video_url, 'youtube.com') !== false || strpos($video_url, 'youtu.be') !== false) {
                $vidId = '';
                if (strpos($video_url, 'v=') !== false) {
                    $vidId = explode('&', explode('v=', $video_url)[1])[0];
                } elseif (strpos($video_url, 'youtu.be/') !== false) {
                    $vidId = explode('?', explode('youtu.be/', $video_url)[1])[0];
                }
                if ($vidId) {
                    $embed = '<iframe width="100%" height="360"
                              src="https://www.youtube.com/embed/' . htmlspecialchars($vidId, ENT_QUOTES, 'UTF-8') . '"
                              frameborder="0" allowfullscreen></iframe>';
                }
            }

            echo $embed
                ? $embed
                : '<a class="text-sky-600 hover:underline" target="_blank"
                     href="' . htmlspecialchars($video_url, ENT_QUOTES, 'UTF-8') . '">Tonton Video</a>';
            ?>
        </div>
    <?php elseif ($video_path): ?>
        <video class="w-full mt-3" controls
               src="<?= htmlspecialchars($video_path, ENT_QUOTES, 'UTF-8'); ?>"></video>
    <?php endif; ?>
</div>
