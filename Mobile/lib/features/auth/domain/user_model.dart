class UserModel {
  final int userId;
  final String nama;
  final String email;
  final String role;
  final String? photoUrl;
  final int? warehouseId;
  final String? warehouseName;
  final bool biometricsEnabled;
  final String? biometricsType;

  const UserModel({
    required this.userId, required this.nama, required this.email,
    required this.role, this.photoUrl, this.warehouseId, this.warehouseName,
    required this.biometricsEnabled, this.biometricsType,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    userId: json['user_id'] as int,
    nama: json['nama'] as String,
    email: json['email'] as String,
    role: json['role'] as String,
    photoUrl: json['photo_url'] as String?,
    warehouseId: json['warehouse_id'] as int?,
    warehouseName: json['warehouse_name'] as String?,
    biometricsEnabled: (json['biometrics_enabled'] as num? ?? 0) == 1,
    biometricsType: json['biometrics_type'] as String?,
  );
}
