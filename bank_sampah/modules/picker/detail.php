<?php
// modules/picker/detail.php
// File ini untuk menampilkan detail picker
check_user_level(['admin']); // Hanya admin yang bisa akses

if (!isset($_GET['id']) || empty($_GET['id'])) {
    $_SESSION['error_message'] = "ID Picker tidak valid.";
    redirect(BASE_URL . 'index.php?page=picker/data');
}

$id_pengguna = (int)$_GET['id'];

// 1. Fetch user & detail_driver info
$query_picker = "SELECT p.id_pengguna, p.nama_lengkap, p.username, p.email, p.no_telepon, p.alamat, p.foto_profil, p.driver_status, p.status, p.tanggal_daftar
                 FROM pengguna p
                 WHERE p.id_pengguna = ? AND p.level = 'driver'";

$stmt = mysqli_prepare($koneksi, $query_picker);
mysqli_stmt_bind_param($stmt, "i", $id_pengguna);
mysqli_stmt_execute($stmt);
$res_picker = mysqli_stmt_get_result($stmt);

if (mysqli_num_rows($res_picker) == 0) {
    $_SESSION['error_message'] = "Data Picker tidak ditemukan.";
    mysqli_stmt_close($stmt);
    redirect(BASE_URL . 'index.php?page=picker/data');
}

$picker = mysqli_fetch_assoc($res_picker);
mysqli_stmt_close($stmt);

// 2. Fetch today's vehicle info
$query_today_veh = "SELECT vehicle_name, vehicle_type, license_plate, capacity, notes, created_at, updated_at 
                    FROM driver_daily_vehicle 
                    WHERE driver_id = ? AND date = CURDATE() 
                    LIMIT 1";
$stmt_t = mysqli_prepare($koneksi, $query_today_veh);
mysqli_stmt_bind_param($stmt_t, "i", $id_pengguna);
mysqli_stmt_execute($stmt_t);
$today_vehicle = mysqli_fetch_assoc(mysqli_stmt_get_result($stmt_t));
mysqli_stmt_close($stmt_t);

// 3. Fetch latest vehicle info overall (to get the last vehicle update details)
$query_last_veh = "SELECT vehicle_name, vehicle_type, license_plate, capacity, notes, created_at, updated_at, date 
                   FROM driver_daily_vehicle 
                   WHERE driver_id = ? 
                   ORDER BY date DESC, created_at DESC 
                   LIMIT 1";
$stmt_l = mysqli_prepare($koneksi, $query_last_veh);
mysqli_stmt_bind_param($stmt_l, "i", $id_pengguna);
mysqli_stmt_execute($stmt_l);
$last_vehicle = mysqli_fetch_assoc(mysqli_stmt_get_result($stmt_l));
mysqli_stmt_close($stmt_l);
?>

