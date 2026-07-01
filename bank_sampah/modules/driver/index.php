<?php
// modules/driver/index.php
// File ini untuk menampilkan daftar driver
check_user_level(['admin']); // Hanya admin yang bisa akses

$search = isset($_GET['search']) ? sanitize_input($_GET['search']) : '';
$query_condition = "";
$params_type = "";
$params_value = [];

// Hanya mencari driver
$base_condition = "p.level = 'driver'";

if (!empty($search)) {
    $search_term = "%" . $search . "%";
    $query_condition = " AND (p.nama_lengkap LIKE ? OR p.username LIKE ? OR p.alamat LIKE ? OR p.no_telepon LIKE ? OR d.plat_nomor LIKE ? OR d.tipe_kendaraan LIKE ?)";
    $params_type = "ssssss"; 
    for ($i = 0; $i < substr_count($params_type, 's'); $i++) {
        $params_value[] = $search_term;
    }
}

$query_string = "SELECT p.id_pengguna, p.nama_lengkap, p.username, p.alamat, p.no_telepon, p.tanggal_daftar,
                        d.tipe_kendaraan, d.jenis_kendaraan, d.plat_nomor, d.kapasitas_berat
                 FROM pengguna p
                 LEFT JOIN detail_driver d ON p.id_pengguna = d.id_pengguna
                 WHERE $base_condition $query_condition 
                 ORDER BY p.nama_lengkap ASC";

$stmt = mysqli_prepare($koneksi, $query_string);

if (!empty($search) && $stmt) {
    mysqli_stmt_bind_param($stmt, $params_type, ...$params_value);
}

if ($stmt) {
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);
} else {
    error_log("MySQLi prepare error in driver/index.php: " . mysqli_error($koneksi));
    $result = false; 
}
?>

