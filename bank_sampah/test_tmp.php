<?php
$file = sys_get_temp_dir() . "/test_upload.txt";
if (@file_put_contents($file, "test") !== false) {
    echo "WRITE TMP OK: " . $file . "\n";
    unlink($file);
} else {
    echo "WRITE TMP FAILED\n";
}

