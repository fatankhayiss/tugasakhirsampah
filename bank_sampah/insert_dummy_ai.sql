-- SQL Script untuk menambah dummy data AI Scan
INSERT INTO deteksi (id_pengguna, uploaded_file, labels_json, created_at) VALUES 
(NULL, 'assets/uploads/botol pet.jpeg', '["Botol Plastik", "PET", "Dapat didaur ulang"]', NOW() - INTERVAL 5 MINUTE),
(NULL, 'assets/uploads/kardus.jpeg', '["Kardus Bekas", "Kertas", "Dapat didaur ulang"]', NOW() - INTERVAL 15 MINUTE),
(NULL, 'assets/uploads/kaleng.jpeg', '["Kaleng Aluminium", "Logam", "Dapat didaur ulang"]', NOW() - INTERVAL 30 MINUTE),
(NULL, 'assets/uploads/plastik hdpe.jpeg', '["Plastik HDPE", "Botol Sampo", "Dapat didaur ulang"]', NOW() - INTERVAL 45 MINUTE),
(NULL, 'assets/uploads/besi.jpeg', '["Besi Tua", "Logam Berat"]', NOW() - INTERVAL 1 HOUR);
