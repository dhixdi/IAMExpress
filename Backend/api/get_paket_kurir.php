<?php
include 'koneksi.php';

$id_kurir = $_GET['id_kurir'] ?? ''; // Diambil dari URL seperti konsepmu

if (empty($id_kurir)) {
    echo json_encode(["status" => "error", "message" => "ID Kurir kosong"]);
    exit();
}

$sql = "SELECT p.*, w.nama_gudang 
        FROM paket p 
        LEFT JOIN warehouse w ON p.id_warehouse = w.id
        WHERE p.id_kurir = ?"; // Filter khusus ID kurir ini

$stmt = $koneksi->prepare($sql);
$stmt->bind_param("s", $id_kurir);
$stmt->execute();
$result = $stmt->get_result();
$data = array();

if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $data[] = $row;
    }
    echo json_encode(["status" => "success", "data" => $data]);
} else {
    echo json_encode(["status" => "success", "data" => []]);
}
?>