<?php
// modules/dashboard/index.php
check_user_level(['admin']); // Hanya admin yang akses dashboard ini

$user_id = $_SESSION['user_id'];
$user_level = $_SESSION['user_level'];
$user_nama = $_SESSION['user_nama'];

// Data default
$jumlah_warga = 0;
$jumlah_jenis_sampah = 0;
$total_berat_setoran_bulan_ini = 0;
$total_saldo_bank_sampah = 0; 
$aktivitas_terbaru = [];

if ($user_level == 'admin' || $user_level == 'petugas') {
    // Ambil data untuk Admin/Petugas
    // Jumlah Warga
    $query_warga = "SELECT COUNT(*) AS total FROM pengguna WHERE level = 'warga'";
    $result_warga = mysqli_query($koneksi, $query_warga);
    if($result_warga) $jumlah_warga = mysqli_fetch_assoc($result_warga)['total'];

    // Jumlah Jenis Sampah
    $query_jenis = "SELECT COUNT(*) AS total FROM jenis_sampah";
    $result_jenis = mysqli_query($koneksi, $query_jenis);
    if($result_jenis) $jumlah_jenis_sampah = mysqli_fetch_assoc($result_jenis)['total'];

    // Total Berat Setoran Bulan Ini
    $bulan_ini_awal = date('Y-m-01 00:00:00');
    $bulan_ini_akhir = date('Y-m-t 23:59:59');
    $query_berat = "SELECT SUM(ds.berat_kg) AS total_berat 
                    FROM detail_setoran ds
                    JOIN transaksi t ON ds.id_transaksi_setor = t.id_transaksi
                    WHERE t.tanggal_transaksi BETWEEN ? AND ?";
    $stmt_berat = mysqli_prepare($koneksi, $query_berat);
    mysqli_stmt_bind_param($stmt_berat, "ss", $bulan_ini_awal, $bulan_ini_akhir);
    mysqli_stmt_execute($stmt_berat);
    $result_berat = mysqli_stmt_get_result($stmt_berat);
    if($result_berat) {
        $data_berat = mysqli_fetch_assoc($result_berat);
        $total_berat_setoran_bulan_ini = $data_berat['total_berat'] ? $data_berat['total_berat'] : 0;
    }
    mysqli_stmt_close($stmt_berat);
    
    // Total Saldo Bank Sampah (akumulasi saldo semua warga)
    $query_saldo_total = "SELECT SUM(saldo) AS total_saldo FROM pengguna WHERE level = 'warga'";
    $result_saldo_total = mysqli_query($koneksi, $query_saldo_total);
    if($result_saldo_total) $total_saldo_bank_sampah = mysqli_fetch_assoc($result_saldo_total)['total_saldo'] ?: 0;

    // Aktivitas Terbaru (5 transaksi terakhir)
    $query_aktivitas = "
        (
            SELECT 
                'transaksi' as activity_type,
                t.tanggal_transaksi as activity_date,
                t.id_transaksi as id,
                t.tipe_transaksi as action_type,
                t.total_nilai as amount,
                warga.nama_lengkap as nama_warga,
                petugas.nama_lengkap as nama_petugas
            FROM transaksi t
            JOIN pengguna warga ON t.id_warga = warga.id_pengguna
            JOIN pengguna petugas ON t.id_petugas_pencatat = petugas.id_pengguna
        )
        UNION ALL
        (
            SELECT 
                'order' as activity_type,
                o.created_at as activity_date,
                o.id_order as id,
                o.status as action_type,
                0 as amount,
                warga.nama_lengkap as nama_warga,
                NULL as nama_petugas
            FROM orders o
            JOIN pengguna warga ON o.id_warga = warga.id_pengguna
        )
        UNION ALL
        (
            SELECT 
                'register' as activity_type,
                p.tanggal_daftar as activity_date,
                p.id_pengguna as id,
                p.level as action_type,
                0 as amount,
                p.nama_lengkap as nama_warga,
                NULL as nama_petugas
            FROM pengguna p
            WHERE p.level = 'warga'
        )
        ORDER BY activity_date DESC
        LIMIT 5
    ";
    $result_aktivitas = mysqli_query($koneksi, $query_aktivitas);
    if($result_aktivitas){
        while($row = mysqli_fetch_assoc($result_aktivitas)){
            $aktivitas_terbaru[] = $row;
        }
    }

    // --- Data Orders Penjemputan (dari Mobile & Driver) ---
    $total_orders = 0;
    $orders_pending = 0;
    $orders_completed = 0;
    $jumlah_driver = 0;

    // Cek apakah tabel orders ada
    $tbl_check = mysqli_query($koneksi, "SELECT COUNT(*) as cnt FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'orders'");
    $tbl_exists = false;
    if ($tbl_check) {
        $tbl_row = mysqli_fetch_assoc($tbl_check);
        $tbl_exists = ($tbl_row['cnt'] > 0);
    }

    if ($tbl_exists) {
        $q = mysqli_query($koneksi, "SELECT COUNT(*) as total FROM orders");
        if ($q) $total_orders = (int)mysqli_fetch_assoc($q)['total'];

        $q = mysqli_query($koneksi, "SELECT COUNT(*) as total FROM orders WHERE status = 'pending'");
        if ($q) $orders_pending = (int)mysqli_fetch_assoc($q)['total'];

        $q = mysqli_query($koneksi, "SELECT COUNT(*) as total FROM orders WHERE status = 'completed'");
        if ($q) $orders_completed = (int)mysqli_fetch_assoc($q)['total'];
    }

    $q = mysqli_query($koneksi, "SELECT COUNT(*) as total FROM pengguna WHERE level = 'driver'");
    if ($q) $jumlah_driver = (int)mysqli_fetch_assoc($q)['total'];
}

