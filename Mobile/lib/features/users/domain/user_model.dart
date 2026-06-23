class UserModel {
  final int userId;
  final String email;
  final String nama;
  final String role;
  final int? warehouseId;
  final String? warehouseName;
  final String? photoUrl;
  final bool biometricsEnabled;
  final String? biometricsType;
  final DateTime createdAt;

  const UserModel({
    required this.userId,
    required this.email,
    required this.nama,
    required this.role,
    this.warehouseId,
    this.warehouseName,
    this.photoUrl,
    required this.biometricsEnabled,
    this.biometricsType,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] as int,
      email: json['email'] as String,
      nama: json['nama'] as String,
      role: json['role'] as String,
      warehouseId: json['warehouse_id'] as int?,
      warehouseName: json['warehouse_name'] as String?,
      photoUrl: json['photo_url'] as String?,
      biometricsEnabled: json['biometrics_enabled'] == 1 || json['biometrics_enabled'] == true,
      biometricsType: json['biometrics_type'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
