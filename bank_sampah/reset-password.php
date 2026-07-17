<?php
// reset-password.php - Fitur Reset Password (I-Trashy)
// Sesuai dengan spesifikasi Security, UI/UX Material Design 3, & Green Theme
date_default_timezone_set('Asia/Jakarta');
require_once __DIR__ . '/config/database.php';

// Pastikan tabel password_resets tersedia
mysqli_query($koneksi, "CREATE TABLE IF NOT EXISTS `password_resets` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `user_id` INT(11) NOT NULL,
  `token` VARCHAR(255) NOT NULL,
  `created_at` DATETIME NOT NULL,
  `expired_at` DATETIME NOT NULL,
  `used` TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_token_unique` (`token`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_expired_at` (`expired_at`),
  CONSTRAINT `fk_password_resets_user` FOREIGN KEY (`user_id`) REFERENCES `pengguna` (`id_pengguna`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;");

$token = isset($_GET['token']) ? trim($_GET['token']) : (isset($_POST['token']) ? trim($_POST['token']) : '');
$state = 'INVALID'; // States: MISSING, INVALID, EXPIRED, USED, FORM, SUCCESS
$error_message = '';
$user_id = 0;
$reset_id = 0;

if (empty($token)) {
    $state = 'MISSING';
} else {
    $stmt = mysqli_prepare($koneksi, "SELECT id, user_id, expired_at, used FROM password_resets WHERE token = ? LIMIT 1");
    if ($stmt) {
        mysqli_stmt_bind_param($stmt, "s", $token);
        mysqli_stmt_execute($stmt);
        $result = mysqli_stmt_get_result($stmt);
        if ($row = mysqli_fetch_assoc($result)) {
            $reset_id = $row['id'];
            $user_id = $row['user_id'];
            $expired_at = strtotime($row['expired_at']);
            
            if ($row['used'] == 1) {
                $state = 'USED';
            } elseif (time() > $expired_at) {
                $state = 'EXPIRED';
            } else {
                $state = 'FORM';
            }
        } else {
            $state = 'INVALID';
        }
        mysqli_stmt_close($stmt);
    } else {
        $state = 'INVALID';
    }
}

// Proses form submission
if ($state === 'FORM' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    $new_password = isset($_POST['new_password']) ? $_POST['new_password'] : '';
    $confirm_password = isset($_POST['confirm_password']) ? $_POST['confirm_password'] : '';

    if (empty($new_password)) {
        $error_message = 'Password baru wajib diisi.';
    } elseif (strlen($new_password) < 8) {
        $error_message = 'Password minimal harus 8 karakter.';
    } elseif (!preg_match('/[a-zA-Z]/', $new_password)) {
        $error_message = 'Password harus mengandung huruf.';
    } elseif (!preg_match('/[0-9]/', $new_password)) {
        $error_message = 'Password harus mengandung angka.';
    } elseif ($new_password !== $confirm_password) {
        $error_message = 'Konfirmasi password tidak cocok dengan password baru.';
    } else {
        // Hash password baru dengan password_hash()
        $hashed_password = password_hash($new_password, PASSWORD_DEFAULT);
        
        // Update password pengguna
        $stmt_up = mysqli_prepare($koneksi, "UPDATE pengguna SET password = ? WHERE id_pengguna = ?");
        mysqli_stmt_bind_param($stmt_up, "si", $hashed_password, $user_id);
        if (mysqli_stmt_execute($stmt_up)) {
            mysqli_stmt_close($stmt_up);
            
            // Tandai token segera agar tidak bisa digunakan ulang
            $stmt_used = mysqli_prepare($koneksi, "UPDATE password_resets SET used = 1 WHERE id = ?");
            mysqli_stmt_bind_param($stmt_used, "i", $reset_id);
            mysqli_stmt_execute($stmt_used);
            mysqli_stmt_close($stmt_used);
            
            $state = 'SUCCESS';
        } else {
            $error_message = 'Terjadi kesalahan sistem saat memperbarui password: ' . mysqli_error($koneksi);
            mysqli_stmt_close($stmt_up);
        }
    }
}
?>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reset Password - I-Trashy</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <script>
      tailwind.config = {
        theme: {
          extend: {
            colors: {
              emerald: {
                50: '#ecfdf5',
                100: '#d1fae5',
                200: '#a7f3d0',
                500: '#10b981',
                600: '#059669',
                700: '#047857',
                800: '#065f46',
                900: '#064e3b',
              }
            },
            fontFamily: {
              sans: ['Poppins', 'Inter', 'sans-serif'],
            }
          }
        }
      }
    </script>
    <style>
        body {
            font-family: 'Poppins', 'Inter', sans-serif;
            background: linear-gradient(135deg, #059669 0%, #10b981 50%, #047857 100%);
            min-height: 100vh;
        }
    </style>
</head>
<body class="flex items-center justify-center p-4 min-h-screen">

    <div class="max-w-md w-full bg-white rounded-3xl shadow-2xl overflow-hidden transition-all duration-300">
        <!-- Brand Header / Logo -->
        <div class="bg-emerald-50 px-8 pt-8 pb-6 text-center border-b border-emerald-100">
            <div class="inline-flex items-center justify-center w-16 h-16 bg-emerald-100 rounded-full text-emerald-600 mb-3 shadow-sm">
                <i class="fas fa-recycle text-3xl"></i>
            </div>
            <h1 class="text-xl font-bold tracking-tight text-emerald-900">I-Trashy</h1>
            <p class="text-xs text-emerald-600 font-medium tracking-wide uppercase mt-0.5">Bank Sampah Digital</p>
        </div>

        <div class="p-8">
            <?php if ($state === 'FORM'): ?>
                <!-- RESET PASSWORD FORM (MATERIAL DESIGN 3) -->
                <div class="text-center mb-6">
                    <h2 class="text-2xl font-bold text-gray-900">Reset Password</h2>
                    <p class="text-sm text-gray-500 mt-1">Masukkan kata sandi baru untuk akun Anda.</p>
                </div>

                <?php if (!empty($error_message)): ?>
                    <div class="mb-6 p-4 rounded-2xl bg-red-50 border border-red-200 flex items-start space-x-3 text-red-700 text-sm animate-pulse">
                        <i class="fas fa-exclamation-circle mt-0.5 text-red-500 flex-shrink-0"></i>
                        <span><?= htmlspecialchars($error_message) ?></span>
                    </div>
                <?php endif; ?>

                <form action="" method="POST" class="space-y-5">
                    <input type="hidden" name="token" value="<?= htmlspecialchars($token) ?>">
                    
                    <div>
                        <label for="new_password" class="block text-sm font-semibold text-gray-700 mb-1.5">New Password</label>
                        <div class="relative rounded-2xl shadow-sm">
                            <div class="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none text-gray-400">
                                <i class="fas fa-lock"></i>
                            </div>
                            <input type="password" name="new_password" id="new_password" required minlength="8"
                                   placeholder="Minimal 8 karakter (huruf & angka)"
                                   class="block w-full pl-11 pr-11 py-3.5 border border-gray-300 rounded-2xl text-gray-900 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 text-sm transition duration-200">
                            <button type="button" onclick="togglePassword('new_password', 'toggleIconNew')" class="absolute inset-y-0 right-0 pr-4 flex items-center text-gray-400 hover:text-emerald-600 focus:outline-none">
                                <i id="toggleIconNew" class="fas fa-eye"></i>
                            </button>
                        </div>
                        <p class="text-xs text-gray-400 mt-1.5 pl-1"><i class="fas fa-info-circle mr-1"></i>Min. 8 karakter, wajib kombinasi huruf dan angka.</p>
                    </div>

                    <div>
                        <label for="confirm_password" class="block text-sm font-semibold text-gray-700 mb-1.5">Confirm Password</label>
                        <div class="relative rounded-2xl shadow-sm">
                            <div class="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none text-gray-400">
                                <i class="fas fa-check-double"></i>
                            </div>
                            <input type="password" name="confirm_password" id="confirm_password" required minlength="8"
                                   placeholder="Ulangi kata sandi baru"
                                   class="block w-full pl-11 pr-11 py-3.5 border border-gray-300 rounded-2xl text-gray-900 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 text-sm transition duration-200">
                            <button type="button" onclick="togglePassword('confirm_password', 'toggleIconConfirm')" class="absolute inset-y-0 right-0 pr-4 flex items-center text-gray-400 hover:text-emerald-600 focus:outline-none">
                                <i id="toggleIconConfirm" class="fas fa-eye"></i>
                            </button>
                        </div>
                    </div>

                    <div class="pt-2">
                        <button type="submit"
                                class="w-full py-4 px-6 rounded-2xl shadow-lg bg-emerald-600 hover:bg-emerald-700 active:bg-emerald-800 text-white font-semibold text-sm tracking-wide transition duration-200 flex items-center justify-center space-x-2">
                            <span>Reset Password Button</span>
                            <i class="fas fa-arrow-right text-xs opacity-80"></i>
                        </button>
                    </div>
                </form>

            <?php elseif ($state === 'SUCCESS'): ?>
                <!-- SUCCESS PAGE (MATERIAL 3 SUCCESS DIALOG) -->
                <div class="text-center py-4">
                    <div class="inline-flex items-center justify-center w-20 h-20 bg-emerald-100 text-emerald-600 rounded-full mb-6 shadow-inner">
                        <i class="fas fa-check text-4xl"></i>
                    </div>
                    <h2 class="text-2xl font-bold text-gray-900">Password Updated</h2>
                    <p class="text-sm text-gray-600 mt-2 leading-relaxed px-4">
                        Your password has been successfully updated. Anda sekarang dapat masuk menggunakan kata sandi baru Anda.
                    </p>
                    <div class="mt-8">
                        <a href="index.php" 
                           class="inline-block w-full py-4 px-6 rounded-2xl shadow-lg bg-emerald-600 hover:bg-emerald-700 text-white font-semibold text-sm transition duration-200">
                            Back to Login
                        </a>
                    </div>
                </div>

            <?php elseif ($state === 'EXPIRED'): ?>
                <!-- EXPIRED TOKEN PAGE -->
                <div class="text-center py-4">
                    <div class="inline-flex items-center justify-center w-20 h-20 bg-amber-100 text-amber-600 rounded-full mb-6 shadow-inner">
                        <i class="fas fa-clock text-4xl"></i>
                    </div>
                    <h2 class="text-2xl font-bold text-gray-900">Reset Link Expired</h2>
                    <p class="text-sm text-gray-600 mt-2 leading-relaxed px-2">
                        This password reset link has expired. Masa berlaku tautan adalah tepat 5 menit.<br>
                        Please request a new password reset.
                    </p>
                    <div class="mt-8 space-y-3">
                        <a href="index.php" 
                           class="block w-full py-4 px-6 rounded-2xl shadow-md bg-gray-100 hover:bg-gray-200 text-gray-700 font-semibold text-sm transition duration-200">
                            Back to Login
                        </a>
                        <button onclick="alert('Silakan buka aplikasi I-Trashy dan klik menu Lupa Password untuk meminta link baru.')" 
                           class="block w-full py-4 px-6 rounded-2xl shadow-lg bg-emerald-600 hover:bg-emerald-700 text-white font-semibold text-sm transition duration-200">
                            Request New Link
                        </button>
                    </div>
                </div>

            <?php elseif ($state === 'USED'): ?>
                <!-- USED TOKEN PAGE -->
                <div class="text-center py-4">
                    <div class="inline-flex items-center justify-center w-20 h-20 bg-red-100 text-red-600 rounded-full mb-6 shadow-inner">
                        <i class="fas fa-ban text-4xl"></i>
                    </div>
                    <h2 class="text-2xl font-bold text-gray-900">Link Already Used</h2>
                    <p class="text-sm text-gray-600 mt-2 leading-relaxed px-2">
                        Tautan reset password ini sudah pernah digunakan sebelumnya.<br>
                        Setiap link hanya berlaku untuk 1 kali reset.
                    </p>
                    <div class="mt-8">
                        <a href="index.php" 
                           class="block w-full py-4 px-6 rounded-2xl shadow-lg bg-emerald-600 hover:bg-emerald-700 text-white font-semibold text-sm transition duration-200">
                            Back to Login
                        </a>
                    </div>
                </div>

            <?php else: ?>
                <!-- MISSING OR INVALID TOKEN PAGE -->
                <div class="text-center py-4">
                    <div class="inline-flex items-center justify-center w-20 h-20 bg-red-100 text-red-600 rounded-full mb-6 shadow-inner">
                        <i class="fas fa-exclamation-triangle text-4xl"></i>
                    </div>
                    <h2 class="text-2xl font-bold text-gray-900">Invalid Reset Link</h2>
                    <p class="text-sm text-gray-600 mt-2 leading-relaxed px-2">
                        Tautan reset password tidak valid atau tidak ditemukan di sistem.<br>
                        Pastikan Anda menyalin URL dengan lengkap dari email Anda.
                    </p>
                    <div class="mt-8">
                        <a href="index.php" 
                           class="block w-full py-4 px-6 rounded-2xl shadow-lg bg-emerald-600 hover:bg-emerald-700 text-white font-semibold text-sm transition duration-200">
                            Back to Login
                        </a>
                    </div>
                </div>
            <?php endif; ?>
        </div>

        <div class="bg-gray-50 py-4 px-8 text-center border-t border-gray-100 text-xs text-gray-400">
            &copy; <?= date('Y') ?> I-Trashy Bank Sampah Digital. Secure Authentication.
        </div>
    </div>

    <script>
        function togglePassword(inputId, iconId) {
            const input = document.getElementById(inputId);
            const icon = document.getElementById(iconId);
            if (input.type === 'password') {
                input.type = 'text';
                icon.classList.remove('fa-eye');
                icon.classList.add('fa-eye-slash');
            } else {
                input.type = 'password';
                icon.classList.remove('fa-eye-slash');
                icon.classList.add('fa-eye');
            }
        }
    </script>
</body>
</html>
