-- SQL Schema for Tukar Poin Audit Logs
CREATE TABLE IF NOT EXISTS redemption_audit_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  redemption_id INT NOT NULL,
  transaction_code VARCHAR(50) NULL,
  action VARCHAR(50) NOT NULL COMMENT 'SUBMIT_REQUEST, PROCESS, COMPLETE, REJECT',
  old_status VARCHAR(50) NOT NULL,
  new_status VARCHAR(50) NOT NULL,
  admin_id INT NULL,
  reason TEXT NULL COMMENT 'Note/Reason especially for rejection',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_redemption_id (redemption_id),
  INDEX idx_transaction_code (transaction_code),
  INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
