<?php
include 'koneksi.php';

$no_resi = $_POST['no_resi'] ?? '';
$status_baru = $_POST['status'] ?? ''; // 'Sedang Diantar' atau 'Selesai'[cite: 5]

if (empty($no_resi) || empty($status_baru)) {
    echo json_encode(["status" => "error", "message" => "Data tidak lengkap"]);
    exit();
}

$sql = "UPDATE paket SET status = ? WHERE no_resi = ?";
$stmt = $koneksi->prepare($sql);
$stmt->bind_param("ss", $status_baru, $no_resi);

if ($stmt->execute()) {
    echo json_encode(["status" => "success", "message" => "Status berhasil diupdate"]);
} else {
    echo json_encode(["status" => "error", "message" => "Gagal update status"]);
}
?>