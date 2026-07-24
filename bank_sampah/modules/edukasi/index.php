<?php
// modules/edukasi/index.php
// List & view edukasi entries. Everyone logged-in can view; only admin/petugas can manage.

// Ensure table exists (for upgraded installs)
$tbl = 'edukasi';
$q = mysqli_query($koneksi, "SELECT COUNT(*) as cnt FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = '" . mysqli_real_escape_string($koneksi, $tbl) . "'");
$exists = false;
if ($q) { $r = mysqli_fetch_assoc($q); $exists = ((int)$r['cnt'] > 0); }
if (!$exists) {
    $sqlFile = __DIR__ . '/create_table_edukasi.sql';
    if (file_exists($sqlFile)) {
        $sql = file_get_contents($sqlFile);
        if ($sql && mysqli_multi_query($koneksi, $sql)) { do {} while (mysqli_more_results($koneksi) && mysqli_next_result($koneksi)); $exists = true; }
    }
}

if (!$exists) {
    echo "<div class='container mx-auto mt-10 p-6 bg-yellow-100 border-l-4 border-yellow-500 text-yellow-700 rounded-lg text-center'>";
    echo "<h1 class='text-2xl font-bold'>Tabel edukasi belum tersedia</h1>";
    echo "<p>Jalankan file SQL: <code>modules/edukasi/create_table_edukasi.sql</code></p>";
    echo "</div>";
    return;
}

$can_manage = isset($_SESSION['user_level']) && in_array($_SESSION['user_level'], ['admin']);

$search = isset($_GET['search']) ? sanitize_input($_GET['search']) : '';
$where = '';
if ($search !== '') {
    $safe = mysqli_real_escape_string($koneksi, $search);
    $where = "WHERE judul LIKE '%$safe%' OR konten LIKE '%$safe%'";
}

$sql = "SELECT e.*, p.nama_lengkap AS author_name FROM edukasi e LEFT JOIN pengguna p ON p.id_pengguna = e.author_id $where ORDER BY e.created_at DESC";
$res = mysqli_query($koneksi, $sql);
?>

