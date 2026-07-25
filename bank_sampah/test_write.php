<?php
$file = __DIR__ . "/assets/uploads/test.txt";
if (@file_put_contents($file, "test") !== false) {
    echo "Write OK\n";
    unlink($file);
} else {
    echo "Write FAILED\n";
}

