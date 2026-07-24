<?php
// modules/orders/index.php
check_user_level(['admin']);

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['assign_driver'])) {
    $id_order = (int)$_POST['id_order'];
    $id_driver = (int)$_POST['id_driver'];

    if ($id_order > 0 && $id_driver > 0) {
        $update = "UPDATE orders SET id_driver = ?, status = 'DRIVER_DITUGASKAN' WHERE id_order = ?";
        $stmt_upd = mysqli_prepare($koneksi, $update);
        mysqli_stmt_bind_param($stmt_upd, "ii", $id_driver, $id_order);
        
        if (mysqli_stmt_execute($stmt_upd)) {
            // Get id_warga
            $get_warga = "SELECT id_warga FROM orders WHERE id_order = ?";
            $stmt_w = mysqli_prepare($koneksi, $get_warga);
            mysqli_stmt_bind_param($stmt_w, "i", $id_order);
            mysqli_stmt_execute($stmt_w);
            $wr = mysqli_stmt_get_result($stmt_w);
            $warga_data = mysqli_fetch_assoc($wr);

            // Notifikasi ke Driver (Picker) - check duplicate first
            $judul = "📦 Penugasan Baru";
            $pesan = "Anda mendapatkan tugas penjemputan sampah baru. Silakan buka detail penjemputan untuk melihat informasi lengkap.";
            
            $check_notif = "SELECT id_notifikasi FROM notifikasi WHERE id_pengguna = ? AND related_id = ? AND tipe = 'info' LIMIT 1";
            $stmt_chk = mysqli_prepare($koneksi, $check_notif);
            mysqli_stmt_bind_param($stmt_chk, "ii", $id_driver, $id_order);
            mysqli_stmt_execute($stmt_chk);
            mysqli_stmt_store_result($stmt_chk);
            $notif_exists = mysqli_stmt_num_rows($stmt_chk) > 0;
            mysqli_stmt_close($stmt_chk);
            
            $notif_success = true;
            $notif_error = '';
            
            if (!$notif_exists) {
                $ins_notif = "INSERT INTO notifikasi (id_pengguna, judul, pesan, tipe, related_id) VALUES (?, ?, ?, 'info', ?)";
                $stmt_notif = mysqli_prepare($koneksi, $ins_notif);
                mysqli_stmt_bind_param($stmt_notif, "issi", $id_driver, $judul, $pesan, $id_order);
                $notif_success = mysqli_stmt_execute($stmt_notif);
                $notif_error = $notif_success ? '' : mysqli_error($koneksi);
                mysqli_stmt_close($stmt_notif);
            }
            
            // Notifikasi ke Warga (Citizen)
            if ($warga_data) {
                $id_warga = $warga_data['id_warga'];
                $pesan_warga = "Picker telah ditugaskan untuk melakukan penjemputan sampah Anda.";
                
                $check_warga = "SELECT id_notifikasi FROM notifikasi WHERE id_pengguna = ? AND related_id = ? AND tipe = 'pickup' LIMIT 1";
                $stmt_chkw = mysqli_prepare($koneksi, $check_warga);
                mysqli_stmt_bind_param($stmt_chkw, "ii", $id_warga, $id_order);
                mysqli_stmt_execute($stmt_chkw);
                mysqli_stmt_store_result($stmt_chkw);
                $notif_warga_exists = mysqli_stmt_num_rows($stmt_chkw) > 0;
                mysqli_stmt_close($stmt_chkw);
                
                if (!$notif_warga_exists) {
                    $ins_notif_w = "INSERT INTO notifikasi (id_pengguna, judul, pesan, tipe, related_id) VALUES (?, 'Konfirmasi Penjemputan', ?, 'pickup', ?)";
                    $stmt_notif_w = mysqli_prepare($koneksi, $ins_notif_w);
                    mysqli_stmt_bind_param($stmt_notif_w, "isi", $id_warga, $pesan_warga, $id_order);
                    mysqli_stmt_execute($stmt_notif_w);
                    mysqli_stmt_close($stmt_notif_w);
                }
            }
            
            if ($notif_success) {
                echo "<script>alert('Penugasan berhasil dikirim ke Picker.'); window.location.href='index.php?page=orders/data';</script>";
            } else {
                echo "<script>alert('Gagal mengirim penugasan: " . addslashes($notif_error) . "'); window.location.href='index.php?page=orders/data';</script>";
            }
            exit;
        }
    }
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['verify_order'])) {
    $id_order = (int)$_POST['id_order'];
    $berat_aktual = isset($_POST['berat_aktual']) && $_POST['berat_aktual'] !== '' ? floatval($_POST['berat_aktual']) : null;

    if ($id_order > 0) {
        if ($berat_aktual !== null) {
            $update = "UPDATE orders SET status = 'SELESAI', berat_aktual = ? WHERE id_order = ?";
            $stmt_upd = mysqli_prepare($koneksi, $update);
            mysqli_stmt_bind_param($stmt_upd, "di", $berat_aktual, $id_order);
        } else {
            $update = "UPDATE orders SET status = 'SELESAI' WHERE id_order = ?";
            $stmt_upd = mysqli_prepare($koneksi, $update);
            mysqli_stmt_bind_param($stmt_upd, "i", $id_order);
        }
        
        if (mysqli_stmt_execute($stmt_upd)) {
            // Notifikasi ke Penyetor & Update Status Driver
            $get_warga = "SELECT id_warga, id_driver, estimasi_berat, berat_aktual, estimasi_poin FROM orders WHERE id_order = ?";
            $stmt_w = mysqli_prepare($koneksi, $get_warga);
            mysqli_stmt_bind_param($stmt_w, "i", $id_order);
            mysqli_stmt_execute($stmt_w);
            $wr = mysqli_stmt_get_result($stmt_w);
            if ($row = mysqli_fetch_assoc($wr)) {
                $id_warga = (int)$row['id_warga'];
                $id_driver = (int)$row['id_driver'];
                $actual_wt = $row['berat_aktual'] !== null ? floatval($row['berat_aktual']) : floatval($row['estimasi_berat'] ?? 1.0);
                $est_wt = floatval($row['estimasi_berat'] ?? 1.0);
                $est_pts = (int)($row['estimasi_poin'] ?? 10);
                $final_points = $est_wt > 0 ? (int)round(($actual_wt / $est_wt) * $est_pts) : $est_pts;
                if ($final_points <= 0) $final_points = $est_pts;

                $upd_poin = "UPDATE pengguna SET poin = COALESCE(poin, 0) + ?, saldo = COALESCE(saldo, 0) + ? WHERE id_pengguna = ?";
                $stmt_p = mysqli_prepare($koneksi, $upd_poin);
                $total_rupiah = $final_points * 1000;
                mysqli_stmt_bind_param($stmt_p, "idi", $final_points, $total_rupiah, $id_warga);
                mysqli_stmt_execute($stmt_p);
                mysqli_stmt_close($stmt_p);

                $pesan = "Penjemputan sampah Anda telah selesai. Total poin ($final_points pts) telah ditambahkan ke saldo Anda.";
                $ins_notif = "INSERT INTO notifikasi (id_pengguna, judul, pesan, tipe, related_id) VALUES (?, 'Penjemputan selesai', ?, 'reward', ?)";
                $stmt_notif = mysqli_prepare($koneksi, $ins_notif);
                mysqli_stmt_bind_param($stmt_notif, "isi", $id_warga, $pesan, $id_order);
                mysqli_stmt_execute($stmt_notif);
                mysqli_stmt_close($stmt_notif);

                // Update status driver ke waiting assignment
                if ($id_driver > 0) {
                    mysqli_query($koneksi, "UPDATE pengguna SET driver_status = 'waiting assignment' WHERE id_pengguna = $id_driver AND level = 'driver'");
                }
            }
            
            echo "<script>alert('Order berhasil diselesaikan dan poin telah ditambahkan!'); window.location.href='index.php?page=orders/data';</script>";
            exit;
        }
    }
}

