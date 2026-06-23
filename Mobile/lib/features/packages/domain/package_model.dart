class PackageModel {
  final int packageId;
  final String resi;
  final String namaPaket;
  final String alamatPengirim;
  final String alamatTujuan;
  final String noHpPengirim;
  final String noHpPenerima;
  final String? deskripsiBarang;
  final double berat;
  final String jenisLayanan;
  final double ongkosKirim;
  final double? receiverLat;
  final double? receiverLng;
  final String currentStatus;
  final int currentWarehouseId;
  final String? currentWarehouseName;
  final int? destinationWarehouseId;
  final String? destinationWarehouseName;
  final double? destinationWarehouseLat;
  final double? destinationWarehouseLng;
  final String? deliveryPhotoUrl;
  final DateTime? deliveredAt;
  final DateTime createdAt;

  const PackageModel({
    required this.packageId, required this.resi, required this.namaPaket,
    required this.alamatPengirim, required this.alamatTujuan,
    required this.noHpPengirim, required this.noHpPenerima,
    this.deskripsiBarang, required this.berat, required this.jenisLayanan,
    required this.ongkosKirim, this.receiverLat, this.receiverLng,
    required this.currentStatus, required this.currentWarehouseId,
    this.currentWarehouseName, this.destinationWarehouseId,
    this.destinationWarehouseName, this.destinationWarehouseLat,
    this.destinationWarehouseLng, this.deliveryPhotoUrl,
    this.deliveredAt, required this.createdAt,
  });

  static double _toDouble(dynamic v) => v == null ? 0.0 : (v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0.0);
  static double? _toDoubleNullable(dynamic v) => v == null ? null : (v is num ? v.toDouble() : double.tryParse(v.toString()));
  static int _toInt(dynamic v) => v == null ? 0 : (v is int ? v : int.tryParse(v.toString()) ?? 0);

  factory PackageModel.fromJson(Map<String, dynamic> json) => PackageModel(
    packageId: _toInt(json['package_id']),
    resi: json['resi'] as String,
    namaPaket: json['nama_paket'] as String,
    alamatPengirim: json['alamat_pengirim'] as String,
    alamatTujuan: json['alamat_tujuan'] as String,
    noHpPengirim: json['no_hp_pengirim'] as String,
    noHpPenerima: json['no_hp_penerima'] as String,
    deskripsiBarang: json['deskripsi_barang'] as String?,
    berat: _toDouble(json['berat']),
    jenisLayanan: json['jenis_layanan'] as String,
    ongkosKirim: _toDouble(json['ongkos_kirim']),
    receiverLat: _toDoubleNullable(json['receiver_lat']),
    receiverLng: _toDoubleNullable(json['receiver_lng']),
    currentStatus: json['current_status'] as String,
    currentWarehouseId: _toInt(json['current_warehouse_id']),
    currentWarehouseName: json['current_warehouse_name'] as String?,
    destinationWarehouseId: json['destination_warehouse_id'] != null ? _toInt(json['destination_warehouse_id']) : null,
    destinationWarehouseName: json['destination_warehouse_name'] as String?,
    destinationWarehouseLat: _toDoubleNullable(json['destination_warehouse_lat']),
    destinationWarehouseLng: _toDoubleNullable(json['destination_warehouse_lng']),
    deliveryPhotoUrl: json['delivery_photo_url'] as String?,
    deliveredAt: json['delivered_at'] != null ? DateTime.parse(json['delivered_at'].toString()) : null,
    createdAt: DateTime.parse(json['created_at'].toString()),
  );

  factory PackageModel.fromMap(Map<String, dynamic> map) => PackageModel.fromJson(map);

  Map<String, dynamic> toMap() => {
    'package_id': packageId,
    'resi': resi,
    'nama_paket': namaPaket,
    'alamat_pengirim': alamatPengirim,
    'alamat_tujuan': alamatTujuan,
    'no_hp_pengirim': noHpPengirim,
    'no_hp_penerima': noHpPenerima,
    'deskripsi_barang': deskripsiBarang,
    'berat': berat,
    'jenis_layanan': jenisLayanan,
    'ongkos_kirim': ongkosKirim,
    'receiver_lat': receiverLat,
    'receiver_lng': receiverLng,
    'current_status': currentStatus,
    'current_warehouse_id': currentWarehouseId,
    'current_warehouse_name': currentWarehouseName,
    'destination_warehouse_id': destinationWarehouseId,
    'destination_warehouse_name': destinationWarehouseName,
    'destination_warehouse_lat': destinationWarehouseLat,
    'destination_warehouse_lng': destinationWarehouseLng,
    'delivery_photo_url': deliveryPhotoUrl,
    'delivered_at': deliveredAt?.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
  };
}