<div class="container mx-auto px-4 py-8">
    <div class="flex justify-between items-center mb-6">
        <h1 class="text-3xl font-bold text-gray-800">Edukasi</h1>
        <?php if ($can_manage): ?>
        <div class="flex space-x-3">
            <a href="<?php echo BASE_URL; ?>index.php?page=edukasi/video_tambah" class="bg-sky-500 hover:bg-sky-600 text-white font-semibold py-2 px-4 rounded-lg shadow-md transition">
                <i class="fas fa-video mr-2"></i> Tambah Video
            </a>
            <a href="<?php echo BASE_URL; ?>index.php?page=edukasi/artikel_tambah" class="bg-green-500 hover:bg-green-600 text-white font-semibold py-2 px-4 rounded-lg shadow-md transition">
                <i class="fas fa-file-alt mr-2"></i> Tambah Artikel
            </a>
        </div>
        <?php endif; ?>
    </div>

    <form method="GET" action="<?php echo BASE_URL; ?>index.php" class="mb-6">
        <input type="hidden" name="page" value="edukasi/data">
        <div class="flex">
            <input type="text" name="search" value="<?php echo htmlspecialchars($search); ?>" placeholder="Cari judul atau isi..." class="w-full px-4 py-2 border border-gray-300 rounded-l-lg focus:outline-none focus:ring-2 focus:ring-sky-500 focus:border-sky-500">
            <button type="submit" class="bg-sky-500 hover:bg-sky-600 text-white font-semibold px-4 py-2 rounded-r-lg transition">
                <i class="fas fa-search"></i> Cari
            </button>
        </div>
    </form>

    <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
        <?php if ($res && mysqli_num_rows($res) > 0): ?>
            <?php while($row = mysqli_fetch_assoc($res)): ?>
                <?php
                    $img = $row['gambar'];
                    if ($img && !preg_match('#^(https?://|/)#i', $img)) {
                        $img = rtrim(BASE_URL, '/') . '/' . ltrim($img, '/');
                    }
                    $video_url = $row['video_url'];
                    $video_path = $row['video_path'];
                    if ($video_path && !preg_match('#^(https?://|/)#i', $video_path)) {
                        $video_path = rtrim(BASE_URL, '/') . '/' . ltrim($video_path, '/');
                    }
                ?>
                <div class="bg-white rounded-xl shadow overflow-hidden flex flex-col">
                    <?php if ($img): ?>
                        <img src="<?php echo htmlspecialchars($img); ?>" alt="thumb" class="h-40 w-full object-cover">
                    <?php else: ?>
                        <div class="h-40 w-full bg-gray-100 flex items-center justify-center text-gray-400">Tidak ada gambar</div>
                    <?php endif; ?>
                    <div class="p-4 flex-1 flex flex-col">
                        <h3 class="text-lg font-semibold mb-2"><?php echo htmlspecialchars($row['judul']); ?></h3>
                        <p class="text-sm text-gray-600 mb-2"><?php echo htmlspecialchars($row['author_name'] ?? ''); ?> • <?php echo format_tanggal_indonesia($row['created_at'], true); ?></p>
                        <p class="text-gray-700 text-sm line-clamp-3 mb-3"><?php echo htmlspecialchars(mb_strimwidth(strip_tags($row['konten']), 0, 160, '...')); ?></p>
                        <?php if ($video_url): ?>
                            <a href="<?php echo htmlspecialchars($video_url); ?>" target="_blank" class="text-sky-600 hover:underline text-sm mb-2"><i class="fas fa-video mr-1"></i> Tonton Video (URL)</a>
                        <?php elseif ($video_path): ?>
                            <a href="<?php echo htmlspecialchars($video_path); ?>" target="_blank" class="text-sky-600 hover:underline text-sm mb-2"><i class="fas fa-video mr-1"></i> Tonton Video</a>
                        <?php endif; ?>
                        <div class="mt-auto flex items-center justify-between">
                            <a href="#" class="text-sky-700 hover:underline text-sm" onclick="openEdukasiModal(<?php echo (int)$row['id_edukasi']; ?>)">Baca selengkapnya</a>
                            <?php if ($can_manage): ?>
                            <div class="space-x-3 text-sm">
                                <?php $edit_route = ($video_url || $video_path) ? 'video_edit' : 'artikel_edit'; ?>
                                <a href="<?php echo BASE_URL; ?>index.php?page=edukasi/<?php echo $edit_route; ?>&id=<?php echo (int)$row['id_edukasi']; ?>" class="text-sky-600 hover:text-sky-800 transition-colors duration-150"><i class="fas fa-edit"></i> Edit</a>
                                <a href="<?php echo BASE_URL; ?>index.php?page=edukasi/hapus&id=<?php echo (int)$row['id_edukasi']; ?>" 
                                   class="text-red-600 hover:text-red-800 transition-colors duration-150 btn-hapus" 
                                   data-pesan="Apakah Anda yakin ingin menghapus konten ini?"><i class="fas fa-trash"></i> Hapus</a>
                            </div>
                            <?php endif; ?>
                        </div>
                    </div>
                </div>
            <?php endwhile; ?>
        <?php else: ?>
            <div class="col-span-3 text-center text-gray-500">Belum ada konten edukasi.</div>
        <?php endif; ?>
    </div>
</div>

<!-- Modal baca konten -->
<div id="edukasi-modal" class="fixed inset-0 bg-black bg-opacity-50 hidden items-center justify-center z-50">
  <div class="bg-white rounded-lg overflow-hidden max-w-3xl w-full mx-4 max-h-[90vh] flex flex-col">
    <div class="flex justify-between items-center p-3 border-b">
      <h3 id="edukasi-modal-title" class="text-lg font-semibold">Edukasi</h3>
      <button id="edukasi-modal-close" class="text-gray-600 hover:text-gray-900">&times;</button>
    </div>
    <div id="edukasi-modal-body" class="p-4 overflow-auto"></div>
  </div>
</div>

<script>
async function openEdukasiModal(id){
  try{
    const res = await fetch('<?php echo BASE_URL; ?>modules/edukasi/view.php?id=' + id);
    const html = await res.text();
    const modal = document.getElementById('edukasi-modal');
    const body = document.getElementById('edukasi-modal-body');
    const title = document.getElementById('edukasi-modal-title');
    title.textContent = 'Edukasi';
    body.innerHTML = html;
    modal.classList.remove('hidden');
    modal.classList.add('flex');
  } catch(e){ console.error(e); }
}

(function(){
  const modal = document.getElementById('edukasi-modal');
  const closeBtn = document.getElementById('edukasi-modal-close');
  function close(){ modal.classList.remove('flex'); modal.classList.add('hidden'); }
  closeBtn.addEventListener('click', close);
  modal.addEventListener('click', function(e){ if (e.target === modal) close(); });
})();
</script>
