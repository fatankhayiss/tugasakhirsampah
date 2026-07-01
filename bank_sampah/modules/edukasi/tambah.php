<?php
// modules/edukasi/tambah.php
check_user_level(['admin']);
?>

<div class="container mx-auto px-4 py-8">
  <h1 class="text-3xl font-bold text-gray-800 mb-6">Tambah Konten Edukasi</h1>
  <div class="bg-white p-8 rounded-xl shadow-2xl max-w-2xl mx-auto">
    <form action="<?php echo BASE_URL; ?>index.php?page=edukasi/proses_simpan" method="POST" enctype="multipart/form-data">
      <div class="space-y-6">
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Judul <span class="text-red-500">*</span></label>
          <input type="text" name="judul" required class="mt-1 block w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-sky-500 focus:border-sky-500">
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Konten <span class="text-red-500">*</span></label>
          <textarea name="konten" rows="6" required class="mt-1 block w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-sky-500 focus:border-sky-500"></textarea>
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Gambar (JPEG/PNG/WEBP, maks 5MB)</label>
          <input type="file" name="gambar" accept="image/jpeg,image/png,image/webp" class="block w-full text-sm text-gray-700" />
        </div>
        <div class="grid md:grid-cols-2 gap-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Video URL (YouTube atau tautan lain)</label>
            <input type="url" name="video_url" placeholder="https://..." class="mt-1 block w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-sky-500 focus:border-sky-500">
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Atau Upload Video (MP4/WEBM/OGG, maks 50MB)</label>
            <input type="file" name="video_file" accept="video/mp4,video/webm,video/ogg" class="block w-full text-sm text-gray-700" />
          </div>
        </div>
      </div>
      <div class="mt-8 flex justify-end space-x-3">
        <a href="<?php echo BASE_URL; ?>index.php?page=edukasi/data" class="bg-gray-200 hover:bg-gray-300 text-gray-800 font-semibold py-2 px-4 rounded-lg">Batal</a>
        <button type="submit" name="simpan_edukasi" class="bg-green-600 hover:bg-green-700 text-white font-semibold py-2 px-4 rounded-lg shadow">Simpan</button>
      </div>
    </form>
  </div>
</div>
