<?php
include 'koneksi.php';

$API_KEY = 'AIzaSyBFgvUR7-zhtNo6um7Nvvr-2cOXS2INO6U'; // Aman di server

$input = json_decode(file_get_contents('php://input'), true);
$contents = $input['contents'] ?? [];

if (empty($contents)) {
    header('Content-Type: application/json');
    echo json_encode([
        "error" => [
            "message" => "Request ditolak: Tidak ada pesan yang dikirim dari aplikasi.",
            "status" => "EMPTY_INPUT"
        ]
    ]);
    exit;
}

$url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$API_KEY";

$ch = curl_init($url);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode([
    'system_instruction' => ['parts' => [['text' => 'Kamu adalah asisten kurir pengiriman paket bernama "Pintar". Jawab singkat, praktis, dalam Bahasa Indonesia.']]],
    'contents' => $contents
]));
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$response = curl_exec($ch);
curl_close($ch);

echo $response;
?>