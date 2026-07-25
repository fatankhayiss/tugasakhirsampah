<?php
$file = __DIR__ . "/assets/test.txt";
if (@file_put_contents($file, "test") !== false) {
    echo "Write assets/ OK\n";
    unlink($file);
} else {
    echo "Write assets/ FAILED\n";
}

