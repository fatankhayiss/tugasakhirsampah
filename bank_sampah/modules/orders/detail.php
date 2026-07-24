<?php
// modules/orders/detail.php
check_user_level(['admin']);

if (!isset($_GET['id']) || empty($_GET['id'])) {
    $_SESSION['error_message'] = "ID Order tidak valid.";
    redirect(BASE_URL . 'index.php?page=orders/data');
}

$id_order = (int)$_GET['id'];

// Handle POST actions
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $poin_final = isset($_POST['poin_final']) ? (int)$_POST['poin_final'] : 0;
    
    // Fetch order first to get driver and citizen IDs
    $stmt_o = mysqli_prepare($koneksi, "SELECT id_warga, id_driver FROM orders WHERE id_order = ?");
    mysqli_stmt_bind_param($stmt_o, "i", $id_order);
    mysqli_stmt_execute($stmt_o);
    $order_data = mysqli_fetch_assoc(mysqli_stmt_get_result($stmt_o));
    mysqli_stmt_close($stmt_o);
    
    if (!$order_data) {
        $_SESSION['error_message'] = "Pesanan tidak ditemukan.";
        redirect(BASE_URL . 'index.php?page=orders/data');
    }
    
    $id_warga = (int)$order_data['id_warga'];
    $id_driver = (int)$order_data['id_driver'];

    // 1. Process Order Items update
    $total_berat_aktual = 0.00;
    if (isset($_POST['items']) && is_array($_POST['items'])) {
        foreach ($_POST['items'] as $item_id => $item_data) {
            $id_order_item = (int)$item_id;
            $id_jenis_sampah = (int)$item_data['id_jenis_sampah'];
            $berat_aktual_kg = floatval($item_data['berat_aktual_kg']);
            
            $total_berat_aktual += $berat_aktual_kg;
            
            $stmt_item = mysqli_prepare($koneksi, "UPDATE order_items SET id_jenis_sampah = ?, berat_aktual_kg = ? WHERE id_order_item = ? AND id_order = ?");
            mysqli_stmt_bind_param($stmt_item, "idii", $id_jenis_sampah, $berat_aktual_kg, $id_order_item, $id_order);
            mysqli_stmt_execute($stmt_item);
            mysqli_stmt_close($stmt_item);
        }
    }

    if (isset($_POST['action_reject'])) {
        // ==========================================
        // ACTION REJECT
        // ==========================================
        $rejection_reason = isset($_POST['rejection_reason']) ? trim($_POST['rejection_reason']) : 'Dibatalkan oleh Admin.';

        $stmt_upd = mysqli_prepare($koneksi, "UPDATE orders SET status = 'DIBATALKAN', rejection_reason = ? WHERE id_order = ?");
        mysqli_stmt_bind_param($stmt_upd, "si", $rejection_reason, $id_order);
        mysqli_stmt_execute($stmt_upd);
        mysqli_stmt_close($stmt_upd);

        // Make Picker available
        if ($id_driver > 0) {
            mysqli_query($koneksi, "UPDATE pengguna SET driver_status = 'waiting assignment' WHERE id_pengguna = $id_driver AND level = 'driver'");
        }

        // Send notification to Penyetor
        $pesan_warga = "Permintaan penjemputan sampah Anda (Order #$id_order) telah ditolak/dibatalkan oleh Admin. Alasan: $rejection_reason";
        $stmt_notif = mysqli_prepare($koneksi, "INSERT INTO notifikasi (id_pengguna, judul, pesan, tipe, related_id) VALUES (?, 'Penjemputan Dibatalkan', ?, 'info', ?)");
        mysqli_stmt_bind_param($stmt_notif, "isi", $id_warga, $pesan_warga, $id_order);
        mysqli_stmt_execute($stmt_notif);
        mysqli_stmt_close($stmt_notif);

        // Send notification to Picker
        if ($id_driver > 0) {
            $pesan_driver = "Penjemputan untuk Order #$id_order telah ditolak/dibatalkan oleh Admin. Alasan: $rejection_reason";
            $stmt_notif_d = mysqli_prepare($koneksi, "INSERT INTO notifikasi (id_pengguna, judul, pesan, tipe, related_id) VALUES (?, 'Penjemputan Dibatalkan', ?, 'info', ?)");
            mysqli_stmt_bind_param($stmt_notif_d, "isi", $id_driver, $pesan_driver, $id_order);
            mysqli_stmt_execute($stmt_notif_d);
            mysqli_stmt_close($stmt_notif_d);
        }

        $_SESSION['success_message'] = "Pesanan #$id_order berhasil dibatalkan dengan alasan: $rejection_reason.";
        redirect(BASE_URL . 'index.php?page=orders/data');

    } elseif (isset($_POST['action_approve'])) {
        // ==========================================
        // ACTION APPROVE
        // ==========================================
        $stmt_upd = mysqli_prepare($koneksi, "UPDATE orders SET status = 'SELESAI', berat_aktual = ?, estimasi_poin = ? WHERE id_order = ?");
        mysqli_stmt_bind_param($stmt_upd, "dii", $total_berat_aktual, $poin_final, $id_order);
        mysqli_stmt_execute($stmt_upd);
        mysqli_stmt_close($stmt_upd);

        // Credit balance to Penyetor (1 Poin = Rp 1,000)
        $total_rupiah = $poin_final * 1000;
        $stmt_credit = mysqli_prepare($koneksi, "UPDATE pengguna SET saldo = COALESCE(saldo, 0) + ? WHERE id_pengguna = ?");
        mysqli_stmt_bind_param($stmt_credit, "di", $total_rupiah, $id_warga);
        mysqli_stmt_execute($stmt_credit);
        mysqli_stmt_close($stmt_credit);

        // Create point transaction history in 'transaksi' table
        $id_petugas = isset($_SESSION['user_id']) ? (int)$_SESSION['user_id'] : 1;
        $keterangan_trx = "Validasi setoran penjemputan sampah #$id_order";
        
        $stmt_trx = mysqli_prepare($koneksi, "INSERT INTO transaksi (id_warga, id_petugas_pencatat, tipe_transaksi, total_nilai, keterangan) VALUES (?, ?, 'setor', ?, ?)");
        mysqli_stmt_bind_param($stmt_trx, "iids", $id_warga, $id_petugas, $total_rupiah, $keterangan_trx);
        mysqli_stmt_execute($stmt_trx);
        $id_transaksi_setor = mysqli_insert_id($koneksi);
        mysqli_stmt_close($stmt_trx);

        // Insert details into 'detail_setoran' for each item
        if ($id_transaksi_setor > 0 && isset($_POST['items']) && is_array($_POST['items'])) {
            $stmt_detail = mysqli_prepare($koneksi, "INSERT INTO detail_setoran (id_transaksi_setor, id_jenis_sampah, berat_kg, harga_saat_setor, subtotal_nilai) VALUES (?, ?, ?, ?, ?)");
            foreach ($_POST['items'] as $item_id => $item_data) {
                $id_jenis_sampah = (int)$item_data['id_jenis_sampah'];
                $berat_aktual_kg = floatval($item_data['berat_aktual_kg']);
                
                // Get price for this trash category
                $price_query = mysqli_query($koneksi, "SELECT harga_per_kg FROM jenis_sampah WHERE id_jenis_sampah = $id_jenis_sampah");
                $price_row = mysqli_fetch_assoc($price_query);
                $harga_saat_setor = isset($price_row['harga_per_kg']) ? floatval($price_row['harga_per_kg']) : 0.0;
                $subtotal_nilai = $berat_aktual_kg * $harga_saat_setor;
                
                mysqli_stmt_bind_param($stmt_detail, "iiddd", $id_transaksi_setor, $id_jenis_sampah, $berat_aktual_kg, $harga_saat_setor, $subtotal_nilai);
                mysqli_stmt_execute($stmt_detail);
            }
            mysqli_stmt_close($stmt_detail);
        }

        // Make Picker available
        if ($id_driver > 0) {
            mysqli_query($koneksi, "UPDATE pengguna SET driver_status = 'waiting assignment' WHERE id_pengguna = $id_driver AND level = 'driver'");
        }

        // Send notification
        $pesan = "Penjemputan selesai. Total poin ($poin_final pts) telah ditambahkan ke saldo Anda.";
        $stmt_notif = mysqli_prepare($koneksi, "INSERT INTO notifikasi (id_pengguna, judul, pesan, tipe, related_id) VALUES (?, 'Penjemputan Selesai', ?, 'reward', ?)");
        mysqli_stmt_bind_param($stmt_notif, "isi", $id_warga, $pesan, $id_order);
        mysqli_stmt_execute($stmt_notif);
        mysqli_stmt_close($stmt_notif);

        $_SESSION['success_message'] = "Pesanan #$id_order berhasil diselesaikan dan poin telah ditambahkan ke Penyetor.";
        redirect(BASE_URL . 'index.php?page=orders/data');

    } elseif (isset($_POST['action_save'])) {
        // ==========================================
        // ACTION SAVE (KEEP VALIDATION MODE)
        // ==========================================
        $stmt_upd = mysqli_prepare($koneksi, "UPDATE orders SET berat_aktual = ?, estimasi_poin = ? WHERE id_order = ?");
        mysqli_stmt_bind_param($stmt_upd, "dii", $total_berat_aktual, $poin_final, $id_order);
        mysqli_stmt_execute($stmt_upd);
        mysqli_stmt_close($stmt_upd);

        $_SESSION['success_message'] = "Detail validasi pesanan #$id_order berhasil disimpan.";
        redirect(BASE_URL . 'index.php?page=orders/detail&id=' . $id_order);
    }
}