<div class="container mx-auto px-4 py-8">
    <div class="flex flex-col sm:flex-row justify-between sm:items-center mb-6 gap-4">
        <h1 class="text-2xl sm:text-3xl font-bold text-gray-800">Data Driver Terdaftar</h1>
        <a href="<?php echo BASE_URL; ?>index.php?page=driver/tambah" class="w-full sm:w-auto bg-green-500 hover:bg-green-600 text-white font-semibold py-2 px-4 rounded-lg shadow-md transition duration-150 ease-in-out flex items-center justify-center text-sm">
            <i class="fas fa-user-plus mr-2"></i> Tambah Driver Baru
        </a>
    </div>

    <form method="GET" action="<?php echo BASE_URL; ?>index.php" class="mb-6">
        <input type="hidden" name="page" value="driver/data">
        <div class="flex">
            <input type="text" name="search" value="<?php echo htmlspecialchars($search); ?>" placeholder="Cari berdasarkan nama, no. telepon, plat nomor..." class="w-full px-4 py-2.5 border border-gray-300 rounded-l-lg focus:outline-none focus:ring-2 focus:ring-sky-500 focus:border-sky-500 sm:text-sm">
            <button type="submit" class="bg-sky-500 hover:bg-sky-600 text-white font-semibold px-4 py-2.5 rounded-r-lg transition duration-150 text-sm">
                <i class="fas fa-search"></i> <span class="hidden sm:inline">Cari</span>
            </button>
        </div>
    </form>

    <div class="bg-white shadow-xl rounded-lg overflow-hidden">
        <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200">
                <thead class="bg-gray-100">
                    <tr>
                        <th scope="col" class="px-4 sm:px-6 py-3 text-left text-xs font-medium text-gray-600 uppercase tracking-wider">No</th>
                        <th scope="col" class="px-4 sm:px-6 py-3 text-left text-xs font-medium text-gray-600 uppercase tracking-wider">Info Driver</th>
                        <th scope="col" class="px-4 sm:px-6 py-3 text-left text-xs font-medium text-gray-600 uppercase tracking-wider">Kendaraan</th>
                        <th scope="col" class="px-4 sm:px-6 py-3 text-left text-xs font-medium text-gray-600 uppercase tracking-wider">Plat Nomor</th>
                        <th scope="col" class="px-4 sm:px-6 py-3 text-center text-xs font-medium text-gray-600 uppercase tracking-wider">Aksi</th>
                    </tr>
                </thead>
                <tbody class="bg-white divide-y divide-gray-200">
                    <?php if ($result && mysqli_num_rows($result) > 0): ?>
                        <?php $no = 1; ?>
                        <?php while($row = mysqli_fetch_assoc($result)): ?>
                        <tr class="hover:bg-gray-50 transition-colors duration-150">
                            <td class="px-4 sm:px-6 py-4 whitespace-nowrap text-sm text-gray-500"><?php echo $no++; ?></td>
                            <td class="px-4 sm:px-6 py-4 whitespace-nowrap">
                                <div class="text-sm font-medium text-gray-900"><?php echo htmlspecialchars($row['nama_lengkap']); ?></div>
                                <div class="text-sm text-gray-500"><?php echo htmlspecialchars($row['no_telepon']); ?></div>
                            </td>
                            <td class="px-4 sm:px-6 py-4 whitespace-nowrap">
                                <div class="text-sm text-gray-900"><?php echo htmlspecialchars($row['tipe_kendaraan'] ?? '-'); ?></div>
                                <div class="text-sm text-gray-500"><?php echo htmlspecialchars($row['jenis_kendaraan'] ?? '-'); ?></div>
                            </td>
                            <td class="px-4 sm:px-6 py-4 whitespace-nowrap">
                                <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-blue-100 text-blue-800">
                                    <?php echo htmlspecialchars($row['plat_nomor'] ?? '-'); ?>
                                </span>
                            </td>
                            <td class="px-4 sm:px-6 py-4 whitespace-nowrap text-center text-sm font-medium">
                                <a href="<?php echo BASE_URL; ?>index.php?page=driver/edit&id=<?php echo $row['id_pengguna']; ?>" class="text-sky-600 hover:text-sky-800 mr-3 transition-colors duration-150" title="Edit Data Driver">
                                    <i class="fas fa-edit"></i> <span class="hidden sm:inline">Edit</span>
                                </a>
                                <a href="<?php echo BASE_URL; ?>index.php?page=driver/hapus&id=<?php echo $row['id_pengguna']; ?>" 
                                   class="text-red-600 hover:text-red-800 transition-colors duration-150 btn-hapus" 
                                   data-pesan="Apakah Anda yakin ingin menghapus driver ini? Semua data terkait juga akan terhapus." title="Hapus Driver">
                                   <i class="fas fa-trash"></i> <span class="hidden sm:inline">Hapus</span>
                                </a>
                            </td>
                        </tr>
                        <?php endwhile; ?>
                    <?php else: ?>
                        <tr>
                            <td colspan="5" class="px-6 py-10 text-center text-sm text-gray-500">
                                <div class="flex flex-col items-center">
                                    <i class="fas fa-truck-slash fa-3x text-gray-400 mb-3"></i>
                                    <?php if(!empty($search)): ?>
                                        Tidak ada data driver ditemukan dengan kata kunci "<strong><?php echo htmlspecialchars($search); ?></strong>".
                                        <br>Coba kata kunci lain atau <a href="<?php echo BASE_URL; ?>index.php?page=driver/data" class="text-sky-500 hover:underline mt-2">tampilkan semua driver</a>.
                                    <?php else: ?>
                                        Belum ada data driver terdaftar.
                                        <br><a href="<?php echo BASE_URL; ?>index.php?page=driver/tambah" class="text-sky-500 hover:underline mt-2">Tambahkan driver baru sekarang.</a>
                                    <?php endif; ?>
                                </div>
                            </td>
                        </tr>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<?php
if ($stmt) {
    mysqli_stmt_close($stmt);
}
?>
