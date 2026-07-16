-- SQL Schema Suggestion for Tukar Poin (Citizen Reward Redemption Module)
-- Run this in MySQL/MariaDB database: db_banksampah

CREATE TABLE IF NOT EXISTS reward_redemptions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  destination_type VARCHAR(50) NOT NULL COMMENT 'Bank Account or E-Wallet',
  provider VARCHAR(100) NOT NULL COMMENT 'e.g., BCA, Mandiri, GoPay, OVO, DANA',
  account_name VARCHAR(150) NOT NULL COMMENT 'Account Holder / Owner Name',
  account_number VARCHAR(100) NOT NULL COMMENT 'Bank Account Number or Phone Number',
  redeem_point INT NOT NULL COMMENT 'Amount of points redeemed',
  conversion_rate INT DEFAULT 10 COMMENT 'Conversion value (e.g. 10 means 1 point = Rp10)',
  estimated_amount DOUBLE NOT NULL COMMENT 'Estimated money amount in Rupiah (redeem_point * conversion_rate)',
  status VARCHAR(50) DEFAULT 'pending' COMMENT 'pending, processing, completed, rejected',
  admin_note TEXT COMMENT 'Notes from admin upon verification or rejection',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  processed_at DATETIME NULL,
  completed_at DATETIME NULL,
  INDEX idx_user_id (user_id),
  INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