// Fetch order information
$query_order = "SELECT o.*, 
                w.nama_lengkap as nama_warga, w.username as username_warga, w.no_telepon as telp_warga, w.email as email_warga, w.alamat as alamat_warga, w.foto_profil as foto_warga,
                d.nama_lengkap as nama_driver, d.no_telepon as telp_driver, d.foto_profil as foto_driver,
                dv.vehicle_type as daily_vehicle_type, dv.license_plate as daily_license_plate
                FROM orders o
                JOIN pengguna w ON o.id_warga = w.id_pengguna
                LEFT JOIN pengguna d ON o.id_driver = d.id_pengguna
                LEFT JOIN driver_daily_vehicle dv ON o.id_driver = dv.driver_id AND dv.date = DATE(o.tanggal_order)
                WHERE o.id_order = ?";

$stmt = mysqli_prepare($koneksi, $query_order);
mysqli_stmt_bind_param($stmt, "i", $id_order);
mysqli_stmt_execute($stmt);
$order = mysqli_fetch_assoc(mysqli_stmt_get_result($stmt));
mysqli_stmt_close($stmt);

if (!$order) {
    $_SESSION['error_message'] = "Data pesanan tidak ditemukan.";
    redirect(BASE_URL . 'index.php?page=orders/data');
}

