-- ============================================================
-- add_detail_driver.sql
-- Membuat tabel detail_driver khusus untuk profil driver
-- ============================================================

USE `db_banksampah`;

CREATE TABLE IF NOT EXISTS `detail_driver` (
  `id_detail` INT(11) NOT NULL AUTO_INCREMENT,
  `id_pengguna` INT(11) NOT NULL,
  `kecamatan` VARCHAR(100) DEFAULT NULL,
  `kab_kota` VARCHAR(100) DEFAULT NULL,
  `wilayah` VARCHAR(100) DEFAULT NULL,
  `kode_pos` VARCHAR(20) DEFAULT NULL,
  `tipe_kendaraan` ENUM('Mobil', 'Truk', 'Motor') NOT NULL,
  `jenis_kendaraan` VARCHAR(100) NOT NULL,
  `plat_nomor` VARCHAR(20) NOT NULL,
  `kapasitas_berat` DECIMAL(5,2) DEFAULT 0.00,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_detail`),
  KEY `idx_detail_driver_pengguna` (`id_pengguna`),
  CONSTRAINT `fk_detail_driver_pengguna` FOREIGN KEY (`id_pengguna`) REFERENCES `pengguna` (`id_pengguna`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
