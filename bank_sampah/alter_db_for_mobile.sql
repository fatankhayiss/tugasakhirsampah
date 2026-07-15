-- ============================================================
-- alter_db_for_mobile.sql
-- Migrasi database untuk integrasi Mobile & Driver
-- Jalankan di phpMyAdmin atau CLI: mysql -u root db_banksampah < alter_db_for_mobile.sql
-- ============================================================

USE `db_banksampah`;

-- 1. Tambah level 'driver' ke enum pengguna
ALTER TABLE `pengguna`
  MODIFY `level` ENUM('admin','petugas','warga','driver') NOT NULL;

-- 2. Tambah kolom baru di pengguna
ALTER TABLE `pengguna`
  ADD COLUMN IF NOT EXISTS `foto_profil` VARCHAR(255) DEFAULT NULL AFTER `saldo`,
  ADD COLUMN IF NOT EXISTS `api_token` VARCHAR(255) DEFAULT NULL AFTER `foto_profil`,
  ADD COLUMN IF NOT EXISTS `email` VARCHAR(100) DEFAULT NULL AFTER `no_telepon`;

-- 3. Insert sample driver
INSERT INTO `pengguna` (`nama_lengkap`, `username`, `password`, `level`, `alamat`, `no_telepon`, `saldo`)
VALUES ('Driver Contoh 1', 'driver1', '$2y$10$OQ4wl7ky9pv./gSXpGdIKexnquBeYSOTr52XpZuVmlCS6L8fVoPDC', 'driver', 'Pos Driver A', '081200000003', 0.00);
-- Password: admin123 (sama dengan admin untuk testing)

-- 4. Tabel orders (permintaan penjemputan dari Mobile → Driver)
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
  `status` ENUM('pending','accepted','on_the_way','picked_up','validating','completed','cancelled') DEFAULT 'pending',
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

-- 5. Tabel order_items (detail sampah per order)
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

-- 6. Tabel notifikasi
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

-- 7. Sample data orders (untuk testing)
INSERT INTO `orders` (`id_warga`, `alamat_jemput`, `waktu_jemput_dari`, `waktu_jemput_sampai`, `estimasi_berat`, `estimasi_poin`, `status`, `catatan`)
VALUES
  (3, 'Jl. Merdeka No. 10, RT 03/RW 02', '08:00:00', '10:00:00', '5 Kg', 2500, 'pending', 'Tolong jemput di depan rumah'),
  (4, 'Jl. Pahlawan No. 5, RT 01/RW 05', '13:00:00', '15:00:00', '3 Kg', 1500, 'pending', 'Sampah sudah dikemas dalam plastik');

-- 8. Sample order_items
INSERT INTO `order_items` (`id_order`, `id_jenis_sampah`, `estimasi_berat_kg`)
VALUES
  (1, 1, 3.00),
  (1, 2, 2.00),
  (2, 3, 1.50),
  (2, 6, 1.50);

-- 9. Sample notifikasi
INSERT INTO `notifikasi` (`id_pengguna`, `judul`, `pesan`, `tipe`, `is_read`)
VALUES
  (3, 'Selamat datang di iTrashy!', 'Akun Anda telah berhasil terdaftar.', 'info', 0),
  (3, 'Setoran sampah berhasil', 'Setoran senilai Rp 7.500 telah ditambahkan ke saldo Anda.', 'reward', 1),
  (4, 'Selamat datang di iTrashy!', 'Akun Anda telah berhasil terdaftar.', 'info', 1);