// Karena warga tidak lagi login ke dashboard ini, bagian elseif ($user_level == 'warga') bisa dihapus.
// Kode di bawah ini khusus untuk admin dan petugas.

?>

<div class="container mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <h1 class="text-3xl md:text-4xl font-bold text-gray-800 mb-8">Dashboard Utama</h1>

    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 mb-10">

        <!-- Jumlah Warga -->
        <a href="<?php echo BASE_URL; ?>index.php?page=warga/data"
           class="block bg-gradient-to-br from-sky-500 to-sky-600 p-6 rounded-xl shadow-lg text-white transform hover:scale-105 transition-transform duration-300">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-sm font-medium uppercase tracking-wider opacity-80">Jumlah Warga</p>
                    <p class="text-4xl font-extrabold"><?php echo $jumlah_warga; ?></p>
                </div>
                <i class="fas fa-users fa-3x opacity-50"></i>
            </div>
        </a>

        <!-- Jenis Sampah -->
        <a href="<?php echo BASE_URL; ?>index.php?page=jenis_sampah/data"
           class="block bg-gradient-to-br from-amber-500 to-amber-600 p-6 rounded-xl shadow-lg text-white transform hover:scale-105 transition-transform duration-300">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-sm font-medium uppercase tracking-wider opacity-80">Jenis Sampah</p>
                    <p class="text-4xl font-extrabold"><?php echo $jumlah_jenis_sampah; ?></p>
                </div>
                <i class="fas fa-dumpster fa-3x opacity-50"></i>
            </div>
        </a>

        <!-- Setoran Bulan Ini -->
        <a href="<?php echo BASE_URL; ?>index.php?page=transaksi/riwayat"
           class="block bg-gradient-to-br from-purple-500 to-purple-600 p-6 rounded-xl shadow-lg text-white transform hover:scale-105 transition-transform duration-300">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-sm font-medium uppercase tracking-wider opacity-80">Setoran Bulan Ini</p>
                    <p class="text-3xl font-extrabold"><?php echo number_format($total_berat_setoran_bulan_ini, 2, ',', '.'); ?> Kg</p>
                </div>
                <i class="fas fa-weight-hanging fa-3x opacity-50"></i>
            </div>
        </a>

        <!-- Total Saldo Bank -->
        <a href="<?php echo BASE_URL; ?>index.php?page=laporan/bulanan"
           class="block bg-gradient-to-br from-emerald-500 to-emerald-600 p-6 rounded-xl shadow-lg text-white transform hover:scale-105 transition-transform duration-300">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-sm font-medium uppercase tracking-wider opacity-80">Total Saldo Bank</p>
                    <p class="text-3xl font-extrabold"><?php echo format_rupiah($total_saldo_bank_sampah); ?></p>
                </div>
                <i class="fas fa-wallet fa-3x opacity-50"></i>
            </div>
        </a>

    </div>

    <!-- Row 2: Orders & Driver Stats -->
    <div class="grid grid-cols-1 sm:grid-cols-3 gap-6 mb-10">
        <a href="<?php echo BASE_URL; ?>index.php?page=orders/data"
           class="block bg-gradient-to-br from-rose-500 to-rose-600 p-6 rounded-xl shadow-lg text-white transform hover:scale-105 transition-transform duration-300">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-sm font-medium uppercase tracking-wider opacity-80">Orders Pending</p>
                    <p class="text-4xl font-extrabold"><?php echo isset($orders_pending) ? $orders_pending : 0; ?></p>
                </div>
                <i class="fas fa-truck fa-3x opacity-50"></i>
            </div>
        </a>
        <a href="<?php echo BASE_URL; ?>index.php?page=orders/data"
           class="block bg-gradient-to-br from-teal-500 to-teal-600 p-6 rounded-xl shadow-lg text-white transform hover:scale-105 transition-transform duration-300">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-sm font-medium uppercase tracking-wider opacity-80">Orders Selesai</p>
                    <p class="text-4xl font-extrabold"><?php echo isset($orders_completed) ? $orders_completed : 0; ?></p>
                </div>
                <i class="fas fa-check-circle fa-3x opacity-50"></i>
            </div>
        </a>
        <div class="block bg-gradient-to-br from-indigo-500 to-indigo-600 p-6 rounded-xl shadow-lg text-white">
            <div class="flex items-center justify-between">
                <div>
                    <p class="text-sm font-medium uppercase tracking-wider opacity-80">Jumlah Driver</p>
                    <p class="text-4xl font-extrabold"><?php echo isset($jumlah_driver) ? $jumlah_driver : 0; ?></p>
                </div>
                <i class="fas fa-motorcycle fa-3x opacity-50"></i>
            </div>
        </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <div class="lg:col-span-2 bg-white p-6 rounded-xl shadow-xl">
            <h2 class="text-xl font-semibold text-gray-700 mb-5 flex items-center">
                <i class="fas fa-stream mr-3 text-sky-500"></i>Aktivitas Transaksi Terbaru
            </h2>
            <?php if (!empty($aktivitas_terbaru)): ?>
                <div class="space-y-4">
                    <?php foreach($aktivitas_terbaru as $aktivitas): ?>
                        <div class="flex items-start space-x-3 p-3 border border-gray-200 rounded-lg hover:shadow-md transition-shadow duration-200">
                            <div class="flex-shrink-0 mt-1">
                                <?php if ($aktivitas['activity_type'] == 'transaksi' && $aktivitas['action_type'] == 'setor'): ?>
                                    <span class="w-8 h-8 bg-green-100 text-green-600 rounded-full flex items-center justify-center">
                                        <i class="fas fa-arrow-down"></i>
                                    </span>
                                <?php elseif ($aktivitas['activity_type'] == 'transaksi' && $aktivitas['action_type'] == 'tarik'): ?>
                                    <span class="w-8 h-8 bg-orange-100 text-orange-600 rounded-full flex items-center justify-center">
                                        <i class="fas fa-arrow-up"></i>
                                    </span>
                                <?php elseif ($aktivitas['activity_type'] == 'order'): ?>
                                    <span class="w-8 h-8 bg-blue-100 text-blue-600 rounded-full flex items-center justify-center">
                                        <i class="fas fa-truck"></i>
                                    </span>
                                <?php elseif ($aktivitas['activity_type'] == 'register'): ?>
                                    <span class="w-8 h-8 bg-purple-100 text-purple-600 rounded-full flex items-center justify-center">
                                        <i class="fas fa-user-plus"></i>
                                    </span>
                                <?php endif; ?>
                            </div>
                            <div>
                                <p class="text-sm font-medium text-gray-800">
                                    <?php if ($aktivitas['activity_type'] == 'transaksi'): ?>
                                        <?php echo ($aktivitas['action_type'] == 'setor' ? 'Setoran baru dari ' : 'Penarikan oleh '); ?>
                                        <span class="font-semibold text-sky-600"><?php echo htmlspecialchars($aktivitas['nama_warga']); ?></span>
                                        sebesar <span class="font-semibold"><?php echo format_rupiah($aktivitas['amount']); ?></span>.
                                    <?php elseif ($aktivitas['activity_type'] == 'order'): ?>
                                        Pengajuan penjemputan dari
                                        <span class="font-semibold text-sky-600"><?php echo htmlspecialchars($aktivitas['nama_warga']); ?></span>
                                        (Status: <span class="italic text-gray-500"><?php echo htmlspecialchars($aktivitas['action_type']); ?></span>).
                                    <?php elseif ($aktivitas['activity_type'] == 'register'): ?>
                                        Pendaftaran warga baru:
                                        <span class="font-semibold text-sky-600"><?php echo htmlspecialchars($aktivitas['nama_warga']); ?></span>.
                                    <?php endif; ?>
                                </p>
                                <p class="text-xs text-gray-500">
                                    <?php echo format_tanggal_indonesia($aktivitas['activity_date']); ?> 
                                    <?php if ($aktivitas['activity_type'] == 'transaksi' && !empty($aktivitas['nama_petugas'])): ?>
                                        - Dicatat oleh <?php echo htmlspecialchars($aktivitas['nama_petugas']); ?>
                                    <?php endif; ?>
                                </p>
                            </div>
                        </div>
                    <?php endforeach; ?>
                </div>
                 <div class="mt-6 text-right">
                    <a href="<?php echo BASE_URL; ?>index.php?page=transaksi/riwayat" class="text-sm font-medium text-sky-600 hover:text-sky-800 hover:underline transition">
                        Lihat Semua Riwayat <i class="fas fa-arrow-right ml-1"></i>
                    </a>
                </div>
            <?php else: ?>
                <div class="text-center py-8">
                    <i class="fas fa-folder-open fa-3x text-gray-300 mb-3"></i>
                    <p class="text-gray-500">Belum ada aktivitas transaksi terbaru.</p>
                </div>
            <?php endif; ?>
        </div>

        <div class="bg-white p-6 rounded-xl shadow-xl">
            <h2 class="text-xl font-semibold text-gray-700 mb-5 flex items-center">
                <i class="fas fa-bolt mr-3 text-sky-500"></i>Pintasan Cepat
            </h2>
            <div class="space-y-3">
                <a href="<?php echo BASE_URL; ?>index.php?page=transaksi/setor" class="flex items-center w-full text-left px-4 py-3 rounded-lg bg-green-500 text-white hover:bg-green-600 focus:bg-green-600 transition duration-200 shadow hover:shadow-lg transform hover:-translate-y-0.5">
                    <i class="fas fa-plus-circle fa-lg mr-3"></i> 
                    <div>
                        <span class="font-semibold">Input Setoran Sampah</span>
                        <p class="text-xs opacity-80">Catat setoran baru dari warga.</p>
                    </div>
                </a>
                <!-- Input Tarik Saldo removed (handled by users) -->
                <a href="<?php echo BASE_URL; ?>index.php?page=warga/tambah" class="flex items-center w-full text-left px-4 py-3 rounded-lg bg-sky-500 text-white hover:bg-sky-600 focus:bg-sky-600 transition duration-200 shadow hover:shadow-lg transform hover:-translate-y-0.5">
                    <i class="fas fa-user-plus fa-lg mr-3"></i> 
                    <div>
                        <span class="font-semibold">Tambah Warga Baru</span>
                        <p class="text-xs opacity-80">Daftarkan warga baru ke sistem.</p>
                    </div>
                </a>
                 <a href="<?php echo BASE_URL; ?>index.php?page=jenis_sampah/tambah" class="flex items-center w-full text-left px-4 py-3 rounded-lg bg-amber-500 text-white hover:bg-amber-600 focus:bg-amber-600 transition duration-200 shadow hover:shadow-lg transform hover:-translate-y-0.5">
                    <i class="fas fa-tag fa-lg mr-3"></i> 
                    <div>
                        <span class="font-semibold">Tambah Jenis Sampah</span>
                        <p class="text-xs opacity-80">Kelola daftar jenis sampah.</p>
                    </div>
                </a>
            </div>
        </div>
    </div>
</div>
