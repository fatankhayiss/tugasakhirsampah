<?php
// modules/penyetor/index.php
// File ini untuk menampilkan daftar penyetor
check_user_level(['admin']); // Hanya admin yang bisa akses

$search = isset($_GET['search']) ? sanitize_input($_GET['search']) : '';
$query_condition = "";
$params_type = "";
$params_value = [];

// Hanya mencari warga (role = warga/penyetor)
$base_condition = "p.level = 'warga'";

if (!empty($search)) {
    $search_term = "%" . $search . "%";
    $query_condition = " AND (p.nama_lengkap LIKE ? OR p.username LIKE ? OR p.alamat LIKE ? OR p.no_telepon LIKE ? OR p.email LIKE ?)";
    $params_type = "sssss"; 
    for ($i = 0; $i < substr_count($params_type, 's'); $i++) {
        $params_value[] = $search_term;
    }
}

// Hitung total data untuk pagination
$count_query = "SELECT COUNT(*) as total FROM pengguna p WHERE $base_condition $query_condition";
$stmt_cnt = mysqli_prepare($koneksi, $count_query);
if (!empty($search) && $stmt_cnt) {
    mysqli_stmt_bind_param($stmt_cnt, $params_type, ...$params_value);
}
mysqli_stmt_execute($stmt_cnt);
$count_result = mysqli_stmt_get_result($stmt_cnt);
$total_data = mysqli_fetch_assoc($count_result)['total'];
mysqli_stmt_close($stmt_cnt);

// Pagination config
$limit = 10;
$total_pages = ceil($total_data / $limit);
$page_num = max(1, (int)($_GET['pg'] ?? 1));
$offset = ($page_num - 1) * $limit;

// Fetch data
$query_string = "SELECT p.id_pengguna, p.nama_lengkap, p.username, p.alamat, p.no_telepon, p.email, p.tanggal_daftar, p.status, p.foto_profil
                 FROM pengguna p
                 WHERE $base_condition $query_condition 
                 ORDER BY p.nama_lengkap ASC
                 LIMIT ? OFFSET ?";

$stmt = mysqli_prepare($koneksi, $query_string);

$bind_types = $params_type . "ii";
$bind_values = array_merge($params_value, [$limit, $offset]);

if ($stmt) {
    mysqli_stmt_bind_param($stmt, $bind_types, ...$bind_values);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);
} else {
    error_log("MySQLi prepare error in penyetor/index.php: " . mysqli_error($koneksi));
    $result = false; 
}
?>

