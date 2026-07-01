<?php
require_once __DIR__ . '/config/database.php';

// Hapus semua data lama
mysqli_query($koneksi, "TRUNCATE TABLE edukasi");

// Data Baru
$data = [
    // Artikel 1
    [
        'judul' => 'Cara Efektif Memilah Sampah Rumah Tangga',
        'konten' => 'Memilah sampah dari rumah tangga adalah langkah awal yang sangat penting dalam menjaga kelestarian lingkungan. Pisahkan antara sampah organik (sisa makanan, dedaunan) dan anorganik (plastik, kertas, logam). Sampah organik bisa dijadikan kompos, sedangkan anorganik bisa disetorkan ke Bank Sampah untuk didaur ulang menjadi barang bernilai ekonomis.',
        'gambar' => 'https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?auto=format&fit=crop&w=800&q=80',
        'video_url' => '',
        'author_id' => 1
    ],
    // Artikel 2
    [
        'judul' => 'Mengapa Bank Sampah Penting untuk Lingkungan?',
        'konten' => 'Bank Sampah tidak hanya membantu mengurangi tumpukan sampah di TPA (Tempat Pembuangan Akhir), tetapi juga memberdayakan masyarakat secara ekonomi. Dengan sistem tabungan, warga dapat mengubah sampah menjadi pundi-pundi rupiah. Selain itu, Bank Sampah mengajarkan kedisiplinan dan rasa tanggung jawab terhadap alam sekitar.',
        'gambar' => 'https://images.unsplash.com/photo-1611284446314-60a58ac0deb9?auto=format&fit=crop&w=800&q=80',
        'video_url' => '',
        'author_id' => 1
    ],
    // Video 1
    [
        'judul' => 'Proses Daur Ulang Plastik Menjadi Produk Baru',
        'konten' => 'Simak video dokumenter singkat ini untuk melihat bagaimana botol plastik bekas yang Anda kumpulkan diproses di pabrik daur ulang hingga menjadi produk baru yang siap digunakan kembali.',
        'gambar' => '',
        'video_url' => 'https://www.youtube.com/watch?v=VjGzP07XvP4',
        'author_id' => 1
    ],
    // Video 2
    [
        'judul' => 'Tutorial Membuat Kompos Sederhana di Rumah',
        'konten' => 'Punya banyak sisa sayuran dan kulit buah? Jangan langsung dibuang! Tonton video ini untuk mempelajari cara mudah membuat pupuk kompos sendiri di halaman rumah Anda tanpa ribet.',
        'gambar' => '',
        'video_url' => 'https://www.youtube.com/watch?v=cBmWXzIu_yE',
        'author_id' => 1
    ]
];

foreach ($data as $item) {
    $judul = mysqli_real_escape_string($koneksi, $item['judul']);
    $konten = mysqli_real_escape_string($koneksi, $item['konten']);
    $gambar = mysqli_real_escape_string($koneksi, $item['gambar']);
    $video_url = mysqli_real_escape_string($koneksi, $item['video_url']);
    $author_id = $item['author_id'];
    
    $sql = "INSERT INTO edukasi (judul, konten, gambar, video_url, author_id) VALUES ('$judul', '$konten', '$gambar', '$video_url', $author_id)";
    mysqli_query($koneksi, $sql);
}

echo "Database berhasil di-seed dengan data yang benar!";
?>
