-- Create table for storing detection results
-- Run this SQL once (after backup) to create the `deteksi` table used by detect.php and detections.php

CREATE TABLE IF NOT EXISTS `deteksi` (
  `id_deteksi` int(11) NOT NULL AUTO_INCREMENT,
  `id_pengguna` int(11) DEFAULT NULL,
  `uploaded_file` varchar(255) DEFAULT NULL,
  `labels_json` text DEFAULT NULL,
  `matched_json` text DEFAULT NULL,
  `note` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_deteksi`),
  KEY `idx_pengguna` (`id_pengguna`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Optional foreign key (uncomment if ingin memakai dan pastikan referensi tabel pengguna ada)
-- ALTER TABLE `deteksi` ADD CONSTRAINT `deteksi_ibfk_1` FOREIGN KEY (`id_pengguna`) REFERENCES `pengguna` (`id_pengguna`) ON DELETE SET NULL ON UPDATE CASCADE;
