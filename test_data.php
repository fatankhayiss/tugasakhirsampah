<?php
require 'c:/laragon/www/tugasakhirsampah/bank_sampah/config/database.php';
$_SESSION['user_id'] = 1;
$_SESSION['user_level'] = 'admin';
$_SERVER['REQUEST_METHOD'] = 'GET';
ob_start();
require 'c:/laragon/www/tugasakhirsampah/bank_sampah/modules/monitor_ai/data.php';
$out = ob_get_clean();
echo "OUTPUT:\n";
echo substr($out, 0, 1000);
