<?php
$conn = new mysqli('127.0.0.1', 'root', '', 'db_banksampah');
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
$res = $conn->query('SHOW TABLES');
while($r = $res->fetch_row()) {
    echo "Table: " . $r[0] . "\n";
    $cols = $conn->query("DESCRIBE " . $r[0]);
    while($c = $cols->fetch_assoc()) {
        echo "  - " . $c['Field'] . "\n";
    }
}
?>
