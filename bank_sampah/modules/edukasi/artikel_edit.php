<?php
// modules/edukasi/artikel_edit.php
check_user_level(['admin']);

$id = isset($_GET['id']) ? (int)$_GET['id'] : 0;
if ($id <= 0) { $_SESSION['error_message'] = 'ID tidak valid.'; redirect(BASE_URL . 'index.php?page=edukasi/data'); }

$res = mysqli_query($koneksi, "SELECT * FROM edukasi WHERE id_edukasi = $id LIMIT 1");
if (!$res || mysqli_num_rows($res) === 0) { $_SESSION['error_message'] = 'Data tidak ditemukan.'; redirect(BASE_URL . 'index.php?page=edukasi/data'); }
$row = mysqli_fetch_assoc($res);

$img = $row['gambar'];
if ($img && !preg_match('#^(https?://|/)#i', $img)) { $img = rtrim(BASE_URL, '/') . '/' . ltrim($img, '/'); }
?>
<div class="container mx-auto px-4 py-8">
  <h1 class="text-3xl font-bold text-gray-800 mb-6">Edit Artikel Edukasi</h1>
  <div class="bg-white p-8 rounded-xl shadow-2xl max-w-2xl mx-auto">
    <form action="<?php echo BASE_URL; ?>index.php?page=edukasi/proses_simpan" method="POST" enctype="multipart/form-data">
      <input type="hidden" name="id_edukasi" value="<?php echo (int)$row['id_edukasi']; ?>">
      <div class="space-y-6">
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Judul <span class="text-red-500">*</span></label>
          <input type="text" name="judul" required value="<?php echo htmlspecialchars($row['judul']); ?>" class="mt-1 block w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-sky-500 focus:border-sky-500">
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Konten <span class="text-red-500">*</span></label>
          <textarea name="konten" rows="10" required class="mt-1 block w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-sky-500 focus:border-sky-500"><?php echo htmlspecialchars($row['konten']); ?></textarea>
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Gambar Saat Ini</label>
          <?php if ($row['gambar']): ?>
            <img src="<?php echo htmlspecialchars($img); ?>" class="h-32 w-full object-cover rounded mb-2" alt="gambar">
          <?php else: ?>
            <div class="text-sm text-gray-500 mb-2">Belum ada gambar.</div>
          <?php endif; ?>
          <label class="block text-sm font-medium text-gray-700 mb-1">Ganti Gambar (opsional)</label>
          <input type="file" name="gambar" accept="image/jpeg,image/png,image/webp" class="block w-full text-sm text-gray-700" />
        </div>
      </div>
      <div class="mt-8 flex justify-end space-x-3">
        <a href="<?php echo BASE_URL; ?>index.php?page=edukasi/data" class="bg-gray-200 hover:bg-gray-300 text-gray-800 font-semibold py-2 px-4 rounded-lg">Batal</a>
        <button type="submit" name="update_edukasi" class="bg-indigo-600 hover:bg-indigo-700 text-white font-semibold py-2 px-4 rounded-lg shadow">Update Artikel</button>
      </div>
    </form>
  </div>
</div>
