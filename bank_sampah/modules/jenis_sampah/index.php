<?php
// modules/jenis_sampah/index.php
check_user_level(['admin']); // Hanya admin

$search = isset($_GET['search']) ? sanitize_input($_GET['search']) : '';
$query_condition = "";
if (!empty($search)) {
    $query_condition = " WHERE nama_sampah LIKE '%$search%' OR deskripsi LIKE '%$search%'";
}

// Ambil daftar kolom dari tabel jenis_sampah supaya kita bisa menampilkan semua kolom secara dinamis
$cols_res = mysqli_query($koneksi, "SHOW COLUMNS FROM jenis_sampah");
$columns = [];
while ($c = mysqli_fetch_assoc($cols_res)) {
    $columns[] = $c['Field'];
}

$query = "SELECT * FROM jenis_sampah $query_condition ORDER BY nama_sampah ASC";
$result = mysqli_query($koneksi, $query);
?>

<div class="container mx-auto px-4 py-8">
    <div class="flex justify-between items-center mb-6">
        <h1 class="text-3xl font-bold text-gray-800">Data Jenis Sampah</h1>
        <a href="<?php echo BASE_URL; ?>index.php?page=jenis_sampah/tambah" class="bg-green-500 hover:bg-green-600 text-white font-semibold py-2 px-4 rounded-lg shadow-md transition duration-150 ease-in-out">
            <i class="fas fa-plus mr-2"></i> Tambah Jenis Sampah
        </a>
    </div>

    <form method="GET" action="<?php echo BASE_URL; ?>index.php" class="mb-6">
        <input type="hidden" name="page" value="jenis_sampah/data">
        <div class="flex">
            <input type="text" name="search" value="<?php echo htmlspecialchars($search); ?>" placeholder="Cari jenis sampah..." class="w-full px-4 py-2 border border-gray-300 rounded-l-lg focus:outline-none focus:ring-2 focus:ring-sky-500 focus:border-sky-500">
            <button type="submit" class="bg-sky-500 hover:bg-sky-600 text-white font-semibold px-4 py-2 rounded-r-lg transition duration-150">
                <i class="fas fa-search"></i> Cari
            </button>
        </div>
    </form>

    <div class="bg-white shadow-xl rounded-lg overflow-hidden">
        <div class="overflow-x-auto">
            <!-- debug removed -->
            <table class="min-w-full divide-y divide-gray-200">
                <thead class="bg-gray-50">
                    <tr>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">No</th>
                        <?php foreach ($columns as $col): ?>
                            <?php if ($col === 'id_jenis_sampah') continue; ?>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"><?php echo htmlspecialchars(ucwords(str_replace('_', ' ', $col))); ?></th>
                        <?php endforeach; ?>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Aksi</th>
                    </tr>
                </thead>
                <tbody class="bg-white divide-y divide-gray-200">
                    <?php if ($result && mysqli_num_rows($result) > 0): ?>
                        <?php $no = 1; ?>
                        <?php while($row = mysqli_fetch_assoc($result)): ?>
                        <tr>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900"><?php echo $no++; ?></td>
                            <?php foreach ($columns as $col): ?>
                                <?php if ($col === 'id_jenis_sampah') continue; ?>
                                <?php if ($col === 'gambar'): ?>
                                    <td class="px-6 py-4 text-sm text-gray-900 align-top">
                                        <?php if (!empty($row[$col])): ?>
                                            <?php
                                                $img_raw = $row[$col];
                                                // jika path relatif (tidak diawali http:// https:// atau /), prepend BASE_URL
                                                if (!preg_match('#^(https?://|/)#i', $img_raw)) {
                                                    $img = rtrim(BASE_URL, '/') . '/' . ltrim($img_raw, '/');
                                                } else {
                                                    $img = $img_raw;
                                                }
                                            ?>
                                            <img src="<?php echo htmlspecialchars($img); ?>" alt="<?php echo htmlspecialchars($row['nama_sampah'] ?? ''); ?>" class="w-24 h-16 object-cover rounded" />
                                        <?php else: ?>
                                            -
                                        <?php endif; ?>
                                    </td>
                                <?php elseif ($col === 'video'): ?>
                                    <td class="px-6 py-4 text-sm text-gray-900 align-top">
                                        <?php if (!empty($row[$col])): ?>
                                            <a href="<?php echo htmlspecialchars($row[$col]); ?>" target="_blank" class="text-sky-600 hover:underline">Lihat Video</a>
                                        <?php else: ?>
                                            -
                                        <?php endif; ?>
                                    </td>
                                <?php else: ?>
                                    <td class="px-6 py-4 whitespace-normal text-sm text-gray-900 align-top">
                                        <?php
                                            if ($col === 'harga_per_kg') {
                                                echo format_rupiah($row[$col]);
                                            } else {
                                                echo nl2br(htmlspecialchars($row[$col] !== null && $row[$col] !== '' ? $row[$col] : '-'));
                                            }
                                        ?>
                                    </td>
                                <?php endif; ?>
                            <?php endforeach; ?>
                            <td class="px-6 py-4 whitespace-nowrap text-sm">
                                <?php
                                    $img_val = in_array('gambar', $columns) ? $row['gambar'] : '';
                                    $video_val = in_array('video', $columns) ? $row['video'] : '';
                                    if (!empty($img_val) && !preg_match('#^(https?://|/)#i', $img_val)) {
                                        $img_val = rtrim(BASE_URL, '/') . '/' . ltrim($img_val, '/');
                                    }
                                ?>
                                <div class="flex items-center justify-between w-full">
                                    <div class="flex items-center text-sm space-x-2">

                                    </div>
                                    <div class="flex items-center text-sm space-x-3 whitespace-nowrap">
                                        <a href="<?php echo BASE_URL; ?>index.php?page=jenis_sampah/edit&id=<?php echo $row['id_jenis_sampah']; ?>" class="text-indigo-600 hover:text-indigo-900"><i class="fas fa-edit"></i> Edit</a>
                                        <a href="<?php echo BASE_URL; ?>index.php?page=jenis_sampah/hapus&id=<?php echo $row['id_jenis_sampah']; ?>" 
                                           class="text-red-600 hover:text-red-900 btn-hapus" 
                                           data-pesan="Apakah Anda yakin ingin menghapus jenis sampah ini? Ini mungkin mempengaruhi data transaksi yang ada."><i class="fas fa-trash"></i> Hapus</a>
                                    </div>
                                </div>
                            </td>
                        </tr>
                        <?php endwhile; ?>
                    <?php else: ?>
                        <tr>
                            <td colspan="<?php echo (count($columns) - (in_array('id_jenis_sampah', $columns) ? 1 : 0)) + 2; ?>" class="px-6 py-4 text-center text-sm text-gray-500">
                                Tidak ada data jenis sampah ditemukan.
                                <?php if(!empty($search)): ?>
                                    <br>Coba kata kunci lain atau <a href="<?php echo BASE_URL; ?>index.php?page=jenis_sampah/data" class="text-sky-500 hover:underline">tampilkan semua jenis sampah</a>.
                                <?php endif; ?>
                            </td>
                        </tr>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

        <!-- Modal sederhana untuk menampilkan gambar / video -->
        <div id="media-modal" class="fixed inset-0 bg-black bg-opacity-50 hidden items-center justify-center z-50">
            <div class="bg-white rounded-lg overflow-hidden max-w-3xl w-full mx-4">
                <div class="flex justify-between items-center p-3 border-b">
                    <h3 id="media-modal-title" class="text-lg font-semibold">Media</h3>
                    <button id="media-modal-close" class="text-gray-600 hover:text-gray-900">&times;</button>
                </div>
                <div id="media-modal-body" class="p-4 text-center">
                    <!-- konten akan diinject oleh JS -->
                </div>
            </div>
        </div>

        <script>
        document.addEventListener('DOMContentLoaded', function(){
            const modal = document.getElementById('media-modal');
            const body = document.getElementById('media-modal-body');
            const title = document.getElementById('media-modal-title');
            const closeBtn = document.getElementById('media-modal-close');

            function openModal(contentHtml, modalTitle) {
                body.innerHTML = contentHtml;
                title.textContent = modalTitle;
                modal.classList.remove('hidden');
                modal.classList.add('flex');
            }
            function closeModal(){
                modal.classList.remove('flex');
                modal.classList.add('hidden');
                body.innerHTML = '';
            }

            document.querySelectorAll('.btn-show-image').forEach(btn => {
                btn.addEventListener('click', function(){
                    const imgPath = this.getAttribute('data-img');
                    if (!imgPath) {
                        openModal('<p class="text-gray-700">Tidak ada gambar untuk item ini.</p>', 'Gambar');
                        return;
                    }
                    // jika path relatif, tambahkan BASE URL (server-side already handled when rendering)
                    const img = '<img src="' + imgPath.replace(/&quot;/g,'\"') + '" alt="gambar" class="mx-auto max-h-[60vh] object-contain" />';
                    openModal(img, 'Gambar');
                });
            });

            document.querySelectorAll('.btn-show-video').forEach(btn => {
                btn.addEventListener('click', function(){
                    const vid = this.getAttribute('data-video');
                    if (!vid) {
                        openModal('<p class="text-gray-700">Tidak ada video untuk item ini.</p>', 'Video');
                        return;
                    }
                    // jika video adalah link youtube, embed
                    let content = '';
                    if (vid.includes('youtube.com') || vid.includes('youtu.be')){
                        // extract id (basic)
                        let vidId = '';
                        try{
                            if (vid.includes('v=')){
                                vidId = vid.split('v=')[1].split('&')[0];
                            } else if (vid.includes('youtu.be/')){
                                vidId = vid.split('youtu.be/')[1].split('?')[0];
                            }
                            content = '<iframe width="100%" height="480" src="https://www.youtube.com/embed/' + vidId + '" frameborder="0" allowfullscreen></iframe>';
                        } catch(e){
                            content = '<a href="'+ vid +'" target="_blank">Buka video</a>';
                        }
                    } else {
                        content = '<a href="'+ vid +'" target="_blank">Buka video</a>';
                    }
                    openModal(content, 'Video');
                });
            });

            closeBtn.addEventListener('click', closeModal);
            modal.addEventListener('click', function(e){ if (e.target === modal) closeModal(); });
        });
        </script>