<div class="container mx-auto px-4 py-8">
    <div class="max-w-4xl mx-auto">
        <!-- Header -->
        <div class="flex items-center justify-between mb-6">
            <div class="flex items-center gap-3">
                <a href="<?php echo BASE_URL; ?>index.php?page=picker/data" class="text-gray-500 hover:text-sky-600 transition-colors">
                    <i class="fas fa-arrow-left fa-lg"></i>
                </a>
                <h1 class="text-2xl sm:text-3xl font-bold text-gray-800">Detail Profil Picker</h1>
            </div>
            <div class="flex gap-2">
                <a href="<?php echo BASE_URL; ?>index.php?page=picker/edit&id=<?php echo $picker['id_pengguna']; ?>" class="bg-sky-500 hover:bg-sky-600 text-white font-semibold py-2 px-4 rounded-lg shadow-md text-sm transition duration-150">
                    <i class="fas fa-edit mr-1.5"></i> Edit Akun
                </a>
                <a href="<?php echo BASE_URL; ?>index.php?page=picker/proses_simpan&action=toggle_status&id=<?php echo $picker['id_pengguna']; ?>" class="bg-teal-500 hover:bg-teal-600 text-white font-semibold py-2 px-4 rounded-lg shadow-md text-sm transition duration-150">
                    <i class="fas fa-toggle-on mr-1.5"></i> Ubah Status Akun
                </a>
            </div>
        </div>

        <!-- Main Info Cards -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
            <!-- Left Card: Avatar and Quick Actions -->
            <div class="bg-white rounded-xl shadow-md p-6 flex flex-col items-center border border-gray-100">
                    <?php 
                        $avatar_src = BASE_URL . 'assets/uploads/default_avatar.png';
                        if (!empty($picker['foto_profil'])) {
                            if (strpos($picker['foto_profil'], 'http') === 0) {
                                $avatar_src = $picker['foto_profil'];
                            } elseif (strpos($picker['foto_profil'], 'assets/') === 0) {
                                $avatar_src = BASE_URL . ltrim($picker['foto_profil'], '/');
                            } else {
                                $avatar_src = BASE_URL . 'assets/uploads/' . $picker['foto_profil'];
                            }
                        }
                    ?>
                    <img class="h-32 w-32 rounded-full object-cover border-4 border-sky-100 shadow-sm mb-4" 
                         src="<?php echo htmlspecialchars($avatar_src); ?>" 
                         alt="Profile Avatar" onerror="this.src='<?php echo BASE_URL . 'assets/uploads/default_avatar.png'; ?>'">
                
                <h2 class="text-xl font-bold text-gray-900 text-center"><?php echo htmlspecialchars($picker['nama_lengkap']); ?></h2>
                <p class="text-sm text-gray-500 mb-4">@<?php echo htmlspecialchars($picker['username']); ?></p>

                <!-- Online Status Badge -->
                <div class="mb-4">
                    <?php 
                    $driver_status = strtolower($picker['driver_status'] ?? 'offline');
                    if ($driver_status === 'online'): ?>
                        <span class="px-3 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">
                            🟢 Online
                        </span>
                    <?php elseif ($driver_status === 'on pickup'): ?>
                        <span class="px-3 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-amber-100 text-amber-800">
                            🟡 On Pickup
                        </span>
                    <?php elseif ($driver_status === 'waiting assignment'): ?>
                        <span class="px-3 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-blue-100 text-blue-800">
                            🔵 Waiting Assignment
                        </span>
                    <?php else: ?>
                        <span class="px-3 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-gray-100 text-gray-800">
                            ⚪ Offline
                        </span>
                    <?php endif; ?>
                </div>

                <!-- Account Status -->
                <div class="w-full border-t pt-4 mt-2">
                    <div class="flex justify-between items-center text-sm">
                        <span class="text-gray-500 font-medium">Status Akun:</span>
                        <span class="font-bold <?php echo ($picker['status'] === 'aktif') ? 'text-emerald-600' : 'text-red-600'; ?>">
                            <?php echo ($picker['status'] === 'aktif') ? 'AKTIF' : 'NONAKTIF'; ?>
                        </span>
                    </div>
                    <div class="flex justify-between items-center text-sm mt-2">
                        <span class="text-gray-500 font-medium">Terdaftar sejak:</span>
                        <span class="text-gray-800"><?php echo date('d M Y', strtotime($picker['tanggal_daftar'])); ?></span>
                    </div>
                </div>
            </div>

            <!-- Right Card: Account Details and Vehicle -->
            <div class="md:col-span-2 space-y-6">
                <!-- Profile Details -->
                <div class="bg-white rounded-xl shadow-md p-6 border border-gray-100">
                    <h3 class="text-lg font-bold text-gray-800 border-b pb-2 mb-4">Detail Informasi Akun</h3>
                    
                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 text-sm">
                        <div>
                            <span class="text-gray-500 block mb-0.5">Email</span>
                            <span class="font-semibold text-gray-800"><?php echo htmlspecialchars($picker['email'] ?? '-'); ?></span>
                        </div>
                        <div>
                            <span class="text-gray-500 block mb-0.5">Nomor Telepon</span>
                            <span class="font-semibold text-gray-800"><?php echo htmlspecialchars($picker['no_telepon'] ?? '-'); ?></span>
                        </div>
                        <div class="sm:col-span-2">
                            <span class="text-gray-500 block mb-0.5">Alamat</span>
                            <span class="font-semibold text-gray-800"><?php echo htmlspecialchars($picker['alamat'] ?? '-'); ?></span>
                        </div>

                    </div>
                </div>

                <!-- Daily Vehicle Info -->
                <div class="bg-white rounded-xl shadow-md p-6 border border-gray-100">
                    <h3 class="text-lg font-bold text-gray-800 border-b pb-2 mb-4">Informasi Kendaraan</h3>
                    
                    <?php if ($today_vehicle): ?>
                        <div class="mb-4 p-4 rounded-lg bg-green-50 border border-green-200">
                            <div class="flex items-center gap-2.5 text-green-800 font-bold text-sm mb-3">
                                <i class="fas fa-check-circle"></i>
                                <span>KENDARAAN HARI INI (AKTIF)</span>
                            </div>
                            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 text-sm">
                                <div>
                                    <span class="text-gray-600 block mb-0.5">Nama Kendaraan</span>
                                    <span class="font-bold text-gray-800"><?php echo htmlspecialchars($today_vehicle['vehicle_name'] ?? '-'); ?></span>
                                </div>
                                <div>
                                    <span class="text-gray-600 block mb-0.5">Tipe Kendaraan</span>
                                    <span class="font-bold text-gray-800"><?php echo htmlspecialchars($today_vehicle['vehicle_type'] ?? '-'); ?></span>
                                </div>
                                <div>
                                    <span class="text-gray-600 block mb-0.5">Plat Nomor</span>
                                    <span class="font-bold text-gray-800"><?php echo htmlspecialchars($today_vehicle['license_plate'] ?? '-'); ?></span>
                                </div>
                                <div>
                                    <span class="text-gray-600 block mb-0.5">Kapasitas</span>
                                    <span class="font-bold text-gray-800"><?php echo htmlspecialchars($today_vehicle['capacity'] ?: '-'); ?></span>
                                </div>
                                <?php if (!empty($today_vehicle['notes'])): ?>
                                <div class="sm:col-span-2">
                                    <span class="text-gray-600 block mb-0.5">Catatan</span>
                                    <span class="font-medium text-gray-700"><?php echo htmlspecialchars($today_vehicle['notes']); ?></span>
                                </div>
                                <?php endif; ?>
                                <div>
                                    <span class="text-gray-600 block mb-0.5">Registration Date</span>
                                    <span class="font-medium text-gray-700"><?php echo date('d M Y H:i:s', strtotime($today_vehicle['created_at'])); ?></span>
                                </div>
                                <div>
                                    <span class="text-gray-600 block mb-0.5">Last Updated</span>
                                    <span class="font-medium text-gray-700"><?php echo $today_vehicle['updated_at'] ? date('d M Y H:i:s', strtotime($today_vehicle['updated_at'])) : date('d M Y H:i:s', strtotime($today_vehicle['created_at'])); ?></span>
                                </div>
                            </div>
                        </div>
                    <?php else: ?>
                        <div class="mb-4 p-4 rounded-lg bg-yellow-50 border border-yellow-200 text-sm text-yellow-800 flex items-center gap-2">
                            <i class="fas fa-exclamation-triangle"></i>
                            <span>Picker belum mendaftarkan kendaraan untuk hari ini.</span>
                        </div>
                    <?php endif; ?>

                    <!-- Last Vehicle Update History -->
                    <?php if ($last_vehicle && (!$today_vehicle || $today_vehicle['created_at'] !== $last_vehicle['created_at'])): ?>
                        <div class="border-t pt-4 mt-4">
                            <span class="text-sm font-semibold text-gray-700 block mb-2">Riwayat Kendaraan Terakhir</span>
                            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 text-xs text-gray-600">
                                <div>
                                    <span>Tipe Kendaraan:</span>
                                    <span class="font-semibold text-gray-800"><?php echo htmlspecialchars($last_vehicle['vehicle_type']); ?></span>
                                </div>
                                <div>
                                    <span>Plat Nomor:</span>
                                    <span class="font-semibold text-gray-800"><?php echo htmlspecialchars($last_vehicle['license_plate']); ?></span>
                                </div>
                                <div>
                                    <span>Tanggal Penggunaan:</span>
                                    <span class="font-semibold text-gray-800"><?php echo date('d M Y', strtotime($last_vehicle['date'])); ?></span>
                                </div>
                                <div>
                                    <span>Terakhir Diperbarui:</span>
                                    <span class="font-semibold text-gray-800"><?php echo date('d M Y H:i:s', strtotime($last_vehicle['created_at'])); ?></span>
                                </div>
                            </div>
                        </div>
                    <?php endif; ?>
                </div>
            </div>
        </div>
    </div>
</div>
