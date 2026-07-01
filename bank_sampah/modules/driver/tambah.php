<?php
// modules/driver/tambah.php
check_user_level(['admin']);
?>

<div class="container mx-auto px-4 py-8">
    <div class="max-w-3xl mx-auto bg-white rounded-lg shadow-xl overflow-hidden">
        <div class="bg-gray-50 px-6 py-4 border-b border-gray-200 flex justify-between items-center">
            <h2 class="text-xl font-semibold text-gray-800">Tambah Driver Baru</h2>
            <a href="<?php echo BASE_URL; ?>index.php?page=driver/data" class="text-sm text-gray-500 hover:text-sky-600 transition-colors">
                <i class="fas fa-arrow-left mr-1"></i> Kembali
            </a>
        </div>
        
        <form action="<?php echo BASE_URL; ?>index.php?page=driver/proses_simpan" method="POST" class="p-6">
            
            <h3 class="text-lg font-medium text-gray-900 mb-4 border-b pb-2">Informasi Akun</h3>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
                <div>
                    <label for="nama_lengkap" class="block text-sm font-medium text-gray-700 mb-1">Nama Lengkap *</label>
                    <input type="text" id="nama_lengkap" name="nama_lengkap" required 
                           class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-sky-500 focus:border-sky-500">
                </div>
                <div>
                    <label for="no_telepon" class="block text-sm font-medium text-gray-700 mb-1">No. Telepon / WhatsApp *</label>
                    <input type="tel" id="no_telepon" name="no_telepon" required placeholder="08xxxxxxxxxx"
                           class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-sky-500 focus:border-sky-500">
                    <p class="mt-1 text-xs text-gray-500">Nomor ini juga akan digunakan sebagai Username untuk login.</p>
                </div>
                <div class="md:col-span-2">
                    <label for="alamat" class="block text-sm font-medium text-gray-700 mb-1">Alamat Lengkap</label>
                    <textarea id="alamat" name="alamat" rows="3" 
                              class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-sky-500 focus:border-sky-500"></textarea>
                </div>
                <div>
                    <label for="password" class="block text-sm font-medium text-gray-700 mb-1">Password *</label>
                    <input type="password" id="password" name="password" required 
                           class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-sky-500 focus:border-sky-500">
                </div>
            </div>

            <h3 class="text-lg font-medium text-gray-900 mb-4 border-b pb-2">Informasi Kendaraan & Area</h3>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
                <div>
                    <label for="tipe_kendaraan" class="block text-sm font-medium text-gray-700 mb-1">Tipe Kendaraan *</label>
                    <select id="tipe_kendaraan" name="tipe_kendaraan" required class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-sky-500 focus:border-sky-500">
                        <option value="">Pilih Tipe</option>
                        <option value="Mobil">Mobil</option>
                        <option value="Truk">Truk</option>
                        <option value="Motor">Motor</option>
                    </select>
                </div>
                <div>
                    <label for="jenis_kendaraan" class="block text-sm font-medium text-gray-700 mb-1">Jenis Kendaraan *</label>
                    <input type="text" id="jenis_kendaraan" name="jenis_kendaraan" required placeholder="Misal: Pick Up, Tossa, Vario"
                           class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-sky-500 focus:border-sky-500">
                </div>
                <div>
                    <label for="plat_nomor" class="block text-sm font-medium text-gray-700 mb-1">Plat Nomor *</label>
                    <input type="text" id="plat_nomor" name="plat_nomor" required placeholder="Misal: B 1234 CD"
                           class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-sky-500 focus:border-sky-500">
                </div>
                <div>
                    <label for="kapasitas_berat" class="block text-sm font-medium text-gray-700 mb-1">Kapasitas Maksimal (Kg)</label>
                    <input type="number" step="0.01" id="kapasitas_berat" name="kapasitas_berat" placeholder="Misal: 500"
                           class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-sky-500 focus:border-sky-500">
                </div>
                <div>
                    <label for="wilayah" class="block text-sm font-medium text-gray-700 mb-1">Wilayah / Area</label>
                    <input type="text" id="wilayah" name="wilayah" 
                           class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-sky-500 focus:border-sky-500">
                </div>
                <div>
                    <label for="kecamatan" class="block text-sm font-medium text-gray-700 mb-1">Kecamatan</label>
                    <input type="text" id="kecamatan" name="kecamatan" 
                           class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-sky-500 focus:border-sky-500">
                </div>
                <div>
                    <label for="kab_kota" class="block text-sm font-medium text-gray-700 mb-1">Kab/Kota</label>
                    <input type="text" id="kab_kota" name="kab_kota" 
                           class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-sky-500 focus:border-sky-500">
                </div>
                <div>
                    <label for="kode_pos" class="block text-sm font-medium text-gray-700 mb-1">Kode Pos</label>
                    <input type="text" id="kode_pos" name="kode_pos" 
                           class="w-full px-4 py-2 border border-gray-300 rounded-md focus:ring-sky-500 focus:border-sky-500">
                </div>
            </div>

            <div class="mt-8 pt-5 border-t border-gray-200 flex justify-end gap-3">
                <a href="<?php echo BASE_URL; ?>index.php?page=driver/data" 
                   class="bg-white py-2 px-4 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-sky-500 transition-colors">
                    Batal
                </a>
                <button type="submit" name="simpan_driver" 
                        class="bg-sky-600 border border-transparent rounded-md shadow-sm py-2 px-6 inline-flex justify-center text-sm font-medium text-white hover:bg-sky-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-sky-500 transition-colors">
                    Simpan Data Driver
                </button>
            </div>
        </form>
    </div>
</div>
