<?php
// modules/penyetor/detail.php
// File ini untuk menampilkan detail penyetor
check_user_level(['admin']); // Hanya admin yang bisa akses

if (!isset($_GET['id']) || empty($_GET['id'])) {
    $_SESSION['error_message'] = "ID Penyetor tidak valid.";
    redirect(BASE_URL . 'index.php?page=penyetor/data');
}

$id_pengguna = (int)$_GET['id'];

// 1. Fetch user info
$query_penyetor = "SELECT id_pengguna, nama_lengkap, username, email, no_telepon, alamat, foto_profil, status, tanggal_daftar, saldo,
                   (SELECT COALESCE(SUM(estimasi_poin), 0) FROM orders WHERE id_warga = pengguna.id_pengguna AND status = 'SELESAI') as total_points
                   FROM pengguna
                   WHERE id_pengguna = ? AND level = 'warga'";

$stmt = mysqli_prepare($koneksi, $query_penyetor);
mysqli_stmt_bind_param($stmt, "i", $id_pengguna);
mysqli_stmt_execute($stmt);
$res_penyetor = mysqli_stmt_get_result($stmt);

if (mysqli_num_rows($res_penyetor) == 0) {
    $_SESSION['error_message'] = "Data Penyetor tidak ditemukan.";
    mysqli_stmt_close($stmt);
    redirect(BASE_URL . 'index.php?page=penyetor/data');
}

$penyetor = mysqli_fetch_assoc($res_penyetor);
mysqli_stmt_close($stmt);

// 2. Fetch stats
$stats_query = "SELECT 
    (SELECT COUNT(*) FROM orders WHERE id_warga = ?) as total_requests,
    (SELECT COUNT(*) FROM orders WHERE id_warga = ? AND status = 'SELESAI') as completed_orders,
    (SELECT COUNT(*) FROM orders WHERE id_warga = ? AND status = 'DIBATALKAN') as cancelled_orders";

$stmt_stats = mysqli_prepare($koneksi, $stats_query);
mysqli_stmt_bind_param($stmt_stats, "iii", $id_pengguna, $id_pengguna, $id_pengguna);
mysqli_stmt_execute($stmt_stats);
$stats = mysqli_fetch_assoc(mysqli_stmt_get_result($stmt_stats));
mysqli_stmt_close($stmt_stats);
?>

