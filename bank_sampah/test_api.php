<?php
$ch = curl_init('http://192.168.167.68/tugasakhirsampah/bank_sampah/modules/api/auth_api.php?action=register');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, [
    'nama_lengkap' => 'Test Driver 2',
    'username' => 'testdriver2',
    'no_telepon' => '081234567891',
    'password' => 'password123',
    'alamat' => 'Jalan Test',
    'level' => 'driver',
    'kecamatan' => 'Test Kec',
    'kab_kota' => 'Test Kab',
    'wilayah' => 'Test Wil',
    'kode_pos' => '12345',
    'tipe_kendaraan' => 'Motor',
    'jenis_kendaraan' => 'Beat',
    'plat_nomor' => 'B 1234 CD',
    'kapasitas_berat' => '10'
]);
$response = curl_exec($ch);
echo "Response:\n";
echo $response;
?>
