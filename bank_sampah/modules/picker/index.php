<?php
// modules/picker/index.php
// File ini untuk menampilkan daftar picker
check_user_level(['admin']); // Hanya admin yang bisa akses

$search = isset($_GET['search']) ? sanitize_input($_GET['search']) : '';
$query_condition = "";
$params_type = "";
$params_value = [];

// Hanya mencari picker (level = 'driver')
$base_condition = "p.level = 'driver'";

if (!empty($search)) {
    $search_term = "%" . $search . "%";
    $query_condition = " AND (p.nama_lengkap LIKE ? OR p.username LIKE ? OR p.alamat LIKE ? OR p.no_telepon LIKE ? OR p.email LIKE ?)";
    $params_type = "sssss"; 
    for ($i = 0; $i < substr_count($params_type, 's'); $i++) {
        $params_value[] = $search_term;
    }
}

$query_string = "SELECT p.id_pengguna, p.nama_lengkap, p.username, p.alamat, p.no_telepon, p.email, p.tanggal_daftar, p.driver_status, p.status, p.foto_profil,
                        dv.vehicle_type, dv.license_plate, dv.created_at as vehicle_reg_date
                 FROM pengguna p
                 LEFT JOIN driver_daily_vehicle dv ON p.id_pengguna = dv.driver_id AND dv.date = CURDATE()
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
    error_log("MySQLi prepare error in picker/index.php: " . mysqli_error($koneksi));
    $result = false; 
}
?>

