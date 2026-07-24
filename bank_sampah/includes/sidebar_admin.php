<?php
// includes/sidebar_admin.php
// Pastikan $current_page sudah didefinisikan di header.php
$current_page = isset($current_page) ? $current_page : (isset($_GET['page']) ? $_GET['page'] : '');
?>
<ul class="space-y-2">
    <li>
        <a href="<?php echo BASE_URL; ?>index.php?page=dashboard" 
           class="flex items-center space-x-3 px-4 py-3 rounded-lg hover:bg-sky-600 transition duration-200 <?php echo ($current_page == 'dashboard') ? 'active-nav-link' : ''; ?>">
            <i class="fas fa-tachometer-alt w-5"></i>
            <span>Dashboard</span>
        </a>
    </li>
    <li>
        <a href="<?php echo BASE_URL; ?>index.php?page=monitor_ai/index" 
           class="flex items-center space-x-3 px-4 py-3 rounded-lg hover:bg-sky-600 transition duration-200 <?php echo (strpos($current_page, 'monitor_ai/') === 0) ? 'active-nav-link' : ''; ?>">
            <i class="fas fa-camera-retro w-5"></i>
            <span>Monitor AI Scan</span>
            <span class="ml-auto inline-block px-2 py-0.5 bg-red-500 text-white text-xs font-bold rounded-full animate-pulse">LIVE</span>
        </a>
    </li>
    <li>
        <a href="<?php echo BASE_URL; ?>index.php?page=edukasi/data" 
           class="flex items-center space-x-3 px-4 py-3 rounded-lg hover:bg-sky-600 transition duration-200 <?php echo (strpos($current_page, 'edukasi/') === 0) ? 'active-nav-link' : ''; ?>">
            <i class="fas fa-book-open w-5"></i>
            <span>Edukasi</span>
        </a>
    </li>
    <li>
        <a href="<?php echo BASE_URL; ?>index.php?page=penyetor/data" 
           class="flex items-center space-x-3 px-4 py-3 rounded-lg hover:bg-sky-600 transition duration-200 <?php echo (strpos($current_page, 'penyetor/') === 0) ? 'active-nav-link' : ''; ?>">
            <i class="fas fa-users w-5"></i>
            <span>Data Penyetor</span>
        </a>
    </li>
    <li>
        <a href="<?php echo BASE_URL; ?>index.php?page=picker/data" 
           class="flex items-center space-x-3 px-4 py-3 rounded-lg hover:bg-sky-600 transition duration-200 <?php echo (strpos($current_page, 'picker/') === 0) ? 'active-nav-link' : ''; ?>">
            <i class="fas fa-id-card w-5"></i>
            <span>Data Picker</span>
        </a>
    </li>
    <li>
        <a href="<?php echo BASE_URL; ?>index.php?page=jenis_sampah/data" 
           class="flex items-center space-x-3 px-4 py-3 rounded-lg hover:bg-sky-600 transition duration-200 <?php echo (strpos($current_page, 'jenis_sampah/') === 0) ? 'active-nav-link' : ''; ?>">
            <i class="fas fa-dumpster w-5"></i>
            <span>Jenis Sampah</span>
        </a>
    </li>
    <li>
        <a href="<?php echo BASE_URL; ?>index.php?page=orders/data" 
           class="flex items-center space-x-3 px-4 py-3 rounded-lg hover:bg-sky-600 transition duration-200 <?php echo (strpos($current_page, 'orders/') === 0) ? 'active-nav-link' : ''; ?>">
            <i class="fas fa-truck w-5"></i>
            <span>Orders Penjemputan</span>
        </a>
    </li>
    <li>
        <a href="<?php echo BASE_URL; ?>index.php?page=reward/index" 
           class="flex items-center space-x-3 px-4 py-3 rounded-lg hover:bg-sky-600 transition duration-200 <?php echo (strpos($current_page, 'reward/') === 0) ? 'active-nav-link' : ''; ?>">
            <i class="fas fa-gift w-5"></i>
            <span>Tukar Poin</span>
            <?php
            $q_pending = @mysqli_query($koneksi, "SELECT COUNT(*) as jml FROM reward_redemptions WHERE status = 'pending'");
            if ($q_pending) {
                $r_p = mysqli_fetch_assoc($q_pending);
                if ($r_p && $r_p['jml'] > 0) {
                    echo '<span class="ml-auto inline-block px-2 py-0.5 bg-amber-500 text-white text-xs font-bold rounded-full">' . $r_p['jml'] . '</span>';
                }
            }
            ?>
        </a>
    </li>
    <li x-data="{ open: <?php echo (strpos($current_page, 'transaksi/') === 0) ? 'true' : 'false'; ?> }" @dropdown-opened.window="if ($event.detail !== 'transaksi') open = false">
            <button type="button" @click="open = !open; if (open) $dispatch('dropdown-opened', 'transaksi')" class="w-full flex items-center justify-between space-x-3 px-4 py-3 rounded-lg hover:bg-sky-600 transition duration-200">
            <div class="flex items-center space-x-3">
                <i class="fas fa-history w-5"></i>
                <span>Transaksi</span>
            </div>
            <i class="fas transition-transform duration-300" :class="open ? 'fa-chevron-down rotate-180' : 'fa-chevron-down'"></i>
        </button>
        <ul class="ml-4 mt-1 space-y-1 overflow-hidden transition-all duration-300 ease-in-out" :style="open ? 'max-height: 140px; opacity: 1;' : 'max-height: 0px; opacity: 0;'">
            <li>
                <a href="<?php echo BASE_URL; ?>index.php?page=transaksi/riwayat&filter_tipe=setor" 
                   class="block px-4 py-2 rounded-md hover:bg-sky-700 <?php echo ($current_page == 'transaksi/riwayat' && isset($_GET['filter_tipe']) && $_GET['filter_tipe']=='setor') ? 'active-nav-link' : ''; ?>">Riwayat Setor</a>
            </li>
            <li>
                <a href="<?php echo BASE_URL; ?>index.php?page=transaksi/riwayat&filter_tipe=tarik_saldo" 
                   class="block px-4 py-2 rounded-md hover:bg-sky-700 <?php echo ($current_page == 'transaksi/riwayat' && isset($_GET['filter_tipe']) && $_GET['filter_tipe']=='tarik_saldo') ? 'active-nav-link' : ''; ?>">Riwayat Tarik/Transfer</a>
            </li>
        </ul>
    </li>
    <li x-data="{ open: <?php echo (strpos($current_page, 'laporan/') === 0) ? 'true' : 'false'; ?> }" @dropdown-opened.window="if ($event.detail !== 'laporan') open = false">
        <button type="button" @click="open = !open; if (open) $dispatch('dropdown-opened', 'laporan')" class="w-full flex items-center justify-between space-x-3 px-4 py-3 rounded-lg hover:bg-sky-600 transition duration-200">
            <div class="flex items-center space-x-3">
                <i class="fas fa-chart-line w-5"></i>
                <span>Laporan</span>
            </div>
            <i class="fas transition-transform duration-300" :class="open ? 'fa-chevron-down rotate-180' : 'fa-chevron-down'"></i>
        </button>
        <ul class="ml-4 mt-1 space-y-1 overflow-hidden transition-all duration-300 ease-in-out" :style="open ? 'max-height: 140px; opacity: 1;' : 'max-height: 0px; opacity: 0;'">
            <li>
                <a href="<?php echo BASE_URL; ?>index.php?page=laporan/harian" 
                   class="block px-4 py-2 rounded-md hover:bg-sky-700 <?php echo ($current_page == 'laporan/harian') ? 'active-nav-link' : ''; ?>">Laporan Harian</a>
            </li>
            <li>
                <a href="<?php echo BASE_URL; ?>index.php?page=laporan/bulanan" 
                   class="block px-4 py-2 rounded-md hover:bg-sky-700 <?php echo ($current_page == 'laporan/bulanan') ? 'active-nav-link' : ''; ?>">Laporan Bulanan</a>
            </li>
        </ul>
    </li>
    </ul>
