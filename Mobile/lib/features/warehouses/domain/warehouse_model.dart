class WarehouseModel {
  final int warehouseId;
  final String namaGudang;
  final String alamat;
  final double? lat;
  final double? lng;
  final DateTime createdAt;

  const WarehouseModel({
    required this.warehouseId,
    required this.namaGudang,
    required this.alamat,
    this.lat,
    this.lng,
    required this.createdAt,
  });

  factory WarehouseModel.fromJson(Map<String, dynamic> json) {
    return WarehouseModel(
      warehouseId: json['warehouse_id'] as int,
      namaGudang: json['nama_gudang'] as String,
      alamat: json['alamat'] as String,
      lat: json['lat'] != null ? double.parse(json['lat'].toString()) : null,
      lng: json['lng'] != null ? double.parse(json['lng'].toString()) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
