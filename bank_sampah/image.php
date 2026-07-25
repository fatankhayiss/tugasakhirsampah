<?php
require_once __DIR__ . "/config/database.php";

$type = isset($_GET["type"]) ? $_GET["type"] : "";
$id = isset($_GET["id"]) ? intval($_GET["id"]) : 0;

if (!$type || !$id) {
    http_response_code(400);
    exit;
}

$b64 = null;

if ($type === "profil") {
    $stmt = mysqli_prepare($koneksi, "SELECT foto_profil_b64 FROM pengguna WHERE id_pengguna = ? LIMIT 1");
    mysqli_stmt_bind_param($stmt, "i", $id);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);
    if ($row = mysqli_fetch_assoc($result)) {
        $b64 = $row["foto_profil_b64"];
    }
} else if ($type === "proof") {
    $stmt = mysqli_prepare($koneksi, "SELECT transfer_proof_b64 FROM reward_redemptions WHERE id = ? LIMIT 1");
    mysqli_stmt_bind_param($stmt, "i", $id);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);
    if ($row = mysqli_fetch_assoc($result)) {
        $b64 = $row["transfer_proof_b64"];
    }
}

if (!$b64) {
    http_response_code(404);
    exit;
}

// Ensure it starts with data:image
if (strpos($b64, "data:image") === 0) {
    list($meta, $data) = explode(",", $b64, 2);
    // meta format: data:image/jpeg;base64
    $mime = "image/jpeg";
    if (preg_match("/data:(image\/[a-zA-Z0-9]+);base64/", $meta, $matches)) {
        $mime = $matches[1];
    }
    $decoded = base64_decode($data);
    header("Content-Type: " . $mime);
    header("Content-Length: " . strlen($decoded));
    // Cache control
    header("Cache-Control: public, max-age=86400");
    echo $decoded;
    exit;
}

http_response_code(404);