<div class="container mx-auto px-4 py-8">
    <div class="max-w-4xl mx-auto">
        <!-- Header -->
        <div class="flex items-center justify-between mb-6">
            <div class="flex items-center gap-3">
                <a href="<?php echo BASE_URL; ?>index.php?page=penyetor/data" class="text-gray-500 hover:text-sky-600 transition-colors">
                    <i class="fas fa-arrow-left fa-lg"></i>
                </a>
                <h1 class="text-2xl sm:text-3xl font-bold text-gray-800">Detail Profil Penyetor</h1>
            </div>
            <div class="flex gap-2">
                <a href="<?php echo BASE_URL; ?>index.php?page=penyetor/edit&id=<?php echo $penyetor['id_pengguna']; ?>" class="bg-sky-500 hover:bg-sky-600 text-white font-semibold py-2 px-4 rounded-lg shadow-md text-sm transition duration-150">
                    <i class="fas fa-edit mr-1.5"></i> Edit Akun
                </a>
                <a href="<?php echo BASE_URL; ?>index.php?page=penyetor/proses_simpan&action=toggle_status&id=<?php echo $penyetor['id_pengguna']; ?>" class="bg-teal-500 hover:bg-teal-600 text-white font-semibold py-2 px-4 rounded-lg shadow-md text-sm transition duration-150">
                    <i class="fas fa-toggle-on mr-1.5"></i> Ubah Status Akun
                </a>
            </div>
        </div>

        <!-- Main Info Cards -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
            <!-- Left Card: Avatar and Quick Stats -->
            <div class="bg-white rounded-xl shadow-md p-6 flex flex-col items-center border border-gray-100">
                <img class="h-32 w-32 rounded-full object-cover border-4 border-sky-100 shadow-sm mb-4" 
                     src="<?php echo BASE_URL . 'assets/uploads/' . (!empty($penyetor['foto_profil']) ? $penyetor['foto_profil'] : 'default_avatar.png'); ?>" 
                     alt="Profile Avatar">
                
                <h2 class="text-xl font-bold text-gray-900 text-center"><?php echo htmlspecialchars($penyetor['nama_lengkap']); ?></h2>
                <p class="text-sm text-gray-500 mb-4">@<?php echo htmlspecialchars($penyetor['username']); ?></p>

                <!-- Account Status Badge -->
                <div class="mb-4">
                    <?php if (($penyetor['status'] ?? 'aktif') === 'aktif'): ?>
                        <span class="px-3 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-emerald-100 text-emerald-800">
                            Aktif
                        </span>
                    <?php else: ?>
                        <span class="px-3 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-red-100 text-red-800">
                            Nonaktif
                        </span>
                    <?php endif; ?>
                </div>

                <!-- Account Balance & Points -->
                <div class="w-full border-t pt-4 mt-2 space-y-3">
                    <div class="flex justify-between items-center text-sm">
                        <span class="text-gray-500 font-medium">Poin Terkumpul:</span>
                        <span class="font-bold text-amber-600 text-base">
                            <?php echo number_format($penyetor['total_points'] ?? 0); ?> pts
                        </span>
                    </div>
                    <div class="flex justify-between items-center text-sm">
                        <span class="text-gray-500 font-medium">Saldo Dompet:</span>
                        <span class="font-bold text-sky-600 text-base">
                            Rp <?php echo number_format($penyetor['saldo'] ?? 0, 0, ',', '.'); ?>
                        </span>
                    </div>
                    <div class="flex justify-between items-center text-sm border-t pt-2 mt-2">
                        <span class="text-gray-500 font-medium">Terdaftar sejak:</span>
                        <span class="text-gray-800 font-medium"><?php echo date('d M Y', strtotime($penyetor['tanggal_daftar'])); ?></span>
                    </div>
                    <div class="flex justify-between items-center text-sm">
                        <span class="text-gray-500 font-medium">Terakhir Login:</span>
                        <span class="text-gray-800 italic text-xs">
                            <?php echo isset($penyetor['last_login']) ? date('d M Y H:i', strtotime($penyetor['last_login'])) : 'Tidak tersedia'; ?>
                        </span>
                    </div>
                </div>
            </div>

            <!-- Right Card: Account Details and Activity Stats -->
            <div class="md:col-span-2 space-y-6">
                <!-- Profile Details -->
                <div class="bg-white rounded-xl shadow-md p-6 border border-gray-100">
                    <h3 class="text-lg font-bold text-gray-800 border-b pb-2 mb-4">Detail Informasi Akun</h3>
                    
                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 text-sm">
                        <div>
                            <span class="text-gray-500 block mb-0.5">Email</span>
                            <span class="font-semibold text-gray-800"><?php echo htmlspecialchars($penyetor['email'] ?? '-'); ?></span>
                        </div>
                        <div>
                            <span class="text-gray-500 block mb-0.5">Nomor Telepon</span>
                            <span class="font-semibold text-gray-800"><?php echo htmlspecialchars($penyetor['no_telepon'] ?? '-'); ?></span>
                        </div>
                        <div class="sm:col-span-2">
                            <span class="text-gray-500 block mb-0.5">Alamat</span>
                            <span class="font-semibold text-gray-800"><?php echo htmlspecialchars($penyetor['alamat'] ?? '-'); ?></span>
                        </div>
                    </div>
                </div>

                <!-- Activity Statistics -->
                <div class="bg-white rounded-xl shadow-md p-6 border border-gray-100">
                    <h3 class="text-lg font-bold text-gray-800 border-b pb-2 mb-4">Statistik Aktivitas Penjemputan</h3>
                    
                    <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 text-center">
                        <div class="p-4 rounded-xl bg-gray-50 border border-gray-100">
                            <span class="text-gray-500 block text-xs font-bold uppercase tracking-wider mb-1">Total Permintaan</span>
                            <span class="text-2xl font-extrabold text-gray-800"><?php echo $stats['total_requests']; ?></span>
                        </div>
                        <div class="p-4 rounded-xl bg-green-50 border border-green-100">
                            <span class="text-green-600 block text-xs font-bold uppercase tracking-wider mb-1">Selesai (Completed)</span>
                            <span class="text-2xl font-extrabold text-green-800"><?php echo $stats['completed_orders']; ?></span>
                        </div>
                        <div class="p-4 rounded-xl bg-red-50 border border-red-100">
                            <span class="text-red-600 block text-xs font-bold uppercase tracking-wider mb-1">Batal (Cancelled)</span>
                            <span class="text-2xl font-extrabold text-red-800"><?php echo $stats['cancelled_orders']; ?></span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
