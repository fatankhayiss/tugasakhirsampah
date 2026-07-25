<?php
$newDir = __DIR__ . "/storage";
if (!is_dir($newDir)) {
    if (@mkdir($newDir, 0777, true)) {
        echo "MKDIR storage/ OK\n";
    } else {
        echo "MKDIR storage/ FAILED\n";
    }
} else {
    echo "storage/ ALREADY EXISTS\n";
}
if (@file_put_contents($newDir . "/test.txt", "test") !== false) {
    echo "WRITE storage/test.txt OK\n";
} else {
    echo "WRITE storage/test.txt FAILED\n";
}

