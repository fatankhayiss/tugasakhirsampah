<?php
require_once __DIR__ . '/config/database.php';

$queries = [
    "ALTER TABLE `pengguna` MODIFY `level` ENUM('admin','petugas','warga','driver') NOT NULL",
    "ALTER TABLE `pengguna` ADD COLUMN `foto_profil` VARCHAR(255) DEFAULT NULL AFTER `saldo`",
    "ALTER TABLE `pengguna` ADD COLUMN `api_token` VARCHAR(255) DEFAULT NULL AFTER `foto_profil`",
    "ALTER TABLE `pengguna` ADD COLUMN `email` VARCHAR(100) DEFAULT NULL AFTER `no_telepon`"
];

foreach ($queries as $q) {
    mysqli_query($koneksi, $q); // Ignore duplicate column errors
}

$sql = "
CREATE TABLE IF NOT EXISTS `orders` (
  `id_order` INT(11) NOT NULL AUTO_INCREMENT,
  `id_warga` INT(11) NOT NULL,
  `id_driver` INT(11) DEFAULT NULL,
  `alamat_jemput` TEXT NOT NULL,
  `latitude` DECIMAL(10,8) DEFAULT NULL,
  `longitude` DECIMAL(11,8) DEFAULT NULL,
  `tanggal_order` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `waktu_jemput_dari` TIME DEFAULT NULL,
  `waktu_jemput_sampai` TIME DEFAULT NULL,
  `estimasi_berat` VARCHAR(50) DEFAULT NULL,
  `estimasi_poin` INT DEFAULT 0,
  `status` ENUM('pending','accepted','on_the_way','picked_up','completed','cancelled') DEFAULT 'pending',
  `catatan` TEXT DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_order`),
  KEY `idx_orders_warga` (`id_warga`),
  KEY `idx_orders_driver` (`id_driver`),
  KEY `idx_orders_status` (`status`),
  CONSTRAINT `orders_ibfk_warga` FOREIGN KEY (`id_warga`) REFERENCES `pengguna` (`id_pengguna`) ON DELETE CASCADE,
  CONSTRAINT `orders_ibfk_driver` FOREIGN KEY (`id_driver`) REFERENCES `pengguna` (`id_pengguna`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `order_items` (
  `id_order_item` INT(11) NOT NULL AUTO_INCREMENT,
  `id_order` INT(11) NOT NULL,
  `id_jenis_sampah` INT(11) NOT NULL,
  `estimasi_berat_kg` DECIMAL(5,2) DEFAULT 0.00,
  `berat_aktual_kg` DECIMAL(5,2) DEFAULT NULL,
  PRIMARY KEY (`id_order_item`),
  KEY `idx_oi_order` (`id_order`),
  KEY `idx_oi_jenis` (`id_jenis_sampah`),
  CONSTRAINT `oi_ibfk_order` FOREIGN KEY (`id_order`) REFERENCES `orders` (`id_order`) ON DELETE CASCADE,
  CONSTRAINT `oi_ibfk_jenis` FOREIGN KEY (`id_jenis_sampah`) REFERENCES `jenis_sampah` (`id_jenis_sampah`) ON DELETE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `notifikasi` (
  `id_notifikasi` INT(11) NOT NULL AUTO_INCREMENT,
  `id_pengguna` INT(11) NOT NULL,
  `judul` VARCHAR(200) NOT NULL,
  `pesan` TEXT DEFAULT NULL,
  `tipe` VARCHAR(50) DEFAULT 'info',
  `is_read` TINYINT(1) DEFAULT 0,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_notifikasi`),
  KEY `idx_notif_user` (`id_pengguna`),
  CONSTRAINT `notif_ibfk_user` FOREIGN KEY (`id_pengguna`) REFERENCES `pengguna` (`id_pengguna`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
";

if (mysqli_multi_query($koneksi, $sql)) {
    do {
        if ($res = mysqli_store_result($koneksi)) {
            mysqli_free_result($res);
        }
    } while (mysqli_more_results($koneksi) && mysqli_next_result($koneksi));
    echo "Done!\n";
} else {
    echo "Error: " . mysqli_error($koneksi) . "\n";
}
?>
