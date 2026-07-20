<?php

function bs_api_json_response($success, $message, $data = null, $statusCode = 200) {
    http_response_code($statusCode);
    $response = ['success' => $success, 'message' => $message];
    if ($data !== null) {
        $response['data'] = $data;
    }
    echo json_encode($response);
    exit;
}

function bs_api_setup_headers($allowedMethods = 'POST, OPTIONS') {
    $origin = $_SERVER['HTTP_ORIGIN'] ?? '';
    $allowedOriginsRaw = getenv('API_ALLOWED_ORIGINS') ?: '*';
    $allowedOrigins = array_filter(array_map('trim', explode(',', $allowedOriginsRaw)));

    $allowAny = in_array('*', $allowedOrigins, true);
    $originAllowed = $allowAny || ($origin !== '' && in_array($origin, $allowedOrigins, true));

    if ($allowAny) {
        header('Access-Control-Allow-Origin: *');
    } elseif ($originAllowed) {
        header('Access-Control-Allow-Origin: ' . $origin);
        header('Vary: Origin');
    }

    header('Content-Type: application/json; charset=utf-8');
    header('Access-Control-Allow-Methods: ' . $allowedMethods);
    header('Access-Control-Allow-Headers: Content-Type, Accept, Authorization');
}

function bs_api_enforce_origin_policy() {
    $origin = $_SERVER['HTTP_ORIGIN'] ?? '';
    $allowedOriginsRaw = getenv('API_ALLOWED_ORIGINS') ?: '*';
    $allowedOrigins = array_filter(array_map('trim', explode(',', $allowedOriginsRaw)));

    if (in_array('*', $allowedOrigins, true) || $origin === '') {
        return;
    }

    if (!in_array($origin, $allowedOrigins, true)) {
        bs_api_json_response(false, 'Origin tidak diizinkan.', null, 403);
    }
}

function bs_api_handle_options() {
    if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
        bs_api_json_response(true, 'Preflight OK');
    }
}

function bs_api_client_ip() {
    $forwarded = $_SERVER['HTTP_X_FORWARDED_FOR'] ?? '';
    if (!empty($forwarded)) {
        $parts = explode(',', $forwarded);
        return trim($parts[0]);
    }
    return $_SERVER['REMOTE_ADDR'] ?? 'unknown';
}

function bs_api_rate_limit($action, $maxRequests, $windowSeconds) {
    $ip = bs_api_client_ip();
    $key = preg_replace('/[^a-zA-Z0-9_\-]/', '_', $action . '_' . $ip);
    $file = sys_get_temp_dir() . DIRECTORY_SEPARATOR . 'itrashy_api_rate_' . md5($key) . '.json';
    $now = time();

    $bucket = ['window_start' => $now, 'count' => 0];

    $fp = fopen($file, 'c+');
    if ($fp === false) {
        return;
    }

    try {
        if (!flock($fp, LOCK_EX)) {
            return;
        }

        $content = stream_get_contents($fp);
        if (!empty($content)) {
            $decoded = json_decode($content, true);
            if (is_array($decoded) && isset($decoded['window_start'], $decoded['count'])) {
                $bucket = $decoded;
            }
        }

        if (($now - (int)$bucket['window_start']) >= $windowSeconds) {
            $bucket['window_start'] = $now;
            $bucket['count'] = 0;
        }

        $bucket['count'] = (int)$bucket['count'] + 1;

        if ($bucket['count'] > $maxRequests) {
            $retryAfter = max(1, $windowSeconds - ($now - (int)$bucket['window_start']));
            header('Retry-After: ' . $retryAfter);
            bs_api_json_response(false, 'Terlalu banyak permintaan. Coba lagi nanti.', null, 429);
        }

        ftruncate($fp, 0);
        rewind($fp);
        fwrite($fp, json_encode($bucket));
    } finally {
        flock($fp, LOCK_UN);
        fclose($fp);
    }
}
