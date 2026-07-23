-- Migration: Add missing columns to jenis_sampah + seed YOLO class rows
-- Model class names: kaca, kaleng, kardus, kertas, organik, plastik_hdpe, plastik_pet

-- 1. Add missing columns (idempotent via IF NOT EXISTS workaround)
SET @s = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
          WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='jenis_sampah' AND COLUMN_NAME='kategori');
SET @q = IF(@s=0,
    'ALTER TABLE jenis_sampah ADD COLUMN kategori VARCHAR(100) DEFAULT NULL',
    'SELECT "kategori_exists"');
PREPARE p FROM @q; EXECUTE p; DEALLOCATE PREPARE p;

SET @s = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
          WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='jenis_sampah' AND COLUMN_NAME='cara_pengolahan');
SET @q = IF(@s=0,
    'ALTER TABLE jenis_sampah ADD COLUMN cara_pengolahan TEXT DEFAULT NULL',
    'SELECT "cara_pengolahan_exists"');
PREPARE p FROM @q; EXECUTE p; DEALLOCATE PREPARE p;

SET @s = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
          WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='jenis_sampah' AND COLUMN_NAME='gambar');
SET @q = IF(@s=0,
    'ALTER TABLE jenis_sampah ADD COLUMN gambar VARCHAR(255) DEFAULT NULL',
    'SELECT "gambar_exists"');
PREPARE p FROM @q; EXECUTE p; DEALLOCATE PREPARE p;

-- 2. Update existing rows with kategori
UPDATE jenis_sampah SET kategori='Plastik'     WHERE LOWER(nama_sampah) LIKE '%plastik%' AND (kategori IS NULL OR kategori='');
UPDATE jenis_sampah SET kategori='Kardus'      WHERE LOWER(nama_sampah) LIKE '%kardus%'  AND (kategori IS NULL OR kategori='');
UPDATE jenis_sampah SET kategori='Kertas'      WHERE LOWER(nama_sampah) LIKE '%kertas%'  AND (kategori IS NULL OR kategori='');
UPDATE jenis_sampah SET kategori='Logam'       WHERE LOWER(nama_sampah) LIKE '%logam%'   AND (kategori IS NULL OR kategori='');
UPDATE jenis_sampah SET kategori='Kaca'        WHERE LOWER(nama_sampah) LIKE '%kaca%'    AND (kategori IS NULL OR kategori='');
UPDATE jenis_sampah SET kategori='Organik'     WHERE LOWER(nama_sampah) LIKE '%organik%' AND (kategori IS NULL OR kategori='');

-- 3. Seed exact YOLO class rows (7 classes from the model)
INSERT INTO jenis_sampah (nama_sampah, harga_per_kg, deskripsi, satuan, kategori, cara_pengolahan)
SELECT 'Kaca', 500.00, 'Botol kaca, gelas kaca bekas.', 'kg', 'Kaca',
       'Bungkus dengan kertas/koran agar tidak melukai. Kumpulkan ke bank sampah.'
WHERE NOT EXISTS (SELECT 1 FROM jenis_sampah WHERE LOWER(nama_sampah)='kaca');

INSERT INTO jenis_sampah (nama_sampah, harga_per_kg, deskripsi, satuan, kategori, cara_pengolahan)
SELECT 'Kaleng', 1500.00, 'Kaleng minuman, kaleng makanan bekas.', 'kg', 'Logam',
       'Cuci bersih, pipihkan, kumpulkan ke bank sampah.'
WHERE NOT EXISTS (SELECT 1 FROM jenis_sampah WHERE LOWER(nama_sampah)='kaleng');

INSERT INTO jenis_sampah (nama_sampah, harga_per_kg, deskripsi, satuan, kategori, cara_pengolahan)
SELECT 'Kardus', 1500.00, 'Kardus bekas kemasan, dus.', 'kg', 'Kardus',
       'Lipat dan kempiskan kardus, pisahkan dari kotoran, serahkan ke bank sampah.'
WHERE NOT EXISTS (SELECT 1 FROM jenis_sampah WHERE LOWER(nama_sampah)='kardus');

INSERT INTO jenis_sampah (nama_sampah, harga_per_kg, deskripsi, satuan, kategori, cara_pengolahan)
SELECT 'Kertas', 1200.00, 'Kertas HVS, buku, koran, majalah bekas.', 'kg', 'Kertas',
       'Pisahkan kertas bersih dan kering, bundel dan serahkan ke bank sampah.'
WHERE NOT EXISTS (SELECT 1 FROM jenis_sampah WHERE LOWER(nama_sampah)='kertas');

INSERT INTO jenis_sampah (nama_sampah, harga_per_kg, deskripsi, satuan, kategori, cara_pengolahan)
SELECT 'Organik', 0.00, 'Sisa makanan, sayuran, buah-buahan.', 'kg', 'Organik',
       'Olah menjadi kompos atau serahkan ke unit pengolahan organik.'
WHERE NOT EXISTS (SELECT 1 FROM jenis_sampah WHERE LOWER(nama_sampah)='organik');

INSERT INTO jenis_sampah (nama_sampah, harga_per_kg, deskripsi, satuan, kategori, cara_pengolahan)
SELECT 'Plastik HDPE', 2800.00, 'Plastik HDPE: botol shampo, detergen, galon.', 'kg', 'Plastik',
       'Cuci bersih, pisahkan tutupnya, serahkan ke bank sampah.'
WHERE NOT EXISTS (SELECT 1 FROM jenis_sampah WHERE LOWER(nama_sampah) LIKE '%hdpe%');

INSERT INTO jenis_sampah (nama_sampah, harga_per_kg, deskripsi, satuan, kategori, cara_pengolahan)
SELECT 'Plastik PET', 3000.00, 'Botol plastik PET: air mineral, minuman soda.', 'kg', 'Plastik',
       'Cuci bersih, keringkan, kumpulkan ke bank sampah atau pusat daur ulang.'
WHERE NOT EXISTS (SELECT 1 FROM jenis_sampah WHERE LOWER(nama_sampah) LIKE '%pet%' AND LOWER(nama_sampah) LIKE '%plastik%');
