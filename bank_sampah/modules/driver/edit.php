<?php
// modules/driver/edit.php
check_user_level(['admin']);

if (!isset($_GET['id']) || empty($_GET['id'])) {
    $_SESSION['error_message'] = "ID Driver tidak valid.";
    redirect(BASE_URL . 'index.php?page=driver/data');
}

$id_pengguna = sanitize_input($_GET['id']);

$query = "SELECT p.id_pengguna, p.nama_lengkap, p.username, p.no_telepon, p.alamat,
                 d.id_detail, d.tipe_kendaraan, d.jenis_kendaraan, d.plat_nomor, 
                 d.kapasitas_berat, d.wilayah, d.kecamatan, d.kab_kota, d.kode_pos
          FROM pengguna p
          LEFT JOIN detail_driver d ON p.id_pengguna = d.id_pengguna
          WHERE p.id_pengguna = ? AND p.level = 'driver'";

$stmt = mysqli_prepare($koneksi, $query);
mysqli_stmt_bind_param($stmt, "i", $id_pengguna);
mysqli_stmt_execute($stmt);
$result = mysqli_stmt_get_result($stmt);

if (mysqli_num_rows($result) == 0) {
    $_SESSION['error_message'] = "Data driver tidak ditemukan.";
    mysqli_stmt_close($stmt);
    redirect(BASE_URL . 'index.php?page=driver/data');
}

$driver = mysqli_fetch_assoc($result);
mysqli_stmt_close($stmt);
?>

