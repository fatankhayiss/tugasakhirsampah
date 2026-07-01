-- Seeder: extend 'jenis_sampah' with fields for ML results and content
-- This variant sets `kategori` to either 'Organik' or 'Anorganik' as requested.
-- Run this SQL in your database (phpMyAdmin or CLI) after taking backup.

-- Add columns only if they don't already exist (idempotent)
SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE table_schema=DATABASE() AND table_name='jenis_sampah' AND column_name='kategori');
SET @sql = IF(@col_exists = 0, 'ALTER TABLE jenis_sampah ADD COLUMN `kategori` varchar(100) DEFAULT NULL', 'SELECT "kategori_exists"');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE table_schema=DATABASE() AND table_name='jenis_sampah' AND column_name='cara_pengolahan');
SET @sql = IF(@col_exists = 0, 'ALTER TABLE jenis_sampah ADD COLUMN `cara_pengolahan` text DEFAULT NULL', 'SELECT "cara_pengolahan_exists"');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE table_schema=DATABASE() AND table_name='jenis_sampah' AND column_name='gambar');
SET @sql = IF(@col_exists = 0, 'ALTER TABLE jenis_sampah ADD COLUMN `gambar` varchar(255) DEFAULT NULL', 'SELECT "gambar_exists"');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE table_schema=DATABASE() AND table_name='jenis_sampah' AND column_name='video');
SET @sql = IF(@col_exists = 0, 'ALTER TABLE jenis_sampah ADD COLUMN `video` varchar(255) DEFAULT NULL', 'SELECT "video_exists"');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Update existing rows mapping to Organik / Anorganik
-- Plastics, glass, metal, and similar -> Anorganik
UPDATE `jenis_sampah` SET
  `kategori` = 'Anorganik',
  `deskripsi` = 'Botol plastik bekas air mineral, minuman soda, dll.',
  `cara_pengolahan` = 'Cuci bersih, keringkan, lalu kumpulkan ke bank sampah atau pusat daur ulang.',
  `gambar` = 'assets/uploads/example_plastik.jpg',
  `video` = 'https://www.youtube.com/watch?v=example_plastik'
WHERE `nama_sampah` LIKE '%Plastik%';

UPDATE `jenis_sampah` SET
  `kategori` = 'Anorganik',
  `deskripsi` = 'Kardus bekas kemasan.',
  `cara_pengolahan` = 'Lipat dan kempiskan kardus, pisahkan dari kotoran, serahkan ke bank sampah.',
  `gambar` = 'assets/uploads/example_kardus.jpg',
  `video` = 'https://www.youtube.com/watch?v=example_kardus'
WHERE `nama_sampah` LIKE '%Kardus%';

UPDATE `jenis_sampah` SET
  `kategori` = 'Anorganik',
  `deskripsi` = 'Kertas bekas HVS, buku tulis, koran.',
  `cara_pengolahan` = 'Pisahkan kertas yang bersih dan kering untuk didaur ulang; buang kertas kotor ke sampah organik.',
  `gambar` = 'assets/uploads/example_kertas.jpg',
  `video` = 'https://www.youtube.com/watch?v=example_kertas'
WHERE `nama_sampah` LIKE '%Kertas%' OR `nama_sampah` LIKE '%Buku%';

UPDATE `jenis_sampah` SET
  `kategori` = 'Anorganik',
  `deskripsi` = 'Besi tua, kaleng, dll.',
  `cara_pengolahan` = 'Bersihkan dari kotoran berat, kumpulkan di tempat logam terpisah.',
  `gambar` = 'assets/uploads/example_logam.jpg',
  `video` = 'https://www.youtube.com/watch?v=example_logam'
WHERE `nama_sampah` LIKE '%Logam%';

-- Add some organik examples
-- Insert organik examples if they don't already exist
INSERT INTO `jenis_sampah` (nama_sampah, harga_per_kg, deskripsi, satuan, kategori, cara_pengolahan, gambar, video)
SELECT 'Sisa Makanan / Sisa Dapur', 0.00, 'Sisa makanan dari rumah tangga.', 'kg', 'Organik', 'Kumpulkan dan olah menjadi kompos atau serahkan ke unit pengolahan organik.', 'assets/uploads/example_organik_makanan.jpg', 'https://www.youtube.com/watch?v=example_kompos'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM jenis_sampah WHERE nama_sampah = 'Sisa Makanan / Sisa Dapur');

INSERT INTO `jenis_sampah` (nama_sampah, harga_per_kg, deskripsi, satuan, kategori, cara_pengolahan, gambar, video)
SELECT 'Sayuran & Kulit Buah', 0.00, 'Sisa sayuran dan kulit buah yang mudah terurai.', 'kg', 'Organik', 'Pisahkan untuk dibuat kompos atau pengomposan lokal.', 'assets/uploads/example_organik_sayur.jpg', 'https://www.youtube.com/watch?v=example_kompos2'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM jenis_sampah WHERE nama_sampah = 'Sayuran & Kulit Buah');

-- Add a couple of new seeded items (anorganik) with full content
-- Insert additional anorganik examples if they don't exist
INSERT INTO `jenis_sampah` (nama_sampah, harga_per_kg, deskripsi, satuan, kategori, cara_pengolahan, gambar, video)
SELECT 'Botol Plastik Berwarna', 2500.00, 'Botol plastik berwarna seperti kemasan minuman', 'kg', 'Anorganik', 'Pisahkan tutup dan label, bilas, keringkan.', 'assets/uploads/example_botol_warna.jpg', 'https://www.youtube.com/watch?v=example_botol'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM jenis_sampah WHERE nama_sampah = 'Botol Plastik Berwarna');

INSERT INTO `jenis_sampah` (nama_sampah, harga_per_kg, deskripsi, satuan, kategori, cara_pengolahan, gambar, video)
SELECT 'Kertas Karton Berglitter', 500.00, 'Kertas berglitter yang sulit didaur ulang; biasanya dibuang terpisah', 'kg', 'Anorganik', 'Pisahkan dan konsultasikan ke pusat daur ulang tertentu.', 'assets/uploads/example_karton.jpg', 'https://www.youtube.com/watch?v=example_karton'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM jenis_sampah WHERE nama_sampah = 'Kertas Karton Berglitter');
