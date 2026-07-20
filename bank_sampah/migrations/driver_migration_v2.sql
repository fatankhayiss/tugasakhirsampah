-- ============================================================
-- Driver App Database Migration
-- Jalankan di phpMyAdmin pada database: bank_sampah
-- ============================================================

-- 1. Tambah kolom driver_status ke tabel pengguna (jika belum ada)
ALTER TABLE pengguna ADD COLUMN IF NOT EXISTS driver_status VARCHAR(20) DEFAULT 'offline';

-- 2. Buat tabel driver_daily_vehicle
CREATE TABLE IF NOT EXISTS driver_daily_vehicle (
  id           INT          NOT NULL AUTO_INCREMENT,
  driver_id    INT          NOT NULL,
  vehicle_type VARCHAR(100) NOT NULL,
  license_plate VARCHAR(50) NOT NULL,
  capacity     VARCHAR(50)  DEFAULT NULL,
  notes        TEXT         DEFAULT NULL,
  date         DATE         NOT NULL,
  created_at   TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uniq_driver_date (driver_id, date),
  CONSTRAINT fk_ddv_driver FOREIGN KEY (driver_id) REFERENCES pengguna(id_pengguna) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- CATATAN: Jika MySQL versi lama tidak support IF NOT EXISTS:
-- Ganti "ADD COLUMN IF NOT EXISTS" dengan:
--   ALTER TABLE pengguna ADD COLUMN driver_status VARCHAR(20) DEFAULT 'offline';
-- (jalankan hanya jika kolom belum ada)
-- ============================================================
