<?php
// includes/sidebar_warga.php
// Pastikan $current_page sudah didefinisikan di header.php
$current_page = isset($current_page) ? $current_page : (isset($_GET['page']) ? $_GET['page'] : '');
?>
<ul class="space-y-2">
    <li>
        <a href="<?php echo BASE_URL; ?>index.php?page=dashboard" 
           class="flex items-center space-x-3 px-4 py-3 rounded-lg hover:bg-sky-600 transition duration-200 <?php echo ($current_page == 'dashboard') ? 'active-nav-link' : ''; ?>">
            <i class="fas fa-home w-5"></i>
            <span>Dashboard Saya</span>
        </a>
    </li>
    <li>
        <a href="<?php echo BASE_URL; ?>index.php?page=edukasi/data" 
           class="flex items-center space-x-3 px-4 py-3 rounded-lg hover:bg-sky-600 transition duration-200 <?php echo (strpos($current_page, 'edukasi/') === 0) ? 'active-nav-link' : ''; ?>">
            <i class="fas fa-book-open w-5"></i>
            <span>Edukasi</span>
        </a>
    </li>
    <li x-data="{ open: <?php echo ($current_page == 'laporan/riwayat_warga') ? 'true' : 'false'; ?> }">
        <button @click="open = !open" class="w-full flex items-center justify-between space-x-3 px-4 py-3 rounded-lg hover:bg-sky-600 transition duration-200">
            <div class="flex items-center space-x-3">
                <i class="fas fa-history w-5"></i>
                <span>Riwayat Transaksi</span>
            </div>
            <i class="fas transition-transform duration-300" :class="open ? 'fa-chevron-down rotate-180' : 'fa-chevron-down'"></i>
        </button>
        <ul class="ml-4 mt-1 space-y-1 overflow-hidden transition-all duration-300 ease-in-out" :style="open ? 'max-height: 80px; opacity: 1;' : 'max-height: 0px; opacity: 0;'">
            <li>
                <a href="<?php echo BASE_URL; ?>index.php?page=laporan/riwayat_warga&filter_tipe=setor" 
                   class="block px-4 py-2 rounded-md hover:bg-sky-700 <?php echo ($current_page == 'laporan/riwayat_warga' && isset($_GET['filter_tipe']) && $_GET['filter_tipe']=='setor') ? 'active-nav-link' : ''; ?>">Riwayat Setor</a>
            </li>
        </ul>
    </li>
    <li>
        <a href="<?php echo BASE_URL; ?>index.php?page=profil" 
           class="flex items-center space-x-3 px-4 py-3 rounded-lg hover:bg-sky-600 transition duration-200 <?php echo ($current_page == 'profil') ? 'active-nav-link' : ''; ?>">
            <i class="fas fa-user-cog w-5"></i>
            <span>Profil & Saldo</span>
        </a>
    </li>
    </ul>
