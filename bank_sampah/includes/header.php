<?php
// includes/header.php
if (session_status() == PHP_SESSION_NONE) { // Pastikan session sudah dimulai
    session_start();
}
$current_page = isset($_GET['page']) ? $_GET['page'] : '';
$user_level = isset($_SESSION['user_level']) ? $_SESSION['user_level'] : null;
$user_nama = isset($_SESSION['user_nama']) ? $_SESSION['user_nama'] : 'Tamu';
?>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bank Sampah Digital</title>
    <link rel="icon" href="/favicon.ico" type="image/x-icon">
    <link rel="icon" href="assets/recycle.png" type="image/png">
    <link rel="apple-touch-icon" href="assets/recycle.png">
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        /* Sembunyikan scrollbar pada seluruh halaman web (body, tabel, konten utama - BUKAN di sidebar) agar bersih & tidak mengganggu */
        html, body, main, section, article, div:not(.sidebar nav) {
            scrollbar-width: none; /* Firefox */
            -ms-overflow-style: none; /* IE & Edge */
        }
        html::-webkit-scrollbar, body::-webkit-scrollbar, main::-webkit-scrollbar, section::-webkit-scrollbar, article::-webkit-scrollbar, div:not(.sidebar nav)::-webkit-scrollbar { 
            display: none; /* Chrome, Edge, Safari, Opera */
            width: 0px; 
            height: 0px; 
        }
        
        /* Scrollbar khusus untuk Sidebar: melayang (ngambang) di depan tanpa merusak/menggeser isi menu sedikitpun */
        .sidebar nav {
            overflow-y: auto;
            margin-right: -12px; /* Mendorong jalur scrollbar ke luar area teks agar tidak mengganggu layout menu */
            padding-right: 12px; /* Kompensasi padding sehingga posisi teks & ikon menu 100% statis tidak bergeser */
            scrollbar-width: thin;
            scrollbar-color: transparent transparent;
            transition: scrollbar-color 0.4s ease-in-out;
        }
        .sidebar nav:hover {
            scrollbar-color: rgba(209, 213, 219, 0.35) transparent; /* Muncul perlahan abu tipis transparan saat di-hover */
        }
        .sidebar nav::-webkit-scrollbar {
            width: 4px; /* Batang scrollbar tipis (4px) */
        }
        .sidebar nav::-webkit-scrollbar-track {
            background: transparent;
        }
        .sidebar nav::-webkit-scrollbar-thumb {
            background: transparent; /* Default tidak terlihat (transparan) */
            border-radius: 20px;
            transition: background-color 0.4s ease-in-out;
        }
        .sidebar nav:hover::-webkit-scrollbar-thumb {
            background: rgba(209, 213, 219, 0.35); /* Muncul perlahan ngambang di depan dengan warna abu tipis transparan */
        }
        .sidebar nav:hover::-webkit-scrollbar-thumb:hover {
            background: rgba(209, 213, 219, 0.6);
        }
        body {
            font-family: 'Poppins', 'Inter', sans-serif;
            background-color: #f0f9ff; /* Light sky blue background */
        }
        .sidebar {
            transition: transform 0.3s ease-in-out;
        }
        .sidebar-overlay { /* Untuk efek gelap di belakang sidebar mobile */
            transition: opacity 0.3s ease-in-out;
        }
        .active-nav-link {
            background-color: #2563eb; /* bg-blue-600 */
            color: white;
        }
        .active-nav-link i {
            color: white;
        }
    </style>
</head>
<body class="bg-slate-100 antialiased">

<?php if (is_logged_in()): ?>
    <div id="sidebar-overlay" class="sidebar-overlay fixed inset-0 z-20 bg-black bg-opacity-50 opacity-0 pointer-events-none md:hidden"></div>

    <div class="flex h-screen">
        <aside id="sidebar" class="sidebar fixed inset-y-0 left-0 z-30 w-64 bg-gradient-to-b from-sky-500 to-indigo-600 text-white p-4 space-y-4 transform -translate-x-full md:translate-x-0 md:relative md:flex md:flex-col shadow-lg">
            <a href="<?php echo BASE_URL; ?>index.php?page=dashboard" class="flex items-center space-x-3 px-2 py-3 mb-4">
                <i class="fas fa-recycle fa-2x text-sky-200"></i>
                
                <div class="flex flex-col leading-tight">
                    <span class="text-xs font-light text-sky-100 tracking-wide">Bank Sampah</span>
                    <span class="text-2xl font-bold">ITrashy</span>
                </div>
            </a>


            <nav class="flex-grow overflow-y-auto">
                <?php
                // Web Portal ini murni khusus untuk Admin Bank Sampah
                include 'sidebar_admin.php';
                ?>
            </nav>
            
            <div class="pt-4 border-t border-sky-400">
                 <a href="<?php echo BASE_URL; ?>index.php?page=profil" class="flex items-center space-x-3 px-4 py-3 rounded-lg hover:bg-sky-600 transition duration-200 <?php echo ($current_page == 'profil') ? 'active-nav-link' : ''; ?>">
                    <i class="fas fa-user-circle w-5"></i>
                    <span>Profil Saya</span>
                </a>
                <a href="<?php echo BASE_URL; ?>index.php?page=auth/logout" class="flex items-center space-x-3 px-4 py-3 mt-1 rounded-lg text-red-200 hover:bg-red-500 hover:text-white transition duration-200">
                    <i class="fas fa-sign-out-alt w-5"></i>
                    <span>Logout</span>
                </a>
            </div>
        </aside>

        <div id="content-area" class="flex-1 flex flex-col overflow-hidden md:ml-0"> <header class="bg-white shadow-md p-3 sm:p-4">
                <div class="container mx-auto flex justify-between items-center">
                    <div class="flex items-center">
                        <button id="menu-button" class="text-gray-700 md:hidden mr-3 p-2 rounded-md hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-sky-500">
                            <i class="fas fa-bars fa-lg"></i>
                        </button>
                        <h1 class="text-lg sm:text-xl font-semibold text-gray-800 truncate">
                             <span class="font-bold"><?php echo htmlspecialchars($user_nama); ?></span>
                        </h1>
                    </div>
                    <div>
                        </div>
                </div>
            </header>

            <main class="flex-1 overflow-x-hidden overflow-y-auto bg-slate-100 p-4 sm:p-6">

<?php else: // Jika belum login (misalnya halaman login) ?>
    <div class="min-h-screen flex flex-col"> <main class="flex-1">
            <?php endif; ?>
