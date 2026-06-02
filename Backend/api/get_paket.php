 <?php
// Panggil jembatan koneksi
include 'koneksi.php';

// Ambil data paket dan gabungkan dengan nama gudang
$sql = "SELECT p.*, w.nama_gudang 
        FROM paket p 
        LEFT JOIN warehouse w ON p.id_warehouse = w.id";

$result = mysqli_query($koneksi, $sql);
$data = array();

if (mysqli_num_rows($result) > 0) {
    while ($row = mysqli_fetch_assoc($result)) {
        $data[] = $row;
    }
    
    // Cetak ke format JSON
    echo json_encode([
        "status" => "success",
        "total_data" => count($data),
        "data" => $data
    ]);
} else {
    echo json_encode([
        "status" => "success",
        "total_data" => 0,
        "data" => []
    ]);
}

mysqli_close($koneksi);
?>