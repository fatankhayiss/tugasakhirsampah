<?php
// modules/edukasi/video_tambah.php
check_user_level(['admin']);
?>

<div class="container mx-auto px-4 py-8">
  <h1 class="text-3xl font-bold text-gray-800 mb-6">Tambah Video Edukasi</h1>
  <div class="bg-white p-8 rounded-xl shadow-2xl max-w-2xl mx-auto">
    <form action="<?php echo BASE_URL; ?>index.php?page=edukasi/proses_simpan" method="POST" enctype="multipart/form-data">
      <div class="space-y-6">
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Judul Video <span class="text-red-500">*</span></label>
          <input type="text" name="judul" required class="mt-1 block w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-sky-500 focus:border-sky-500">
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Deskripsi Singkat <span class="text-red-500">*</span></label>
          <textarea name="konten" rows="4" required class="mt-1 block w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-sky-500 focus:border-sky-500"></textarea>
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Gambar Thumbnail (Opsional, JPEG/PNG/WEBP)</label>
          <input type="file" name="gambar" accept="image/jpeg,image/png,image/webp" class="block w-full text-sm text-gray-700" />
        </div>
        <div class="border-t border-gray-200 pt-4">
          <h3 class="text-lg font-medium text-gray-800 mb-3">Sumber Video</h3>
          <div class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Option 1: Video URL (YouTube atau tautan lain)</label>
              <input type="url" name="video_url" id="video_url" placeholder="https://..." class="mt-1 block w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-sky-500 focus:border-sky-500">
            </div>
            <div class="flex items-center">
              <div class="flex-grow border-t border-gray-300"></div>
              <span class="px-3 text-sm text-gray-500 font-semibold">ATAU</span>
              <div class="flex-grow border-t border-gray-300"></div>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Option 2: Upload File MP4 (Maks 50MB)</label>
              <input type="file" name="video_file" id="video_file" accept="video/mp4,video/webm,video/ogg" class="block w-full text-sm text-gray-700" />
            </div>
          </div>
        </div>
      </div>
      <div class="mt-8 flex justify-end space-x-3">
        <a href="<?php echo BASE_URL; ?>index.php?page=edukasi/data" class="bg-gray-200 hover:bg-gray-300 text-gray-800 font-semibold py-2 px-4 rounded-lg">Batal</a>
        <button type="submit" name="simpan_edukasi" class="bg-sky-600 hover:bg-sky-700 text-white font-semibold py-2 px-4 rounded-lg shadow">Simpan Video</button>
      </div>
    </form>
  </div>
</div>

<script>
  document.addEventListener("DOMContentLoaded", function() {
    const videoUrl = document.getElementById('video_url');
    const videoFile = document.getElementById('video_file');

    videoUrl.addEventListener('input', function() {
      if (this.value.trim().length > 0) {
        videoFile.disabled = true;
        videoFile.value = "";
      } else {
        videoFile.disabled = false;
      }
    });

    videoFile.addEventListener('change', function() {
      if (this.files.length > 0) {
        videoUrl.disabled = true;
        videoUrl.value = "";
      } else {
        videoUrl.disabled = false;
      }
    });
  });
</script>