$status_filter = isset($_GET['status']) ? $_GET['status'] : '';
$page_num = max(1, (int)($_GET['pg'] ?? 1));
$limit = 15;
$offset = ($page_num - 1) * $limit;

// Build where clause
$where = [];
$params = [];
$types = '';

if ($status_filter && $status_filter !== 'all') {
    $where[] = "o.status = ?";
    $params[] = $status_filter;
    $types .= 's';
}

$where_sql = !empty($where) ? 'WHERE ' . implode(' AND ', $where) : '';

// Count
$count_sql = "SELECT COUNT(*) as total FROM orders o $where_sql";
if (!empty($params)) {
    $stmt_c = mysqli_prepare($koneksi, $count_sql);
    mysqli_stmt_bind_param($stmt_c, $types, ...$params);
    mysqli_stmt_execute($stmt_c);
    $cr = mysqli_stmt_get_result($stmt_c);
} else {
    $cr = mysqli_query($koneksi, $count_sql);
}
$total = $cr ? (int)mysqli_fetch_assoc($cr)['total'] : 0;
if (isset($stmt_c)) mysqli_stmt_close($stmt_c);
$total_pages = max(1, ceil($total / $limit));

// Data
$sql = "SELECT o.*, w.nama_lengkap as nama_warga, w.no_telepon as telp_warga,
               d.nama_lengkap as nama_driver,
               (SELECT GROUP_CONCAT(js.nama_sampah SEPARATOR ', ') FROM order_items oi JOIN jenis_sampah js ON oi.id_jenis_sampah = js.id_jenis_sampah WHERE oi.id_order = o.id_order) as waste_types
        FROM orders o
        JOIN pengguna w ON o.id_warga = w.id_pengguna
        LEFT JOIN pengguna d ON o.id_driver = d.id_pengguna
        $where_sql
        ORDER BY o.created_at DESC
        LIMIT $limit OFFSET $offset";

