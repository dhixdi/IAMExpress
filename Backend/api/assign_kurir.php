<?php
include 'koneksi.php';
$id = $_POST['id'] ?? '';
$id_kurir = $_POST['id_kurir'] ?? '';
if (empty($id) || empty($id_kurir)) {
    echo json_encode(["status" => "error", "message" => "Data tidak lengkap"]);
    exit();
}
$sql = "UPDATE paket SET id_kurir = ? WHERE id = ?";
$stmt = $koneksi->prepare($sql);
$stmt->bind_param("ii", $id_kurir, $id);
if ($stmt->execute()) {
    echo json_encode(["status" => "success", "message" => "Kurir berhasil di-assign"]);
} else {
    echo json_encode(["status" => "error", "message" => "Gagal: " . $stmt->error]);
}
?>