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

            // Notifikasi ke Driver
            $pesan = "Anda mendapat tugas penjemputan baru (Order #$id_order). Segera berangkat!";
            $ins_notif = "INSERT INTO notifikasi (id_pengguna, judul, pesan, tipe, related_id) VALUES (?, 'Tugas Jemput Baru', ?, 'info', ?)";
            $stmt_notif = mysqli_prepare($koneksi, $ins_notif);
            mysqli_stmt_bind_param($stmt_notif, "isi", $id_driver, $pesan, $id_order);
            mysqli_stmt_execute($stmt_notif);
            
            // Notifikasi ke Warga (Citizen)
            if ($warga_data) {
                $id_warga = $warga_data['id_warga'];
                $pesan_warga = "Driver telah ditugaskan untuk melakukan penjemputan sampah Anda.";
                $ins_notif_w = "INSERT INTO notifikasi (id_pengguna, judul, pesan, tipe, related_id) VALUES (?, 'Konfirmasi Penjemputan', ?, 'pickup', ?)";
                $stmt_notif_w = mysqli_prepare($koneksi, $ins_notif_w);
                mysqli_stmt_bind_param($stmt_notif_w, "isi", $id_warga, $pesan_warga, $id_order);
                mysqli_stmt_execute($stmt_notif_w);
            }
            
            echo "<script>alert('Berhasil menugaskan driver dan mengonfirmasi order!'); window.location.href='index.php?page=orders/data';</script>";
            exit;
        }
    }
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['verify_order'])) {
    $id_order = (int)$_POST['id_order'];
    if ($id_order > 0) {
        $update = "UPDATE orders SET status = 'SELESAI' WHERE id_order = ?";
        $stmt_upd = mysqli_prepare($koneksi, $update);
        mysqli_stmt_bind_param($stmt_upd, "i", $id_order);
        
        if (mysqli_stmt_execute($stmt_upd)) {
            // Notifikasi ke Warga
            $get_warga = "SELECT id_warga FROM orders WHERE id_order = ?";
            $stmt_w = mysqli_prepare($koneksi, $get_warga);
            mysqli_stmt_bind_param($stmt_w, "i", $id_order);
            mysqli_stmt_execute($stmt_w);
            $wr = mysqli_stmt_get_result($stmt_w);
            if ($row = mysqli_fetch_assoc($wr)) {
                $id_warga = $row['id_warga'];
                $pesan = "Penjemputan sampah Anda telah selesai. Poin akan segera ditambahkan.";
                $ins_notif = "INSERT INTO notifikasi (id_pengguna, judul, pesan, tipe, related_id) VALUES (?, 'Penjemputan selesai', ?, 'reward', ?)";
                $stmt_notif = mysqli_prepare($koneksi, $ins_notif);
                mysqli_stmt_bind_param($stmt_notif, "isi", $id_warga, $pesan, $id_order);
                mysqli_stmt_execute($stmt_notif);
            }
            
            echo "<script>alert('Order berhasil diselesaikan!'); window.location.href='index.php?page=orders/data';</script>";
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

// Fetch active drivers for dropdown
$drivers = [];
$res_drivers = mysqli_query($koneksi, "SELECT p.id_pengguna, p.nama_lengkap, d.tipe_kendaraan, d.plat_nomor 
                                       FROM pengguna p 
                                       LEFT JOIN detail_driver d ON p.id_pengguna = d.id_pengguna 
                                       WHERE p.level = 'driver' ORDER BY p.nama_lengkap ASC");
if ($res_drivers) {
    while($row = mysqli_fetch_assoc($res_drivers)) {
        $drivers[] = $row;
    }
}

$status_labels = [
    'MENUNGGU_KONFIRMASI' => ['label' => 'Menunggu', 'class' => 'bg-yellow-100 text-yellow-800'],
    'DRIVER_DITUGASKAN' => ['label' => 'Ditugaskan', 'class' => 'bg-blue-100 text-blue-800'],
    'DRIVER_MENUJU_LOKASI' => ['label' => 'Dalam Perjalanan', 'class' => 'bg-indigo-100 text-indigo-800'],
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
                            <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Warga</th>
                            <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Sampah (Estimasi)</th>
                            <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Alamat Jemput</th>
                            <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Waktu</th>
                            <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase">Driver</th>
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
                                    <form method="POST" action="" class="flex items-center space-x-2" onsubmit="return confirm('Konfirmasi penjemputan dan tugaskan driver ini?');">
                                        <input type="hidden" name="id_order" value="<?php echo $order['id_order']; ?>">
                                        <select name="id_driver" required class="text-sm border-gray-300 rounded-md shadow-sm focus:border-sky-500 focus:ring-sky-500">
                                            <option value="">-- Pilih Driver --</option>
                                            <?php foreach ($drivers as $dr): ?>
                                                <option value="<?php echo $dr['id_pengguna']; ?>">
                                                    <?php echo htmlspecialchars($dr['nama_lengkap'] . " (" . ($dr['tipe_kendaraan'] ?? 'Kendaraan') . ")"); ?>
                                                </option>
                                            <?php endforeach; ?>
                                        </select>
                                        <button type="submit" name="assign_driver" class="bg-sky-500 hover:bg-sky-600 text-white px-3 py-1.5 rounded text-xs font-medium transition">
                                            Tugaskan
                                        </button>
                                    </form>
                                <?php elseif ($st === 'SAMPAH_DIJEMPUT' || $st === 'VALIDASI_BANK_SAMPAH'): ?>
                                    <form method="POST" action="" class="flex items-center space-x-2">
                                        <input type="hidden" name="id_order" value="<?php echo $order['id_order']; ?>">
                                        <button type="submit" name="verify_order" class="bg-green-500 hover:bg-green-600 text-white px-3 py-1.5 rounded text-xs font-medium transition" onclick="return confirm('Selesaikan order ini?');">
                                            Selesaikan
                                        </button>
                                    </form>
                                <?php else: ?>
                                    <span class="text-gray-400 italic">No Action</span>
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
