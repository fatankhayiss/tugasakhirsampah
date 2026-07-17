-- Tabel password_resets untuk fitur Lupa Password I-Trashy
-- Menyimpan token acak yang aman, email, dan kode OTP dengan masa berlaku tepat 5 menit (300 detik)

CREATE TABLE IF NOT EXISTS `password_resets` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `user_id` INT(11) NOT NULL,
  `email` VARCHAR(255) NULL,
  `token` VARCHAR(255) NOT NULL,
  `otp_code` VARCHAR(10) NULL,
  `reset_token` VARCHAR(255) NULL,
  `created_at` DATETIME NOT NULL,
  `expired_at` DATETIME NOT NULL,
  `used` TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_token_unique` (`token`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_email` (`email`),
  KEY `idx_expired_at` (`expired_at`),
  CONSTRAINT `fk_password_resets_user` FOREIGN KEY (`user_id`) REFERENCES `pengguna` (`id_pengguna`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
