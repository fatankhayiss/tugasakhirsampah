<?php
// modules/monitor_ai/index.php
// Pastikan tidak bisa diakses langsung
if (!defined('BASE_URL')) {
    header("Location: ../../index.php");
    exit;
}

// Pastikan hanya admin yang bisa akses (fungsi ini sudah otomatis melakukan redirect jika gagal)
check_user_level(['admin']);
?>

<div class="container mx-auto px-4 py-8">
    <div class="flex justify-between items-center mb-6">
        <div>
            <h1 class="text-3xl font-bold text-gray-800">Live Monitor AI Scan</h1>
            <p class="text-gray-600 mt-2">Memantau aktivitas deteksi gambar oleh kecerdasan buatan secara real-time.</p>
        </div>
        <div>
            <span class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-red-100 text-red-800 animate-pulse">
                <span class="w-2 h-2 mr-2 bg-red-500 rounded-full"></span>
                Live Polling (3s)
            </span>
        </div>
    </div>

    <!-- Container untuk List Detections -->
    <div id="ai-monitor-container" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <!-- Skeleton Loading awal -->
        <div class="bg-white rounded-lg shadow-md p-4 animate-pulse">
            <div class="h-48 bg-gray-200 rounded-lg mb-4"></div>
            <div class="h-4 bg-gray-200 rounded w-3/4 mb-2"></div>
            <div class="h-4 bg-gray-200 rounded w-1/2"></div>
        </div>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const container = document.getElementById('ai-monitor-container');
    let lastDataString = '';

    function fetchLatestDetections() {
        fetch('<?php echo BASE_URL; ?>index.php?page=monitor_ai/data')
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    const currentDataString = JSON.stringify(data.data);
                    // Hanya update DOM jika ada perubahan data untuk menghindari flicker
                    if (currentDataString !== lastDataString) {
                        renderDetections(data.data);
                        lastDataString = currentDataString;
                    }
                }
            })
            .catch(error => console.error('Error fetching AI data:', error));
    }

    function renderDetections(items) {
        if (!items || items.length === 0) {
            container.innerHTML = `
                <div class="col-span-full bg-white rounded-lg shadow p-8 text-center">
                    <i class="fas fa-camera text-gray-300 text-5xl mb-3"></i>
                    <h3 class="text-lg font-medium text-gray-900">Belum Ada Aktivitas Scan</h3>
                    <p class="text-gray-500">Hasil deteksi dari aplikasi mobile akan muncul di sini.</p>
                </div>`;
            return;
        }

        let html = '';
        items.forEach(item => {
            const timeAgo = item.time_ago;
            const namaLengkap = item.nama_lengkap ? item.nama_lengkap : 'Pengguna Anonim / Belum Login';
            
            // Format labels array (kalau kosong, defaultnya "Tidak Dikenali")
            let labelsStr = '<span class="text-gray-500 italic">Tidak dikenali</span>';
            if (item.labels && item.labels.length > 0) {
                labelsStr = item.labels.map(l => `<span class="inline-block bg-blue-100 text-blue-800 text-xs px-2 py-1 rounded border border-blue-200 mr-1 mb-1">${l}</span>`).join('');
            }

            // Fallback image url if broken
            const imageUrl = item.uploaded_file ? `<?php echo BASE_URL; ?>${item.uploaded_file}` : 'https://via.placeholder.com/400x300?text=No+Image';

            // User Avatar
            let avatarHtml = `<div class="w-8 h-8 rounded-full bg-indigo-100 flex items-center justify-center text-indigo-500 font-bold"><i class="fas fa-user text-sm"></i></div>`;
            if (item.foto_profil) {
                let avatarSrc = '';
                if (item.foto_profil.startsWith('http')) {
                    avatarSrc = item.foto_profil;
                } else if (item.foto_profil.startsWith('assets/')) {
                    avatarSrc = `<?php echo BASE_URL; ?>${item.foto_profil}`;
                } else {
                    avatarSrc = `<?php echo BASE_URL; ?>assets/uploads/${item.foto_profil}`;
                }
                avatarHtml = `<img src="${avatarSrc}" alt="Avatar" class="w-8 h-8 rounded-full object-cover border border-gray-200" onerror="this.src='<?php echo BASE_URL; ?>assets/uploads/default_avatar.png'">`;
            }

            html += `
            <div class="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-lg transition-shadow duration-300 relative border border-gray-100">
                ${item.is_new ? '<div class="absolute top-2 right-2 bg-green-500 text-white text-xs font-bold px-2 py-1 rounded-full animate-bounce shadow-md">NEW</div>' : ''}
                <div class="h-48 w-full bg-gray-200 overflow-hidden">
                    <img src="${imageUrl}" alt="Scan Image" class="w-full h-full object-cover" onerror="this.src='https://via.placeholder.com/400x300?text=Image+Error'">
                </div>
                <div class="p-4">
                    <div class="flex items-center space-x-2 mb-3">
                        ${avatarHtml}
                        <div class="text-sm">
                            <p class="text-gray-900 font-semibold truncate" title="${namaLengkap}">${namaLengkap}</p>
                            <p class="text-gray-500 text-xs"><i class="far fa-clock mr-1"></i>${timeAgo}</p>
                        </div>
                    </div>
                    
                    <div class="mt-2">
                        <h4 class="text-xs text-gray-500 uppercase font-bold mb-1">Hasil Deteksi (AI):</h4>
                        <div class="flex flex-wrap">
                            ${labelsStr}
                        </div>
                    </div>
                </div>
            </div>
            `;
        });
        container.innerHTML = html;
    }

    // Jalankan pertama kali
    fetchLatestDetections();

    // Polling setiap 3 detik
    setInterval(fetchLatestDetections, 3000);
});
</script>