// Fetch order items
$items_query = "SELECT oi.*, js.nama_sampah, js.harga_per_kg 
                FROM order_items oi
                JOIN jenis_sampah js ON oi.id_jenis_sampah = js.id_jenis_sampah
                WHERE oi.id_order = ?";
$stmt_i = mysqli_prepare($koneksi, $items_query);
mysqli_stmt_bind_param($stmt_i, "i", $id_order);
mysqli_stmt_execute($stmt_i);
$res_items = mysqli_stmt_get_result($stmt_i);
$items = [];
while ($row = mysqli_fetch_assoc($res_items)) {
    $items[] = $row;
}
mysqli_stmt_close($stmt_i);

// Fetch all categories for dropdown correction
$categories_res = mysqli_query($koneksi, "SELECT id_jenis_sampah, nama_sampah, harga_per_kg FROM jenis_sampah ORDER BY nama_sampah ASC");
$categories = [];
while ($cat = mysqli_fetch_assoc($categories_res)) {
    $categories[] = $cat;
}

// Fetch Citizen's AI Detections (latest 3)
$id_warga = (int)$order['id_warga'];
$ai_query = "SELECT uploaded_file, labels_json, created_at 
             FROM deteksi 
             WHERE id_pengguna = ? 
             ORDER BY created_at DESC 
             LIMIT 3";
$stmt_ai = mysqli_prepare($koneksi, $ai_query);
mysqli_stmt_bind_param($stmt_ai, "i", $id_warga);
mysqli_stmt_execute($stmt_ai);
$res_ai = mysqli_stmt_get_result($stmt_ai);
$ai_detections = [];
while ($ai = mysqli_fetch_assoc($res_ai)) {
    $ai_detections[] = $ai;
}
mysqli_stmt_close($stmt_ai);

$status = $order['status'];
$is_editable = !in_array($status, ['SELESAI', 'DIBATALKAN']);
?>

