<?php
echo "Setting permissions...\n";
$dirs = [
    __DIR__ . "/assets/uploads",
    __DIR__ . "/assets/uploads/profil"
];

foreach ($dirs as $dir) {
    if (!is_dir($dir)) {
        if (mkdir($dir, 0777, true)) {
            echo "Created: $dir\n";
        } else {
            echo "Failed to create: $dir\n";
        }
    }
    
    if (chmod($dir, 0777)) {
        echo "Chmod 0777 success: $dir\n";
    } else {
        echo "Chmod 0777 failed: $dir\n";
    }
}
echo "Done.\n";
