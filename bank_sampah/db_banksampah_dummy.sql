-- Dummy database for testing riwayat setor and tarik_saldo
-- Database: db_banksampah_dummy

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+07:00";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

CREATE DATABASE IF NOT EXISTS `db_banksampah_dummy` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `db_banksampah_dummy`;

-- Disable foreign key checks while dropping/creating tables to avoid dependency errors
SET FOREIGN_KEY_CHECKS = 0;

-- --------------------------------------------------------
-- Table structure for table `pengguna`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `pengguna`;
CREATE TABLE `pengguna` (
  `id_pengguna` int(11) NOT NULL,
  `nama_lengkap` varchar(100) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `level` enum('admin','petugas','warga') NOT NULL,
  `alamat` text DEFAULT NULL,
  `no_telepon` varchar(15) DEFAULT NULL,
  `saldo` decimal(10,2) DEFAULT 0.00,
  `tanggal_daftar` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- sample users
-- Password default untuk semua akun adalah 'password' (BCRYPT)
-- Hash digunakan: $2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9Pq8fT6S/Z4xQY/1f9QyG6
INSERT INTO `pengguna` (`id_pengguna`, `nama_lengkap`, `username`, `password`, `level`, `alamat`, `no_telepon`, `saldo`) VALUES
(1, 'Administrator Utama', 'admin', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9Pq8fT6S/Z4xQY/1f9QyG6', 'admin', 'Kantor Pusat', '081200000001', 0.00),
(2, 'Petugas Lapangan 1', 'petugas1', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9Pq8fT6S/Z4xQY/1f9QyG6', 'petugas', 'Pos Petugas A', '081200000002', 0.00),
(3, 'Budi Santoso', 'budi', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9Pq8fT6S/Z4xQY/1f9QyG6', 'warga', 'Jl. Merdeka No. 10', '081234567001', 50000.00),
(4, 'Siti Aminah', 'siti', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9Pq8fT6S/Z4xQY/1f9QyG6', 'warga', 'Jl. Pahlawan No. 5', '081234567002', 25000.00),
(5, 'Agus Supriyadi', 'agus', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9Pq8fT6S/Z4xQY/1f9QyG6', 'warga', 'Jl. Mawar No. 3', '081234567003', 15000.00),
(6, 'Dewi Lestari', 'dewi', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9Pq8fT6S/Z4xQY/1f9QyG6', 'warga', 'Jl. Melati No. 8', '081234567004', 8000.00);

-- --------------------------------------------------------
-- Table structure for table `jenis_sampah`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `jenis_sampah`;
CREATE TABLE `jenis_sampah` (
  `id_jenis_sampah` int(11) NOT NULL,
  `nama_sampah` varchar(100) NOT NULL,
  `harga_per_kg` decimal(10,2) NOT NULL,
  `deskripsi` text DEFAULT NULL,
  `satuan` varchar(10) DEFAULT 'kg'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `jenis_sampah` (`id_jenis_sampah`, `nama_sampah`, `harga_per_kg`, `deskripsi`, `satuan`) VALUES
(1, 'Plastik Botol (PET)', 3000.00, 'Botol plastik bekas', 'kg'),
(2, 'Kardus', 1500.00, 'Kardus bekas kemasan', 'kg'),
(3, 'Kertas', 1200.00, 'Kertas bekas HVS/koran', 'kg'),
(4, 'Besi', 2500.00, 'Besi tua/kaleng', 'kg'),
(5, 'Aluminium', 8000.00, 'Kaleng minuman/aluminium', 'kg'),
(6, 'Gelas Plastik (PP)', 2200.00, 'Gelas plastik bekas', 'kg');

-- --------------------------------------------------------
-- Table structure for table `transaksi`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `transaksi`;
CREATE TABLE `transaksi` (
  `id_transaksi` int(11) NOT NULL,
  `id_warga` int(11) NOT NULL,
  `id_petugas_pencatat` int(11) NOT NULL,
  `tanggal_transaksi` timestamp NOT NULL DEFAULT current_timestamp(),
  `tipe_transaksi` enum('setor','tarik_saldo') NOT NULL,
  `total_nilai` decimal(10,2) NOT NULL DEFAULT 0.00,
  `keterangan` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- sample transaksi: mix of setor and tarik_saldo
INSERT INTO `transaksi` (`id_transaksi`, `id_warga`, `id_petugas_pencatat`, `tanggal_transaksi`, `tipe_transaksi`, `total_nilai`, `keterangan`) VALUES
(1, 3, 2, '2025-10-01 08:15:00', 'setor', 9000.00, 'Setoran plastik + kardus'),
(2, 4, 2, '2025-10-02 10:30:00', 'tarik_saldo', 20000.00, 'Tarik tunai ke rekening bank'),
(3, 5, 2, '2025-10-03 09:45:00', 'setor', 3600.00, 'Setoran kertas 3kg'),
(4, 3, 2, '2025-10-05 14:20:00', 'tarik_saldo', 5000.00, 'Pengajuan penarikan saldo'),
(5, 6, 2, '2025-10-06 16:10:00', 'setor', 11000.00, 'Setoran aluminium + plastik'),
(6, 4, 2, '2025-10-07 11:00:00', 'setor', 3000.00, 'Setoran kardus'),
(7, 5, 2, '2025-10-08 12:00:00', 'tarik_saldo', 7000.00, 'Transfer ke e-wallet'),
(8, 3, 2, '2025-10-09 08:00:00', 'setor', 4500.00, 'Setoran gelas plastik'),
(9, 6, 2, '2025-10-10 09:30:00', 'tarik_saldo', 3000.00, 'Penarikan kecil'),
(10, 5, 2, '2025-10-11 15:20:00', 'setor', 2400.00, 'Setoran kertas');

-- --------------------------------------------------------
-- Table structure for table `detail_setoran`
-- --------------------------------------------------------
DROP TABLE IF EXISTS `detail_setoran`;
CREATE TABLE `detail_setoran` (
  `id_detail_setoran` int(11) NOT NULL,
  `id_transaksi_setor` int(11) NOT NULL,
  `id_jenis_sampah` int(11) NOT NULL,
  `berat_kg` decimal(5,2) NOT NULL,
  `harga_saat_setor` decimal(10,2) NOT NULL,
  `subtotal_nilai` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- detail items for setoran transactions above
INSERT INTO `detail_setoran` (`id_detail_setoran`, `id_transaksi_setor`, `id_jenis_sampah`, `berat_kg`, `harga_saat_setor`, `subtotal_nilai`) VALUES
(1, 1, 1, 1.50, 3000.00, 4500.00),
(2, 1, 2, 1.50, 3000.00, 4500.00),
(3, 3, 3, 3.00, 1200.00, 3600.00),
(4, 5, 5, 1.00, 8000.00, 8000.00),
(5, 5, 1, 1.00, 3000.00, 3000.00),
(6, 6, 2, 2.00, 1500.00, 3000.00),
(7, 8, 6, 2.00, 2200.00, 4400.00),
(8, 10, 3, 2.00, 1200.00, 2400.00);

-- --------------------------------------------------------
-- Indexes and AUTO_INCREMENT
-- --------------------------------------------------------
ALTER TABLE `pengguna`
  ADD PRIMARY KEY (`id_pengguna`),
  ADD UNIQUE KEY `username` (`username`),
  ADD KEY `no_telepon` (`no_telepon`);

ALTER TABLE `jenis_sampah`
  ADD PRIMARY KEY (`id_jenis_sampah`);

ALTER TABLE `transaksi`
  ADD PRIMARY KEY (`id_transaksi`),
  ADD KEY `id_warga` (`id_warga`),
  ADD KEY `id_petugas_pencatat` (`id_petugas_pencatat`);

ALTER TABLE `detail_setoran`
  ADD PRIMARY KEY (`id_detail_setoran`),
  ADD KEY `id_transaksi_setor` (`id_transaksi_setor`),
  ADD KEY `id_jenis_sampah` (`id_jenis_sampah`);

ALTER TABLE `pengguna`
  MODIFY `id_pengguna` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

ALTER TABLE `jenis_sampah`
  MODIFY `id_jenis_sampah` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

ALTER TABLE `transaksi`
  MODIFY `id_transaksi` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

ALTER TABLE `detail_setoran`
  MODIFY `id_detail_setoran` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

-- Foreign keys
ALTER TABLE `transaksi`
  ADD CONSTRAINT `transaksi_ibfk_1` FOREIGN KEY (`id_warga`) REFERENCES `pengguna` (`id_pengguna`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `transaksi_ibfk_2` FOREIGN KEY (`id_petugas_pencatat`) REFERENCES `pengguna` (`id_pengguna`) ON DELETE NO ACTION ON UPDATE CASCADE;

ALTER TABLE `detail_setoran`
  ADD CONSTRAINT `detail_setoran_ibfk_1` FOREIGN KEY (`id_transaksi_setor`) REFERENCES `transaksi` (`id_transaksi`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `detail_setoran_ibfk_2` FOREIGN KEY (`id_jenis_sampah`) REFERENCES `jenis_sampah` (`id_jenis_sampah`) ON DELETE NO ACTION ON UPDATE CASCADE;

-- --------------------------------------------------------
-- Tambahan dummy penarikan (tarik_saldo) — dapat di-import juga terpisah
-- --------------------------------------------------------
INSERT INTO transaksi (id_warga, id_petugas_pencatat, tanggal_transaksi, tipe_transaksi, total_nilai, keterangan) VALUES
  (3, 2, '2025-11-01 10:00:00', 'tarik_saldo', 15000.00, 'Tarik tunai di loket'),
  (4, 2, '2025-11-02 14:30:00', 'tarik_saldo', 5000.00, 'Tarik tunai di loket'),
  (5, 2, '2025-11-03 09:15:00', 'tarik_saldo', 7000.00, 'Tarik tunai di loket'),
  (3, 2, '2025-11-04 16:45:00', 'tarik_saldo', 10000.00, 'Tarik tunai di loket');

-- Sesuaikan saldo pengguna agar mencerminkan penarikan di atas
UPDATE pengguna SET saldo = saldo - 15000.00 WHERE id_pengguna = 3;
UPDATE pengguna SET saldo = saldo - 5000.00 WHERE id_pengguna = 4;
UPDATE pengguna SET saldo = saldo - 7000.00 WHERE id_pengguna = 5;
UPDATE pengguna SET saldo = saldo - 10000.00 WHERE id_pengguna = 3;


-- Re-enable foreign key checks after all tables / constraints are created
SET FOREIGN_KEY_CHECKS = 1;

COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