<div class="container mx-auto px-4 py-8">
    <div class="flex flex-col sm:flex-row justify-between sm:items-center mb-6 gap-4">
        <h1 class="text-2xl sm:text-3xl font-bold text-gray-800">Data Penyetor Terdaftar</h1>
        <a href="<?php echo BASE_URL; ?>index.php?page=penyetor/tambah" class="w-full sm:w-auto bg-green-500 hover:bg-green-600 text-white font-semibold py-2 px-4 rounded-lg shadow-md transition duration-150 ease-in-out flex items-center justify-center text-sm">
            <i class="fas fa-user-plus mr-2"></i> Tambah Penyetor Baru
        </a>
    </div>

    <form method="GET" action="<?php echo BASE_URL; ?>index.php" class="mb-6">
        <input type="hidden" name="page" value="penyetor/data">
        <div class="flex">
            <input type="text" name="search" value="<?php echo htmlspecialchars($search); ?>" placeholder="Cari berdasarkan nama, username, email, no. telepon..." class="w-full px-4 py-2.5 border border-gray-300 rounded-l-lg focus:outline-none focus:ring-2 focus:ring-sky-500 focus:border-sky-500 sm:text-sm">
            <button type="submit" class="bg-sky-500 hover:bg-sky-600 text-white font-semibold px-4 py-2.5 rounded-r-lg transition duration-150 text-sm">
                <i class="fas fa-search"></i> <span class="hidden sm:inline">Cari</span>
            </button>
        </div>
    </form>

    <div class="bg-white shadow-xl rounded-lg overflow-hidden mb-6">
        <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200">
                <thead class="bg-gray-100">
                    <tr>
                        <th scope="col" class="px-4 sm:px-6 py-3 text-left text-xs font-medium text-gray-600 uppercase tracking-wider">No</th>
                        <th scope="col" class="px-4 sm:px-6 py-3 text-left text-xs font-medium text-gray-600 uppercase tracking-wider">Info Penyetor</th>
                        <th scope="col" class="px-4 sm:px-6 py-3 text-left text-xs font-medium text-gray-600 uppercase tracking-wider">Alamat & Kontak</th>
                        <th scope="col" class="px-4 sm:px-6 py-3 text-left text-xs font-medium text-gray-600 uppercase tracking-wider">Status Akun</th>
                        <th scope="col" class="px-4 sm:px-6 py-3 text-left text-xs font-medium text-gray-600 uppercase tracking-wider">Tanggal Daftar</th>
                        <th scope="col" class="px-4 sm:px-6 py-3 text-center text-xs font-medium text-gray-600 uppercase tracking-wider">Aksi</th>
                    </tr>
                </thead>
                <tbody class="bg-white divide-y divide-gray-200">
                    <?php if ($result && mysqli_num_rows($result) > 0): ?>
                        <?php $no = $offset + 1; ?>
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
                                <?php if (($row['status'] ?? 'aktif') === 'aktif'): ?>
                                    <a href="<?php echo BASE_URL; ?>index.php?page=penyetor/proses_simpan&action=toggle_status&id=<?php echo $row['id_pengguna']; ?>" 
                                       class="px-2.5 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-emerald-100 text-emerald-800 hover:bg-emerald-200 transition-colors" 
                                       title="Klik untuk Nonaktifkan Akun">
                                        Aktif
                                    </a>
                                <?php else: ?>
                                    <a href="<?php echo BASE_URL; ?>index.php?page=penyetor/proses_simpan&action=toggle_status&id=<?php echo $row['id_pengguna']; ?>" 
                                       class="px-2.5 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-red-100 text-red-800 hover:bg-red-200 transition-colors" 
                                       title="Klik untuk Aktifkan Akun">
                                        Nonaktif
                                    </a>
                                <?php endif; ?>
                            </td>
                            <td class="px-4 sm:px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                                <?php echo date('d M Y', strtotime($row['tanggal_daftar'])); ?>
                            </td>
                            <td class="px-4 sm:px-6 py-4 whitespace-nowrap text-center text-sm font-medium">
                                <a href="<?php echo BASE_URL; ?>index.php?page=penyetor/detail&id=<?php echo $row['id_pengguna']; ?>" class="text-teal-600 hover:text-teal-800 mr-3 transition-colors duration-150" title="Lihat Detail Penyetor">
                                    <i class="fas fa-eye"></i> <span class="hidden sm:inline">Detail</span>
                                </a>
                                <a href="<?php echo BASE_URL; ?>index.php?page=penyetor/edit&id=<?php echo $row['id_pengguna']; ?>" class="text-sky-600 hover:text-sky-800 mr-3 transition-colors duration-150" title="Edit Data Penyetor">
                                    <i class="fas fa-edit"></i> <span class="hidden sm:inline">Edit</span>
                                </a>
                                <a href="<?php echo BASE_URL; ?>index.php?page=penyetor/hapus&id=<?php echo $row['id_pengguna']; ?>" 
                                   class="text-red-600 hover:text-red-800 transition-colors duration-150 btn-hapus" 
                                   data-pesan="Apakah Anda yakin ingin menghapus penyetor ini? Semua data transaksi terkait juga akan terhapus." title="Hapus Penyetor">
                                   <i class="fas fa-trash"></i> <span class="hidden sm:inline">Hapus</span>
                                </a>
                            </td>
                        </tr>
                        <?php endwhile; ?>
                    <?php else: ?>
                        <tr>
                            <td colspan="6" class="px-6 py-10 text-center text-sm text-gray-500">
                                <div class="flex flex-col items-center">
                                    <i class="fas fa-user-slash fa-3x text-gray-400 mb-3"></i>
                                    <?php if(!empty($search)): ?>
                                        Tidak ada data penyetor ditemukan dengan kata kunci "<strong><?php echo htmlspecialchars($search); ?></strong>".
                                        <br>Coba kata kunci lain atau <a href="<?php echo BASE_URL; ?>index.php?page=penyetor/data" class="text-sky-500 hover:underline mt-2">tampilkan semua penyetor</a>.
                                    <?php else: ?>
                                        Belum ada data penyetor terdaftar.
                                        <br><a href="<?php echo BASE_URL; ?>index.php?page=penyetor/tambah" class="text-sky-500 hover:underline mt-2">Tambahkan penyetor baru sekarang.</a>
                                    <?php endif; ?>
                                </div>
                            </td>
                        </tr>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Pagination -->
    <?php if ($total_pages > 1): ?>
    <div class="flex justify-between items-center bg-white px-4 py-3 border border-gray-200 rounded-lg shadow-sm">
        <p class="text-sm text-gray-500">Menampilkan halaman <?php echo $page_num; ?> dari <?php echo $total_pages; ?></p>
        <div class="flex gap-1">
            <?php if ($page_num > 1): ?>
                <a href="<?php echo BASE_URL; ?>index.php?page=penyetor/data&search=<?php echo urlencode($search); ?>&pg=<?php echo $page_num - 1; ?>" class="px-3 py-1 rounded text-sm border bg-white text-gray-700 hover:bg-gray-100">Sebelumnya</a>
            <?php endif; ?>
            
            <?php for ($i = 1; $i <= $total_pages; $i++): 
                $active_pg = ($i == $page_num) ? 'bg-sky-500 text-white' : 'bg-white text-gray-700 hover:bg-gray-100';
            ?>
                <a href="<?php echo BASE_URL; ?>index.php?page=penyetor/data&search=<?php echo urlencode($search); ?>&pg=<?php echo $i; ?>" class="px-3 py-1 rounded text-sm border <?php echo $active_pg; ?>"><?php echo $i; ?></a>
            <?php endfor; ?>

            <?php if ($page_num < $total_pages): ?>
                <a href="<?php echo BASE_URL; ?>index.php?page=penyetor/data&search=<?php echo urlencode($search); ?>&pg=<?php echo $page_num + 1; ?>" class="px-3 py-1 rounded text-sm border bg-white text-gray-700 hover:bg-gray-100">Selanjutnya</a>
            <?php endif; ?>
        </div>
    </div>
    <?php endif; ?>
</div>

<?php
if ($stmt) {
    mysqli_stmt_close($stmt);
}
?>