<div class="container mx-auto px-4 py-8">
    <div class="flex flex-col sm:flex-row justify-between sm:items-center mb-6 gap-4">
        <h1 class="text-2xl sm:text-3xl font-bold text-gray-800">Data Picker Terdaftar</h1>
        <a href="<?php echo BASE_URL; ?>index.php?page=picker/tambah" class="w-full sm:w-auto bg-green-500 hover:bg-green-600 text-white font-semibold py-2 px-4 rounded-lg shadow-md transition duration-150 ease-in-out flex items-center justify-center text-sm">
            <i class="fas fa-user-plus mr-2"></i> Tambah Picker Baru
        </a>
    </div>

    <form method="GET" action="<?php echo BASE_URL; ?>index.php" class="mb-6">
        <input type="hidden" name="page" value="picker/data">
        <div class="flex">
            <input type="text" name="search" value="<?php echo htmlspecialchars($search); ?>" placeholder="Cari berdasarkan nama, username, email, no. telepon..." class="w-full px-4 py-2.5 border border-gray-300 rounded-l-lg focus:outline-none focus:ring-2 focus:ring-sky-500 focus:border-sky-500 sm:text-sm">
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
                        <th scope="col" class="px-4 sm:px-6 py-3 text-left text-xs font-medium text-gray-600 uppercase tracking-wider">Info Picker</th>
                        <th scope="col" class="px-4 sm:px-6 py-3 text-left text-xs font-medium text-gray-600 uppercase tracking-wider">Alamat & Kontak</th>
                        <th scope="col" class="px-4 sm:px-6 py-3 text-left text-xs font-medium text-gray-600 uppercase tracking-wider">Status Picker</th>
                        <th scope="col" class="px-4 sm:px-6 py-3 text-left text-xs font-medium text-gray-600 uppercase tracking-wider">Nama Kendaraan</th>
                        <th scope="col" class="px-4 sm:px-6 py-3 text-left text-xs font-medium text-gray-600 uppercase tracking-wider">Tipe Kendaraan</th>
                        <th scope="col" class="px-4 sm:px-6 py-3 text-left text-xs font-medium text-gray-600 uppercase tracking-wider">Plat Nomor</th>
                        <th scope="col" class="px-4 sm:px-6 py-3 text-left text-xs font-medium text-gray-600 uppercase tracking-wider">Tgl Reg. Kendaraan</th>
                        <th scope="col" class="px-4 sm:px-6 py-3 text-left text-xs font-medium text-gray-600 uppercase tracking-wider">Status Akun</th>
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
                                <div class="flex items-center">
                                <?php 
                                    $avatar_src = BASE_URL . 'assets/uploads/default_avatar.png';
                                    if (!empty($row['foto_profil'])) {
                                        if (strpos($row['foto_profil'], 'http') === 0) {
                                            $avatar_src = $row['foto_profil'];
                                        } elseif (strpos($row['foto_profil'], 'assets/') === 0) {
                                            $avatar_src = BASE_URL . ltrim($row['foto_profil'], '/');
                                        } else {
                                            $avatar_src = BASE_URL . 'assets/uploads/' . $row['foto_profil'];
                                        }
                                    }
                                ?>
                                    <img class="h-10 w-10 rounded-full object-cover mr-3 border" 
                                         src="<?php echo htmlspecialchars($avatar_src); ?>" 
                                         alt="Avatar" onerror="this.src='<?php echo BASE_URL . 'assets/uploads/default_avatar.png'; ?>'">
                                    <div>
                                        <div class="text-sm font-medium text-gray-900"><?php echo htmlspecialchars($row['nama_lengkap']); ?></div>
                                        <div class="text-xs text-gray-500">@<?php echo htmlspecialchars($row['username']); ?></div>
                                    </div>
                                </div>
                            </td>
                            <td class="px-4 sm:px-6 py-4 whitespace-nowrap">
                                <div class="text-sm text-gray-900"><?php echo htmlspecialchars($row['email'] ?? '-'); ?></div>
                                <div class="text-xs text-gray-500"><?php echo htmlspecialchars($row['no_telepon'] ?? '-'); ?></div>
                            </td>
                            <td class="px-4 sm:px-6 py-4 whitespace-nowrap">
                                <?php 
                                $driver_status = strtolower($row['driver_status'] ?? 'offline');
                                if ($driver_status === 'online'): ?>
                                    <span class="px-2.5 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">
                                        🟢 Online
                                    </span>
                                <?php elseif ($driver_status === 'on pickup'): ?>
                                    <span class="px-2.5 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-amber-100 text-amber-800">
                                        🟡 On Pickup
                                    </span>
                                <?php elseif ($driver_status === 'waiting assignment'): ?>
                                    <span class="px-2.5 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-blue-100 text-blue-800">
                                        🔵 Waiting Assignment
                                    </span>
                                <?php else: ?>
                                    <span class="px-2.5 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-gray-100 text-gray-800">
                                        ⚪ Offline
                                    </span>
                                <?php endif; ?>
                            </td>
                            <td class="px-4 sm:px-6 py-4 whitespace-nowrap text-sm text-gray-900"><?php echo htmlspecialchars($row['vehicle_name'] ?? '-'); ?></td>
                            <td class="px-4 sm:px-6 py-4 whitespace-nowrap text-sm text-gray-900"><?php echo htmlspecialchars($row['vehicle_type'] ?? '-'); ?></td>
                            <td class="px-4 sm:px-6 py-4 whitespace-nowrap text-sm text-gray-900"><?php echo htmlspecialchars($row['license_plate'] ?? '-'); ?></td>
                            <td class="px-4 sm:px-6 py-4 whitespace-nowrap text-sm text-gray-900"><?php echo $row['vehicle_reg_date'] ?? null ? date('d M Y H:i', strtotime($row['vehicle_reg_date'])) : '-'; ?></td>
                            <td class="px-4 sm:px-6 py-4 whitespace-nowrap">
                                <?php if (($row['status'] ?? 'aktif') === 'aktif'): ?>
                                    <a href="<?php echo BASE_URL; ?>index.php?page=picker/proses_simpan&action=toggle_status&id=<?php echo $row['id_pengguna']; ?>" 
                                       class="px-2.5 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-emerald-100 text-emerald-800 hover:bg-emerald-200 transition-colors" 
                                       title="Klik untuk Nonaktifkan Akun">
                                        Aktif
                                    </a>
                                <?php else: ?>
                                    <a href="<?php echo BASE_URL; ?>index.php?page=picker/proses_simpan&action=toggle_status&id=<?php echo $row['id_pengguna']; ?>" 
                                       class="px-2.5 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-red-100 text-red-800 hover:bg-red-200 transition-colors" 
                                       title="Klik untuk Aktifkan Akun">
                                        Nonaktif
                                    </a>
                                <?php endif; ?>
                            </td>
                            <td class="px-4 sm:px-6 py-4 whitespace-nowrap text-center text-sm font-medium">
                                <a href="<?php echo BASE_URL; ?>index.php?page=picker/detail&id=<?php echo $row['id_pengguna']; ?>" class="text-teal-600 hover:text-teal-800 mr-3 transition-colors duration-150" title="Lihat Detail Picker">
                                    <i class="fas fa-eye"></i> <span class="hidden sm:inline">Detail</span>
                                </a>
                                <a href="<?php echo BASE_URL; ?>index.php?page=picker/edit&id=<?php echo $row['id_pengguna']; ?>" class="text-sky-600 hover:text-sky-800 mr-3 transition-colors duration-150" title="Edit Data Picker">
                                    <i class="fas fa-edit"></i> <span class="hidden sm:inline">Edit</span>
                                </a>
                                <a href="<?php echo BASE_URL; ?>index.php?page=picker/hapus&id=<?php echo $row['id_pengguna']; ?>" 
                                   class="text-red-600 hover:text-red-800 transition-colors duration-150 btn-hapus" 
                                   data-pesan="Apakah Anda yakin ingin menghapus picker ini? Semua data terkait juga akan terhapus." title="Hapus Picker">
                                   <i class="fas fa-trash"></i> <span class="hidden sm:inline">Hapus</span>
                                </a>
                            </td>
                        </tr>
                        <?php endwhile; ?>
                    <?php else: ?>
                        <tr>
                            <td colspan="11" class="px-6 py-10 text-center text-sm text-gray-500">
                                <div class="flex flex-col items-center">
                                    <i class="fas fa-user-slash fa-3x text-gray-400 mb-3"></i>
                                    <?php if(!empty($search)): ?>
                                        Tidak ada data picker ditemukan dengan kata kunci "<strong><?php echo htmlspecialchars($search); ?></strong>".
                                        <br>Coba kata kunci lain atau <a href="<?php echo BASE_URL; ?>index.php?page=picker/data" class="text-sky-500 hover:underline mt-2">tampilkan semua picker</a>.
                                    <?php else: ?>
                                        Belum ada data picker terdaftar.
                                        <br><a href="<?php echo BASE_URL; ?>index.php?page=picker/tambah" class="text-sky-500 hover:underline mt-2">Tambahkan picker baru sekarang.</a>
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
