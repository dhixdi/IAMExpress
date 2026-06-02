<?php
include 'koneksi.php';

$username = $_POST['username'] ?? '';
$password = $_POST['password'] ?? '';

if (empty($username) || empty($password)) {
    echo json_encode(['status' => 'error', 'message' => 'Username dan password wajib diisi']);
    exit();
}

// Hash password dengan MD5 (sesuai database kamu)
$hashedPassword = md5($password);

$sql = "SELECT * FROM users WHERE username = ? AND password = ?";
$stmt = mysqli_prepare($koneksi, $sql);
mysqli_stmt_bind_param($stmt, "ss", $username, $hashedPassword);
mysqli_stmt_execute($stmt);
$result = mysqli_stmt_get_result($stmt);

if (mysqli_num_rows($result) > 0) {
    $user = mysqli_fetch_assoc($result);
    echo json_encode([
        'status' => 'success',
        'message' => 'Login berhasil',
        'data' => [
            'id' => $user['id'],
            'username' => $user['username'],
            'role' => $user['role']
        ]
    ]);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Username atau password salah']);
}

mysqli_stmt_close($stmt);
mysqli_close($koneksi);
?>