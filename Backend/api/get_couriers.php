<?php
include 'koneksi.php';
$sql = "SELECT id, username FROM users WHERE role = 'kurir'";
$result = mysqli_query($koneksi, $sql);
$data = [];
while ($row = mysqli_fetch_assoc($result)) $data[] = $row;
echo json_encode(["status" => "success", "data" => $data]);
?>