<?php
// modules/penyetor/edit.php
check_user_level(['admin']);

if (!isset($_GET['id']) || empty($_GET['id'])) {
    $_SESSION['error_message'] = "ID Penyetor tidak valid.";
    redirect(BASE_URL . 'index.php?page=penyetor/data');
}

$id_pengguna = sanitize_input($_GET['id']);

$query = "SELECT id_pengguna, nama_lengkap, username, no_telepon, alamat, email, status
          FROM pengguna
          WHERE id_pengguna = ? AND level = 'warga'";

$stmt = mysqli_prepare($koneksi, $query);
mysqli_stmt_bind_param($stmt, "i", $id_pengguna);
mysqli_stmt_execute($stmt);
$result = mysqli_stmt_get_result($stmt);

if (mysqli_num_rows($result) == 0) {
    $_SESSION['error_message'] = "Data penyetor tidak ditemukan.";
    mysqli_stmt_close($stmt);
    redirect(BASE_URL . 'index.php?page=penyetor/data');
}

$penyetor = mysqli_fetch_assoc($result);
mysqli_stmt_close($stmt);
?>

<div class="container mx-auto px-4 py-8">
    <div class="max-w-3xl mx-auto bg-white rounded-lg shadow-xl overflow-hidden">
        <div class="bg-gray-50 px-6 py-4 border-b border-gray-200 flex justify-between items-center">
            <h2 class="text-xl font-semibold text-gray-800">Edit Data Penyetor</h2>
            <a href="<?php echo BASE_URL; ?>index.php?page=penyetor/data" class="text-sm text-gray-500 hover:text-sky-600 transition-colors">
                <i class="fas fa-arrow-left mr-1"></i> Kembali
            </a>
        </div>
        
        <form action="<?php echo BASE_URL; ?>index.php?page=penyetor/proses_simpan" method="POST" class="p-6">
            <input type="hidden" name="id_pengguna" value="<?php echo $penyetor['id_pengguna']; ?>">
            
            <h3 class="text-lg font-medium text-gray-900 mb-4 border-b pb-2">Informasi Akun</h3>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
                <div>
                    <label for="username" class="block text-sm font-medium text-gray-700 mb-1">Username *</label>
                    <input type="text" id="username" name="username" required 
                           value="<?php echo htmlspecialchars($penyetor['username']); ?>"
                           class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-sky-500 focus:border-sky-500">
                </div>
                <div>
                    <label for="nama_lengkap" class="block text-sm font-medium text-gray-700 mb-1">Nama Lengkap *</label>
                    <input type="text" id="nama_lengkap" name="nama_lengkap" required 
                           value="<?php echo htmlspecialchars($penyetor['nama_lengkap']); ?>"
                           class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-sky-500 focus:border-sky-500">
                </div>
                <div>
                    <label for="email" class="block text-sm font-medium text-gray-700 mb-1">Email *</label>
                    <input type="email" id="email" name="email" required 
                           value="<?php echo htmlspecialchars($penyetor['email'] ?? ''); ?>"
                           class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-sky-500 focus:border-sky-500">
                </div>
                <div>
                    <label for="no_telepon" class="block text-sm font-medium text-gray-700 mb-1">No. Telepon / WhatsApp *</label>
                    <input type="tel" id="no_telepon" name="no_telepon" required
                           value="<?php echo htmlspecialchars($penyetor['no_telepon'] ?? ''); ?>"
                           class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-sky-500 focus:border-sky-500">
                </div>
                <div class="md:col-span-2">
                    <label for="alamat" class="block text-sm font-medium text-gray-700 mb-1">Alamat Lengkap (Opsional)</label>
                    <textarea id="alamat" name="alamat" rows="3" 
                              class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-sky-500 focus:border-sky-500"><?php echo htmlspecialchars($penyetor['alamat'] ?? ''); ?></textarea>
                </div>
                <div>
                    <label for="status" class="block text-sm font-medium text-gray-700 mb-1">Status Akun *</label>
                    <select id="status" name="status" required class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-sky-500 focus:border-sky-500">
                        <option value="aktif" <?php echo (($penyetor['status'] ?? 'aktif') === 'aktif') ? 'selected' : ''; ?>>Aktif</option>
                        <option value="nonaktif" <?php echo (($penyetor['status'] ?? 'aktif') === 'nonaktif') ? 'selected' : ''; ?>>Nonaktif</option>
                    </select>
                </div>
                <div>
                    <label for="password" class="block text-sm font-medium text-gray-700 mb-1">Password Baru (Opsional)</label>
                    <input type="password" id="password" name="password" placeholder="Kosongkan jika tidak ingin mengubah password"
                           class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-sky-500 focus:border-sky-500">
                </div>
            </div>

            <div class="mt-8 pt-5 border-t border-gray-200 flex justify-end gap-3">
                <a href="<?php echo BASE_URL; ?>index.php?page=penyetor/data" 
                   class="bg-white py-2 px-4 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-sky-500 transition-colors">
                    Batal
                </a>
                <button type="submit" name="update_penyetor" 
                        class="bg-sky-600 border border-transparent rounded-md shadow-sm py-2 px-6 inline-flex justify-center text-sm font-medium text-white hover:bg-sky-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-sky-500 transition-colors">
                    Update Data Penyetor
                </button>
            </div>
        </form>
    </div>
</div>