<div class="container mx-auto px-4 py-8">
    <!-- Header -->
    <div class="flex items-center justify-between mb-6">
        <div class="flex items-center gap-3">
            <a href="<?php echo BASE_URL; ?>index.php?page=orders/data" class="text-gray-500 hover:text-sky-600 transition-colors">
                <i class="fas fa-arrow-left fa-lg"></i>
            </a>
            <h1 class="text-2xl sm:text-3xl font-bold text-gray-800">Detail Setoran Sampah #<?php echo $order['id_order']; ?></h1>
        </div>
        <div>
            <?php
            $status_labels = [
                'MENUNGGU_KONFIRMASI' => ['label' => 'Menunggu Konfirmasi', 'class' => 'bg-amber-100 text-amber-800'],
                'DRIVER_DITUGASKAN' => ['label' => 'Picker Ditugaskan', 'class' => 'bg-blue-100 text-blue-800'],
                'DRIVER_MENUJU_LOKASI' => ['label' => 'Dalam Perjalanan', 'class' => 'bg-indigo-100 text-indigo-800'],
                'DRIVER_TIBA' => ['label' => 'Picker Sudah Dekat', 'class' => 'bg-emerald-100 text-emerald-800 font-bold border border-emerald-300'],
                'SAMPAH_DIJEMPUT' => ['label' => 'Sampah Dijemput', 'class' => 'bg-purple-100 text-purple-800'],
                'VALIDASI_BANK_SAMPAH' => ['label' => 'Waiting Validation', 'class' => 'bg-amber-100 text-amber-800 border border-amber-300'],
                'SELESAI' => ['label' => 'Completed', 'class' => 'bg-emerald-100 text-emerald-800'],
                'DIBATALKAN' => ['label' => 'Dibatalkan', 'class' => 'bg-red-100 text-red-800'],
            ];
            $st_label = $status_labels[$status] ?? ['label' => $status, 'class' => 'bg-gray-100 text-gray-800'];
            ?>
            <span class="px-4 py-1.5 text-sm font-semibold rounded-full <?php echo $st_label['class']; ?>">
                <?php echo $st_label['label']; ?>
            </span>
        </div>
    </div>

    <!-- Timeline Progress Tracker -->
    <div class="bg-white rounded-xl shadow p-6 mb-8 border border-gray-100">
        <h2 class="text-lg font-bold text-gray-800 border-b pb-2 mb-6">Status Alur Penjemputan (Timeline)</h2>
        
        <?php
        $stages = [
            ['key' => 'MENUNGGU_KONFIRMASI', 'title' => 'Permintaan Dikirim', 'icon' => 'fa-paper-plane'],
            ['key' => 'DRIVER_DITUGASKAN', 'title' => 'Picker Ditugaskan', 'icon' => 'fa-user-check'],
            ['key' => 'DRIVER_MENUJU_LOKASI', 'title' => 'Dalam Perjalanan', 'icon' => 'fa-truck-loading'],
            ['key' => 'DRIVER_TIBA', 'title' => 'Picker Sudah Dekat', 'icon' => 'fa-map-marker-alt'],
            ['key' => 'SAMPAH_DIJEMPUT', 'title' => 'Sampah Dijemput', 'icon' => 'fa-weight-hanging'],
            ['key' => 'VALIDASI_BANK_SAMPAH', 'title' => 'Waiting Validation', 'icon' => 'fa-hourglass-half'],
            ['key' => 'SELESAI', 'title' => 'Completed', 'icon' => 'fa-check-double']
        ];
        
        // Find current stage index
        $current_stage_idx = 0;
        foreach ($stages as $idx => $stage) {
            if ($status === $stage['key']) {
                $current_stage_idx = $idx;
                break;
            }
        }
        if ($status === 'SELESAI') $current_stage_idx = 6;
        if ($status === 'DIBATALKAN') $current_stage_idx = -1; // Special canceled stage
        ?>

        <div class="grid grid-cols-2 sm:grid-cols-4 lg:grid-cols-7 gap-4">
            <?php foreach ($stages as $idx => $stage): 
                $is_done = ($current_stage_idx >= $idx && $status !== 'DIBATALKAN');
                $is_active = ($current_stage_idx === $idx && $status !== 'DIBATALKAN');
                
                $box_class = ($is_active && $stage['key'] === 'DRIVER_TIBA') ? 'bg-emerald-600 text-white shadow' : ($is_active ? 'bg-sky-500 text-white shadow' : ($is_done ? 'bg-emerald-100 text-emerald-800' : 'bg-gray-50 text-gray-400'));
                $border_class = ($is_active && $stage['key'] === 'DRIVER_TIBA') ? 'border-emerald-700' : ($is_active ? 'border-sky-600' : ($is_done ? 'border-emerald-300' : 'border-gray-200'));
            ?>
            <div class="flex flex-col items-center p-3 rounded-lg border text-center transition-all <?php echo $box_class . ' ' . $border_class; ?>">
                <i class="fas <?php echo $stage['icon']; ?> text-xl mb-2"></i>
                <span class="text-xs font-bold leading-tight"><?php echo $stage['title']; ?></span>
            </div>
            <?php endforeach; ?>
        </div>
        
        <?php if ($status === 'DIBATALKAN'): ?>
            <div class="mt-4 p-3 bg-red-50 text-red-800 rounded-lg border border-red-200 text-sm font-semibold flex items-center gap-2">
                <i class="fas fa-times-circle text-lg"></i>
                <span>Order ini telah dibatalkan (Canceled). Proses terhenti.</span>
            </div>
        <?php endif; ?>
    </div>

    <form method="POST" action="" class="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <!-- Left 2 Cols: Order Items & Points -->
        <div class="lg:col-span-2 space-y-6">
            <!-- Order Information -->
            <div class="bg-white rounded-xl shadow p-6 border border-gray-100">
                <h2 class="text-lg font-bold text-gray-800 border-b pb-2 mb-4">Detail Pengiriman & Deteksi Sampah</h2>
                
                <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-4">
                    <div>
                        <span class="text-xs text-gray-500 block">Tanggal Penjemputan</span>
                        <span class="text-sm font-semibold text-gray-800"><?php echo date('d M Y', strtotime($order['tanggal_order'])); ?></span>
                    </div>
                    <div>
                        <span class="text-xs text-gray-500 block">Jadwal Waktu</span>
                        <span class="text-sm font-semibold text-gray-800">
                            <?php echo $order['waktu_jemput_dari'] ? substr($order['waktu_jemput_dari'], 0, 5) . ' - ' . substr($order['waktu_jemput_sampai'], 0, 5) : '-'; ?>
                        </span>
                    </div>
                    <div>
                        <span class="text-xs text-gray-500 block">Tanggal Validasi</span>
                        <span class="text-sm font-semibold text-gray-800">
                            <?php echo ($order['updated_at'] && $status === 'SELESAI') ? date('d M Y H:i', strtotime($order['updated_at'])) : '-'; ?>
                        </span>
                    </div>
                </div>

                <!-- Trash Items Table -->
                <div class="overflow-x-auto">
                    <table class="min-w-full divide-y divide-gray-200">
                        <thead class="bg-gray-50">
                            <tr>
                                <th scope="col" class="px-4 py-2 text-left text-xs font-semibold text-gray-600 uppercase">Kategori Sampah</th>
                                <th scope="col" class="px-4 py-2 text-center text-xs font-semibold text-gray-600 uppercase">Estimasi Berat</th>
                                <th scope="col" class="px-4 py-2 text-center text-xs font-semibold text-gray-600 uppercase">Berat Timbangan Aktual *</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-200 bg-white">
                            <?php foreach ($items as $item): ?>
                            <tr>
                                <td class="px-4 py-3">
                                    <?php if ($is_editable): ?>
                                        <select name="items[<?php echo $item['id_order_item']; ?>][id_jenis_sampah]" 
                                                class="w-full text-sm border-gray-300 rounded-md shadow-sm focus:border-sky-500 focus:ring-sky-500 block item-category"
                                                data-price="<?php echo $item['harga_per_kg']; ?>">
                                            <?php foreach ($categories as $cat): ?>
                                                <option value="<?php echo $cat['id_jenis_sampah']; ?>" 
                                                        data-price="<?php echo $cat['harga_per_kg']; ?>"
                                                        <?php echo $item['id_jenis_sampah'] == $cat['id_jenis_sampah'] ? 'selected' : ''; ?>>
                                                    <?php echo htmlspecialchars($cat['nama_sampah']); ?> (Rp <?php echo number_format($cat['harga_per_kg']); ?>/kg)
                                                </option>
                                            <?php endforeach; ?>
                                        </select>
                                    <?php else: ?>
                                        <span class="text-sm font-semibold text-gray-800"><?php echo htmlspecialchars($item['nama_sampah']); ?></span>
                                        <span class="text-xs text-gray-500 block">(Rp <?php echo number_format($item['harga_per_kg']); ?>/kg)</span>
                                    <?php endif; ?>
                                </td>
                                <td class="px-4 py-3 text-center">
                                    <span class="text-sm font-semibold text-gray-600"><?php echo $item['estimasi_berat_kg']; ?> kg</span>
                                </td>
                                <td class="px-4 py-3">
                                    <?php if ($is_editable): ?>
                                        <div class="flex items-center justify-center">
                                            <input type="number" step="0.01" min="0" required
                                                   name="items[<?php echo $item['id_order_item']; ?>][berat_aktual_kg]"
                                                   value="<?php echo htmlspecialchars($item['berat_aktual_kg'] ?? $item['estimasi_berat_kg']); ?>"
                                                   class="w-24 text-center border-gray-300 rounded-md shadow-sm focus:border-sky-500 focus:ring-sky-500 text-sm font-bold text-gray-800 item-weight">
                                            <span class="ml-2 text-sm text-gray-500">kg</span>
                                        </div>
                                    <?php else: ?>
                                        <div class="text-center">
                                            <span class="text-sm font-extrabold text-emerald-600"><?php echo $item['berat_aktual_kg'] ?? '-'; ?> kg</span>
                                        </div>
                                    <?php endif; ?>
                                </td>
                            </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Points calculation card -->
            <div class="bg-white rounded-xl shadow p-6 border border-gray-100">
                <h2 class="text-lg font-bold text-gray-800 border-b pb-2 mb-4">Kalkulasi Poin & Nominal Uang</h2>
                
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6 items-center">
                    <div>
                        <div class="mb-4">
                            <span class="text-xs text-gray-500 block">Estimasi Poin Asal</span>
                            <span class="text-base font-bold text-gray-700"><?php echo number_format($order['estimasi_poin']); ?> pts</span>
                        </div>
                        <div>
                            <span class="text-xs text-gray-500 block mb-1">Detail Kalkulasi Poin (Berat × Poin/Kg)</span>
                            <div id="suggested-points-calculation" class="text-xs text-gray-600 font-mono bg-gray-50 p-2.5 rounded-lg border border-gray-200 space-y-1 mb-2">
                                Mengkalkulasi...
                            </div>
                            <span class="text-xs text-gray-500 block">Saran Total Poin</span>
                            <span id="suggested-points" class="text-sm font-bold text-sky-600">Mengkalkulasi...</span>
                        </div>
                    </div>
                    
                    <div class="bg-sky-50 p-4 rounded-xl border border-sky-100 flex flex-col justify-center items-center">
                        <label for="poin_final" class="block text-xs font-bold text-sky-800 uppercase mb-2">Poin Akhir Terpakai *</label>
                        <?php if ($is_editable): ?>
                            <input type="number" id="poin_final" name="poin_final" required min="0"
                                   value="<?php echo htmlspecialchars($order['estimasi_poin']); ?>"
                                   class="w-32 text-center border-sky-300 rounded-md shadow-sm focus:border-sky-500 focus:ring-sky-500 text-2xl font-black text-sky-800 bg-white">
                            <span id="rp-conversion" class="text-xs text-sky-600 font-semibold mt-2">Setara: Rp 0</span>
                        <?php else: ?>
                            <span class="text-3xl font-black text-sky-800"><?php echo number_format($order['estimasi_poin']); ?> pts</span>
                            <span class="text-sm text-sky-600 font-semibold mt-1">Setara: Rp <?php echo number_format($order['estimasi_poin'] * 1000, 0, ',', '.'); ?></span>
                        <?php endif; ?>
                    </div>
                </div>
            </div>

            <!-- AI Detection Cards -->
            <div class="bg-white rounded-xl shadow p-6 border border-gray-100">
                <h2 class="text-lg font-bold text-gray-800 border-b pb-2 mb-4">Hasil Scan AI Penyetor (Terbaru)</h2>
                <?php if (empty($ai_detections)): ?>
                    <p class="text-sm text-gray-500 italic">Belum ada data scan AI yang diupload oleh penyetor ini.</p>
                <?php else: ?>
                    <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
                        <?php foreach ($ai_detections as $ai): 
                            $labels = json_decode($ai['labels_json'], true) ?: [];
                        ?>
                        <div class="border rounded-lg overflow-hidden flex flex-col bg-gray-50">
                            <img src="<?php echo BASE_URL . $ai['uploaded_file']; ?>" class="h-28 w-full object-cover">
                            <div class="p-2 text-xs flex-1">
                                <span class="text-[10px] text-gray-400 block mb-1"><?php echo date('d M H:i', strtotime($ai['created_at'])); ?></span>
                                <div class="space-y-1">
                                    <?php foreach (array_slice($labels, 0, 3) as $lbl): ?>
                                        <span class="inline-block bg-sky-100 text-sky-800 px-1.5 py-0.5 rounded text-[10px] font-bold">
                                            <?php echo htmlspecialchars($lbl['label'] ?? $lbl); ?> (<?php echo round(($lbl['confidence'] ?? 1.0) * 100); ?>%)
                                        </span>
                                    <?php endforeach; ?>
                                </div>
                            </div>
                        </div>
                        <?php endforeach; ?>
                    </div>
                <?php endif; ?>
            </div>
        </div>

        <!-- Right 1 Col: User Profiles & Actions -->
        <div class="space-y-6">
            <!-- Citizens Detail Card -->
            <div class="bg-white rounded-xl shadow p-6 border border-gray-100">
                <h3 class="text-md font-bold text-gray-800 border-b pb-2 mb-3">Informasi Penyetor</h3>
                <div class="flex items-center gap-3 mb-4">
                    <img class="h-10 w-10 rounded-full object-cover border" 
                         src="<?php echo BASE_URL . 'assets/uploads/' . (!empty($order['foto_warga']) ? $order['foto_warga'] : 'default_avatar.png'); ?>">
                    <div>
                        <span class="font-bold text-gray-800 block text-sm"><?php echo htmlspecialchars($order['nama_warga']); ?></span>
                        <span class="text-xs text-gray-500">@<?php echo htmlspecialchars($order['username_warga']); ?></span>
                    </div>
                </div>
                <div class="space-y-2 text-sm">
                    <div>
                        <span class="text-xs text-gray-400 block">Kontak Penyetor</span>
                        <span class="font-semibold text-gray-800"><?php echo htmlspecialchars($order['telp_warga'] ?? '-'); ?></span>
                        <span class="text-xs text-gray-500 block"><?php echo htmlspecialchars($order['email_warga'] ?? ''); ?></span>
                    </div>
                    <div>
                        <span class="text-xs text-gray-400 block">Alamat Penjemputan</span>
                        <span class="text-xs font-semibold text-gray-700"><?php echo htmlspecialchars($order['alamat_jemput']); ?></span>
                    </div>
                </div>
            </div>

            <!-- Picker Detail Card -->
            <div class="bg-white rounded-xl shadow p-6 border border-gray-100">
                <h3 class="text-md font-bold text-gray-800 border-b pb-2 mb-3">Informasi Picker</h3>
                <?php if ($order['nama_driver']): ?>
                <div class="flex items-center gap-3 mb-4">
                    <img class="h-10 w-10 rounded-full object-cover border" 
                         src="<?php echo BASE_URL . 'assets/uploads/' . (!empty($order['foto_driver']) ? $order['foto_driver'] : 'default_avatar.png'); ?>">
                    <div>
                        <span class="font-bold text-gray-800 block text-sm"><?php echo htmlspecialchars($order['nama_driver']); ?></span>
                        <span class="text-xs text-gray-500">Petugas Picker</span>
                    </div>
                </div>
                <div class="space-y-2 text-sm">
                    <div>
                        <span class="text-xs text-gray-400 block">Kontak Picker</span>
                        <span class="font-semibold text-gray-800"><?php echo htmlspecialchars($order['telp_driver'] ?? '-'); ?></span>
                    </div>
                    <div>
                        <span class="text-xs text-gray-400 block">Detail Kendaraan</span>
                        <span class="font-semibold text-gray-800">
                            <?php 
                            if (!empty($order['daily_vehicle_type'])) {
                                echo htmlspecialchars($order['daily_vehicle_type'] . " [" . $order['daily_license_plate'] . "]");
                            } else {
                                echo "-";
                            }
                            ?>
                        </span>
                    </div>
                </div>
                <?php else: ?>
                <p class="text-sm text-gray-500 italic">Belum ditugaskan picker.</p>
                <?php endif; ?>
            </div>

            <!-- Form Actions -->
            <div class="bg-white rounded-xl shadow p-6 border border-gray-100 text-center">
                <h3 class="text-md font-bold text-gray-800 border-b pb-2 mb-4">Aksi Validasi</h3>
                
                <?php if ($is_editable): ?>
                    <div class="space-y-3">
                        <button type="submit" name="action_approve" class="w-full bg-emerald-600 hover:bg-emerald-700 text-white font-bold py-2.5 px-4 rounded-lg shadow transition-colors flex items-center justify-center gap-2">
                            <i class="fas fa-check-circle"></i> Approve & Kirim Poin
                        </button>
                        <div class="grid grid-cols-2 gap-2">
                            <button type="submit" name="action_save" class="bg-sky-600 hover:bg-sky-700 text-white font-semibold py-2 px-3 rounded-lg shadow text-xs transition-colors flex items-center justify-center gap-1">
                                <i class="fas fa-save"></i> Simpan
                            </button>
                            <button type="button" id="btn_reject" class="bg-red-600 hover:bg-red-700 text-white font-semibold py-2 px-3 rounded-lg shadow text-xs transition-colors flex items-center justify-center gap-1">
                                <i class="fas fa-times-circle"></i> Batalkan
                            </button>
                        </div>
                    </div>
                <?php else: ?>
                    <p class="text-sm text-gray-500">Order ini sudah selesai divalidasi dan tidak dapat diubah kembali.</p>
                <?php endif; ?>
            </div>
        </div>
    </form>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const poinInput = document.getElementById('poin_final');
    const rpConversion = document.getElementById('rp-conversion');
    const suggestedPoints = document.getElementById('suggested-points');
    const calcDiv = document.getElementById('suggested-points-calculation');

    function recalculateSuggestion() {
        let totalPoints = 0;
        let breakdownHTML = '';
        
        const rows = document.querySelectorAll('tbody tr');
        rows.forEach((row) => {
            const selectEl = row.querySelector('.item-category');
            const weightInput = row.querySelector('.item-weight');
            
            let catName = '';
            let pricePerKg = 0;
            let weight = 0;
            
            if (selectEl) {
                const selectedOpt = selectEl.options[selectEl.selectedIndex];
                catName = selectedOpt.text.split(' (')[0];
                pricePerKg = parseFloat(selectedOpt.getAttribute('data-price')) || 0;
            } else {
                const nameEl = row.querySelector('.font-semibold');
                if (nameEl) catName = nameEl.textContent.trim();
                const priceText = row.querySelector('.text-xs')?.textContent || '';
                const match = priceText.match(/Rp\s*([\d,.]+)/);
                if (match) {
                    pricePerKg = parseFloat(match[1].replace(/[.,]/g, '')) || 0;
                }
            }
            
            if (weightInput) {
                weight = parseFloat(weightInput.value) || 0;
            } else {
                const wtEl = row.querySelector('.text-emerald-600');
                if (wtEl) weight = parseFloat(wtEl.textContent) || 0;
            }
            
            const pointsPerKg = pricePerKg / 1000;
            const rowPoints = weight * pointsPerKg;
            totalPoints += rowPoints;
            
            breakdownHTML += `<div>• ${catName}: ${weight} kg × ${pointsPerKg.toFixed(2)} pts/kg = ${rowPoints.toFixed(2)} pts</div>`;
        });
        
        const finalSuggested = Math.round(totalPoints);
        
        if (calcDiv) {
            calcDiv.innerHTML = breakdownHTML + `<div class="mt-1 font-bold border-t pt-1 border-gray-200">Total: ${totalPoints.toFixed(2)} pts (dibulatkan: ${finalSuggested} pts)</div>`;
        }
        
        if (suggestedPoints) {
            suggestedPoints.textContent = finalSuggested + " pts";
        }
        
        if (poinInput && !poinInput.classList.contains('user-modified')) {
            poinInput.value = finalSuggested;
            updateRpConversion(finalSuggested);
        }
    }

    function updateRpConversion(points) {
        if (rpConversion) {
            const rp = points * 1000;
            rpConversion.textContent = "Setara: Rp " + rp.toLocaleString('id-ID');
        }
    }

    if (poinInput) {
        poinInput.addEventListener('input', function() {
            poinInput.classList.add('user-modified');
            updateRpConversion(parseInt(poinInput.value) || 0);
        });
        
        updateRpConversion(parseInt(poinInput.value) || 0);
    }

    const weightInputs = document.querySelectorAll('.item-weight');
    weightInputs.forEach(input => {
        input.addEventListener('input', recalculateSuggestion);
    });

    const categorySelects = document.querySelectorAll('.item-category');
    categorySelects.forEach(select => {
        select.addEventListener('change', recalculateSuggestion);
    });

    const btnReject = document.getElementById('btn_reject');
    if (btnReject) {
        btnReject.addEventListener('click', function(e) {
            e.preventDefault();
            const reason = prompt('Masukkan alasan pembatalan/penolakan order ini:');
            if (reason === null) return; 
            if (reason.trim() === '') {
                alert('Alasan pembatalan wajib diisi.');
                return;
            }
            const form = this.closest('form');
            if (form) {
                const inputReason = document.createElement('input');
                inputReason.type = 'hidden';
                inputReason.name = 'rejection_reason';
                inputReason.value = reason;
                form.appendChild(inputReason);
                
                const inputAction = document.createElement('input');
                inputAction.type = 'hidden';
                inputAction.name = 'action_reject';
                inputAction.value = '1';
                form.appendChild(inputAction);
                
                form.submit();
            }
        });
    }

    recalculateSuggestion();
});
</script>