if (!empty($params)) {
    $stmt = mysqli_prepare($koneksi, $sql);
    mysqli_stmt_bind_param($stmt, $types, ...$params);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);
} else {
    $result = mysqli_query($koneksi, $sql);
}

$orders = [];
if ($result) {
    while ($row = mysqli_fetch_assoc($result)) {
        $orders[] = $row;
    }
}
if (isset($stmt)) mysqli_stmt_close($stmt);

// Fetch active pickers for dropdown
$drivers = [];
$res_drivers = mysqli_query($koneksi, "SELECT p.id_pengguna, p.nama_lengkap, p.driver_status, v.vehicle_name as nama_kendaraan, v.vehicle_type as tipe_kendaraan, v.license_plate as plat_nomor 
                                       FROM pengguna p 
                                       LEFT JOIN driver_daily_vehicle v ON p.id_pengguna = v.driver_id AND v.date = CURDATE()
                                       WHERE p.level = 'driver' ORDER BY p.driver_status DESC, p.nama_lengkap ASC");
if ($res_drivers) {
    while($row = mysqli_fetch_assoc($res_drivers)) {
        $drivers[] = $row;
    }
}

$status_labels = [
    'MENUNGGU_KONFIRMASI' => ['label' => 'Menunggu', 'class' => 'bg-yellow-100 text-yellow-800'],
    'DRIVER_DITUGASKAN' => ['label' => 'Ditugaskan', 'class' => 'bg-blue-100 text-blue-800'],
    'DRIVER_MENUJU_LOKASI' => ['label' => 'Dalam Perjalanan', 'class' => 'bg-indigo-100 text-indigo-800'],
    'DRIVER_TIBA' => ['label' => 'Sudah Dekat', 'class' => 'bg-emerald-100 text-emerald-800 font-bold border border-emerald-300'],
    'SAMPAH_DIJEMPUT' => ['label' => 'Dijemput', 'class' => 'bg-purple-100 text-purple-800'],
    'VALIDASI_BANK_SAMPAH' => ['label' => 'Divalidasi', 'class' => 'bg-orange-100 text-orange-800'],
    'SELESAI' => ['label' => 'Selesai', 'class' => 'bg-green-100 text-green-800'],
    'DIBATALKAN' => ['label' => 'Dibatalkan', 'class' => 'bg-red-100 text-red-800'],
];
?>

<div class="container mx-auto px-4 py-8">
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between mb-6">
        <h1 class="text-3xl font-bold text-gray-800">
            <i class="fas fa-truck mr-2 text-rose-500"></i>Orders Penjemputan
        </h1>
        <p class="text-sm text-gray-500 mt-2 sm:mt-0">Total: <?php echo $total; ?> orders</p>
    </div>

    <!-- Filter -->
    <div class="bg-white p-4 rounded-xl shadow-md mb-6 flex flex-wrap gap-2">
        <?php
        $filter_options = [
            '' => 'Semua',
            'MENUNGGU_KONFIRMASI' => 'Menunggu',
            'DRIVER_DITUGASKAN' => 'Ditugaskan',
            'DRIVER_MENUJU_LOKASI' => 'Dalam Perjalanan',
            'DRIVER_TIBA' => 'Sudah Dekat',
            'SAMPAH_DIJEMPUT' => 'Dijemput',
            'VALIDASI_BANK_SAMPAH' => 'Divalidasi',
            'SELESAI' => 'Selesai',
            'DIBATALKAN' => 'Dibatalkan',
        ];
        foreach ($filter_options as $val => $label):
            $active = ($status_filter === $val) ? 'bg-sky-500 text-white' : 'bg-gray-100 text-gray-700 hover:bg-gray-200';
        ?>
            <a href="<?php echo BASE_URL; ?>index.php?page=orders/data&status=<?php echo $val; ?>"
               class="px-4 py-2 rounded-full text-sm font-medium transition <?php echo $active; ?>">
                <?php echo $label; ?>
            </a>
        <?php endforeach; ?>
    </div>

    <!-- Table -->
    <?php if (empty($orders)): ?>
        <div class="bg-white p-12 rounded-xl shadow-md text-center">
            <i class="fas fa-inbox fa-4x text-gray-300 mb-4"></i>
            <p class="text-gray-500 text-lg">Belum ada data orders.</p>
        </div>
    <?php else: ?>
        <div class="bg-white rounded-xl shadow-md overflow-hidden">
            <div class="overflow-x-auto">
                <table class="min-w-full divide-y divide-gray-200">
                    <thead class="bg-gray-50">
                        <tr>
                            <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase">ID</th>
                            <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Penyetor</th>
                            <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Sampah (Estimasi)</th>
                            <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Alamat Jemput</th>
                            <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Waktu</th>
                            <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Picker</th>
                            <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Status</th>
                            <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Tanggal</th>
                            <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Aksi</th>
                        </tr>
                    </thead>
                    <tbody class="bg-white divide-y divide-gray-200">
                        <?php foreach ($orders as $order): 
                            $st = $order['status'];
                            $st_info = $status_labels[$st] ?? ['label' => $st, 'class' => 'bg-gray-100 text-gray-800'];
                        ?>
                        <tr class="hover:bg-gray-50">
                            <td class="px-4 py-3 text-sm font-medium text-gray-900">#<?php echo $order['id_order']; ?></td>
                            <td class="px-4 py-3 text-sm">
                                <div class="font-medium text-gray-800"><?php echo htmlspecialchars($order['nama_warga']); ?></div>
                                <div class="text-xs text-gray-500"><?php echo htmlspecialchars($order['telp_warga'] ?? '-'); ?></div>
                            </td>
                            <td class="px-4 py-3 text-sm">
                                <div class="font-medium text-gray-800"><?php echo htmlspecialchars($order['waste_types'] ?? '-'); ?></div>
                                <div class="text-xs text-gray-500"><?php echo htmlspecialchars($order['estimasi_berat'] ?? '0'); ?> Kg</div>
                            </td>
                            <td class="px-4 py-3 text-sm text-gray-600 max-w-[200px] truncate" title="<?php echo htmlspecialchars($order['alamat_jemput']); ?>">
                                <?php echo htmlspecialchars($order['alamat_jemput']); ?>
                            </td>
                            <td class="px-4 py-3 text-sm text-gray-600">
                                <?php echo ($order['waktu_jemput_dari'] && $order['waktu_jemput_sampai'])
                                    ? substr($order['waktu_jemput_dari'],0,5) . ' - ' . substr($order['waktu_jemput_sampai'],0,5)
                                    : '-'; ?>
                            </td>
                            <td class="px-4 py-3 text-sm text-gray-600">
                                <?php echo $order['nama_driver'] ? htmlspecialchars($order['nama_driver']) : '<span class="text-gray-400 italic">Belum</span>'; ?>
                            </td>
                            <td class="px-4 py-3">
                                <span class="px-2.5 py-1 inline-flex text-xs leading-5 font-semibold rounded-full <?php echo $st_info['class']; ?>">
                                    <?php echo $st_info['label']; ?>
                                </span>
                            </td>
                            <td class="px-4 py-3 text-sm text-gray-500">
                                <?php echo format_tanggal_indonesia($order['created_at'], false); ?>
                            </td>
                            <td class="px-4 py-3 text-sm">
                                <?php if ($st === 'MENUNGGU_KONFIRMASI'): ?>
                                    <form method="POST" action="" class="flex items-center space-x-2" onsubmit="return confirm('Konfirmasi penjemputan dan tugaskan picker ini?');">
                                        <input type="hidden" name="id_order" value="<?php echo $order['id_order']; ?>">
                                        <select name="id_driver" required class="text-sm border-gray-300 rounded-md shadow-sm focus:border-sky-500 focus:ring-sky-500">
                                            <option value="">-- Pilih Picker --</option>
                                            <?php foreach ($drivers as $dr): 
                                                $isOnline = ($dr['driver_status'] ?? 'offline') === 'online';
                                                $statusIcon = $isOnline ? '🟢 Online' : '🔴 Offline';
                                            ?>
                                                <option value="<?php echo $dr['id_pengguna']; ?>" <?php if (!$isOnline) echo 'disabled class="text-gray-400"'; ?>>
                                                    [<?php echo $statusIcon; ?>] <?php echo htmlspecialchars($dr['nama_lengkap'] . " (" . (!empty($dr['nama_kendaraan']) ? $dr['nama_kendaraan'] : ($dr['tipe_kendaraan'] ?? 'Kendaraan')) . ")"); ?><?php if (!$isOnline) echo ' - Tidak Tersedia'; ?>
                                                </option>
                                            <?php endforeach; ?>
                                        </select>
                                        <button type="submit" name="assign_driver" class="bg-sky-500 hover:bg-sky-600 text-white px-3 py-1.5 rounded text-xs font-medium transition">
                                            Tugaskan
                                        </button>
                                    </form>
                                <?php elseif ($st === 'SAMPAH_DIJEMPUT' || $st === 'VALIDASI_BANK_SAMPAH'): ?>
                                    <a href="<?php echo BASE_URL; ?>index.php?page=orders/validate&id=<?php echo $order['id_order']; ?>" 
                                       class="bg-amber-500 hover:bg-amber-600 text-white px-3 py-1.5 rounded text-xs font-semibold shadow transition duration-150 inline-block">
                                        <i class="fas fa-clipboard-check mr-1"></i> Validasi
                                    </a>
                                <?php else: ?>
                                    <a href="<?php echo BASE_URL; ?>index.php?page=orders/detail&id=<?php echo $order['id_order']; ?>" 
                                       class="bg-sky-500 hover:bg-sky-600 text-white px-3 py-1.5 rounded text-xs font-semibold shadow transition duration-150 inline-block">
                                        <i class="fas fa-info-circle mr-1"></i> Detail
                                    </a>
                                <?php endif; ?>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>

            <!-- Pagination -->
            <?php if ($total_pages > 1): ?>
            <div class="px-4 py-3 bg-gray-50 border-t flex items-center justify-between">
                <p class="text-sm text-gray-500">Halaman <?php echo $page_num; ?> dari <?php echo $total_pages; ?></p>
                <div class="flex gap-1">
                    <?php for ($i = 1; $i <= $total_pages; $i++): 
                        $active_pg = ($i == $page_num) ? 'bg-sky-500 text-white' : 'bg-white text-gray-700 hover:bg-gray-100';
                    ?>
                        <a href="<?php echo BASE_URL; ?>index.php?page=orders/data&status=<?php echo $status_filter; ?>&pg=<?php echo $i; ?>"
                           class="px-3 py-1 rounded text-sm border <?php echo $active_pg; ?>">
                            <?php echo $i; ?>
                        </a>
                    <?php endfor; ?>
                </div>
            </div>
            <?php endif; ?>
        </div>
    <?php endif; ?>
</div>
