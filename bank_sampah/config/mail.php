<?php
// config/mail.php - PHPMailer Configuration for Gmail SMTP & I-Trashy Notifications
require_once __DIR__ . '/../libs/vendor/autoload.php';

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\SMTP;
use PHPMailer\PHPMailer\Exception;

// Helper untuk memuat file .env (mendukung root project maupun folder bank_sampah)
$env_paths = [
    __DIR__ . '/../.env',
    __DIR__ . '/../../.env',
    __DIR__ . '/.env'
];
foreach ($env_paths as $env_file) {
    if (file_exists($env_file)) {
        $lines = file($env_file, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
        foreach ($lines as $line) {
            $line = trim($line);
            if (strpos($line, '#') === 0) continue;
            if (strpos($line, '=') !== false) {
                list($key, $val) = explode('=', $line, 2);
                $key = trim($key);
                $val = trim(trim($val), '"\'');
                if (!empty($key) && getenv($key) === false) {
                    putenv("{$key}={$val}");
                    $_ENV[$key] = $val;
                }
            }
        }
        break;
    }
}

/**
 * Kirim email menggunakan Gmail SMTP via PHPMailer dengan logging detail dan dukungan Google App Password.
 * 
 * @param string $to_email Tujuan email
 * @param string $to_name Nama tujuan
 * @param string $subject Subjek email
 * @param string $html_body Isi email format HTML
 * @param string|null $alt_body Isi email format teks biasa
 * @return array ['success' => bool, 'error' => string|null]
 */
function send_smtp_email($to_email, $to_name, $subject, $html_body, $alt_body = null) {
    // Memeriksa dan memprioritaskan environment variabel standar (MAIL_*) dengan fallback ke SMTP_*
    $smtp_host = getenv('MAIL_HOST') ?: (getenv('SMTP_HOST') ?: 'smtp.gmail.com');
    $smtp_port = intval(getenv('MAIL_PORT') ?: (getenv('SMTP_PORT') ?: 465));
    $smtp_encryption = getenv('MAIL_ENCRYPTION') ?: (getenv('SMTP_SECURE') ?: ($smtp_port == 587 ? 'tls' : 'ssl'));
    
    $smtp_user = getenv('MAIL_USERNAME') ?: (getenv('SMTP_USER') ?: 'itrashy.id@gmail.com'); 
    $raw_pass  = getenv('MAIL_PASSWORD') ?: (getenv('SMTP_PASS') ?: 'apzortyulmnopqrs');
    
    // Google App Password: hapus spasi jika pengguna memasukkan 16 digit terpisah oleh spasi (misal: "xxxx xxxx xxxx xxxx")
    $smtp_pass = str_replace(' ', '', $raw_pass);

    $sender_email = getenv('MAIL_FROM_ADDRESS') ?: (getenv('SMTP_SENDER_EMAIL') ?: $smtp_user);
    $sender_name  = getenv('MAIL_FROM_NAME') ?: (getenv('SMTP_SENDER_NAME') ?: 'I-Trashy Security');
    $reply_to     = getenv('MAIL_REPLY_TO') ?: 'support@itrashy.id';

    error_log("[SMTP_LOG] Connection Attempt -> Host: {$smtp_host}:{$smtp_port} (Encryption: {$smtp_encryption})");
    error_log("[SMTP_LOG] Authentication Attempt -> Username: {$smtp_user}");

    $mail = new PHPMailer(true);

    try {
        // Pengaturan Server SMTP
        $mail->isSMTP();
        $mail->Host       = $smtp_host;
        $mail->SMTPAuth   = true;
        $mail->Username   = $smtp_user;
        $mail->Password   = $smtp_pass;
        $mail->Timeout    = 30; // Timeout 30 detik agar koneksi stabil
        
        // Atur enkripsi sesuai protokol (SSL untuk port 465, TLS/STARTTLS untuk port 587)
        if (strtolower($smtp_encryption) === 'ssl' || $smtp_port == 465) {
            $mail->SMTPSecure = PHPMailer::ENCRYPTION_SMTPS;
        } elseif (strtolower($smtp_encryption) === 'tls' || $smtp_port == 587) {
            $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
        } else {
            $mail->SMTPSecure = PHPMailer::ENCRYPTION_SMTPS;
        }

        $mail->Port    = $smtp_port;
        $mail->CharSet = 'UTF-8';

        // Pengaturan Pengirim & Penerima
        $mail->setFrom($sender_email, $sender_name);
        $mail->addAddress($to_email, $to_name);
        $mail->addReplyTo($reply_to, $sender_name);

        // Konten Email
        $mail->isHTML(true);
        $mail->Subject = $subject;
        $mail->Body    = $html_body;
        if ($alt_body) {
            $mail->AltBody = $alt_body;
        } else {
            $mail->AltBody = strip_tags($html_body);
        }

        $mail->send();
        error_log("[SMTP_LOG] Mail Send Result -> SUCCESS: Email delivered to {$to_email}");
        return ['success' => true, 'error' => null];
    } catch (Exception $e) {
        $error_msg = $mail->ErrorInfo ?: $e->getMessage();
        error_log("[SMTP_LOG] Mail Send Result -> FAILED: Delivery error to {$to_email}. Exception Message: {$error_msg}");
        
        // Pesan diagnostik khusus jika terjadi kegagalan autentikasi Gmail
        if (stripos($error_msg, 'Could not authenticate') !== false || stripos($error_msg, 'Username and Password not accepted') !== false) {
            $error_msg .= " (Catatan: Pastikan Anda menggunakan 16-digit Google App Password di variabel MAIL_PASSWORD atau SMTP_PASS pada file .env, bukan password biasa akun Gmail Anda.)";
        }
        
        return ['success' => false, 'error' => $error_msg];
    }
}