<div class="container mx-auto px-4 py-8">
    <div class="max-w-3xl mx-auto bg-white rounded-lg shadow-xl overflow-hidden">
        <div class="bg-gray-50 px-6 py-4 border-b border-gray-200 flex justify-between items-center">
            <h2 class="text-xl font-semibold text-gray-800">Edit Data Driver</h2>
            <a href="<?php echo BASE_URL; ?>index.php?page=driver/data" class="text-sm text-gray-500 hover:text-sky-600 transition-colors">
                <i class="fas fa-arrow-left mr-1"></i> Kembali
            </a>
        </div>
        
        <form action="<?php echo BASE_URL; ?>index.php?page=driver/proses_simpan" method="POST" class="p-6">
            <input type="hidden" name="id_pengguna" value="<?php echo $driver['id_pengguna']; ?>">
            
            <h3 class="text-lg font-medium text-gray-900 mb-4 border-b pb-2">Informasi Akun</h3>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
                <div>
                    <label for="nama_lengkap" class="block text-sm font-medium text-gray-700 mb-1">Nama Lengkap *</label>
                    <input type="text" id="nama_lengkap" name="nama_lengkap" required 
                           value="<?php echo htmlspecialchars($driver['nama_lengkap']); ?>"
                           class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-sky-500 focus:border-sky-500">
                </div>
                <div>
                    <label for="no_telepon" class="block text-sm font-medium text-gray-700 mb-1">No. Telepon / WhatsApp *</label>
                    <input type="tel" id="no_telepon" name="no_telepon" required 
                           value="<?php echo htmlspecialchars($driver['no_telepon']); ?>"
                           class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-sky-500 focus:border-sky-500">
                </div>
                <div class="md:col-span-2">
                    <label for="alamat" class="block text-sm font-medium text-gray-700 mb-1">Alamat Lengkap</label>
                    <textarea id="alamat" name="alamat" rows="3" 
                              class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-sky-500 focus:border-sky-500"><?php echo htmlspecialchars($driver['alamat'] ?? ''); ?></textarea>
                </div>
                <div>
                    <label for="password" class="block text-sm font-medium text-gray-700 mb-1">Password Baru (Opsional)</label>
                    <input type="password" id="password" name="password" placeholder="Kosongkan jika tidak ingin mengubah password"
                           class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-sky-500 focus:border-sky-500">
                </div>
            </div>

            <h3 class="text-lg font-medium text-gray-900 mb-4 border-b pb-2">Informasi Kendaraan & Area</h3>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
                <div>
                    <label for="tipe_kendaraan" class="block text-sm font-medium text-gray-700 mb-1">Tipe Kendaraan *</label>
                    <select id="tipe_kendaraan" name="tipe_kendaraan" required class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-sky-500 focus:border-sky-500">
                        <option value="">Pilih Tipe</option>
                        <option value="Mobil" <?php echo ($driver['tipe_kendaraan'] == 'Mobil') ? 'selected' : ''; ?>>Mobil</option>
                        <option value="Truk" <?php echo ($driver['tipe_kendaraan'] == 'Truk') ? 'selected' : ''; ?>>Truk</option>
                        <option value="Motor" <?php echo ($driver['tipe_kendaraan'] == 'Motor') ? 'selected' : ''; ?>>Motor</option>
                    </select>
                </div>
                <div>
                    <label for="jenis_kendaraan" class="block text-sm font-medium text-gray-700 mb-1">Jenis Kendaraan *</label>
                    <input type="text" id="jenis_kendaraan" name="jenis_kendaraan" required 
                           value="<?php echo htmlspecialchars($driver['jenis_kendaraan'] ?? ''); ?>"
                           class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-sky-500 focus:border-sky-500">
                </div>
                <div>
                    <label for="plat_nomor" class="block text-sm font-medium text-gray-700 mb-1">Plat Nomor *</label>
                    <input type="text" id="plat_nomor" name="plat_nomor" required 
                           value="<?php echo htmlspecialchars($driver['plat_nomor'] ?? ''); ?>"
                           class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-sky-500 focus:border-sky-500">
                </div>
                <div>
                    <label for="kapasitas_berat" class="block text-sm font-medium text-gray-700 mb-1">Kapasitas Maksimal (Kg)</label>
                    <input type="number" step="0.01" id="kapasitas_berat" name="kapasitas_berat" 
                           value="<?php echo htmlspecialchars($driver['kapasitas_berat'] ?? ''); ?>"
                           class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-sky-500 focus:border-sky-500">
                </div>
                <div>
                    <label for="wilayah" class="block text-sm font-medium text-gray-700 mb-1">Wilayah / Area</label>
                    <input type="text" id="wilayah" name="wilayah" 
                           value="<?php echo htmlspecialchars($driver['wilayah'] ?? ''); ?>"
                           class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-sky-500 focus:border-sky-500">
                </div>
                <div>
                    <label for="kecamatan" class="block text-sm font-medium text-gray-700 mb-1">Kecamatan</label>
                    <input type="text" id="kecamatan" name="kecamatan" 
                           value="<?php echo htmlspecialchars($driver['kecamatan'] ?? ''); ?>"
                           class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-sky-500 focus:border-sky-500">
                </div>
                <div>
                    <label for="kab_kota" class="block text-sm font-medium text-gray-700 mb-1">Kab/Kota</label>
                    <input type="text" id="kab_kota" name="kab_kota" 
                           value="<?php echo htmlspecialchars($driver['kab_kota'] ?? ''); ?>"
                           class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-sky-500 focus:border-sky-500">
                </div>
                <div>
                    <label for="kode_pos" class="block text-sm font-medium text-gray-700 mb-1">Kode Pos</label>
                    <input type="text" id="kode_pos" name="kode_pos" 
                           value="<?php echo htmlspecialchars($driver['kode_pos'] ?? ''); ?>"
                           class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-sky-500 focus:border-sky-500">
                </div>
            </div>

            <div class="mt-8 pt-5 border-t border-gray-200 flex justify-end gap-3">
                <a href="<?php echo BASE_URL; ?>index.php?page=driver/data" 
                   class="bg-white py-2 px-4 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-sky-500 transition-colors">
                    Batal
                </a>
                <button type="submit" name="update_driver" 
                        class="bg-sky-600 border border-transparent rounded-md shadow-sm py-2 px-6 inline-flex justify-center text-sm font-medium text-white hover:bg-sky-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-sky-500 transition-colors">
                    Update Data Driver
                </button>
            </div>
        </form>
    </div>
</div>
