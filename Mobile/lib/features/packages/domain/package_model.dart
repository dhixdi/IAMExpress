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
  final DateTime createdAt;

  const PackageModel({
    required this.packageId, required this.resi, required this.namaPaket,
    required this.alamatPengirim, required this.alamatTujuan,
    required this.noHpPengirim, required this.noHpPenerima,
    this.deskripsiBarang, required this.berat, required this.jenisLayanan,
    required this.ongkosKirim, this.receiverLat, this.receiverLng,
    required this.currentStatus, required this.currentWarehouseId,
    this.currentWarehouseName, required this.createdAt,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) => PackageModel(
    packageId: json['package_id'] as int,
    resi: json['resi'] as String,
    namaPaket: json['nama_paket'] as String,
    alamatPengirim: json['alamat_pengirim'] as String,
    alamatTujuan: json['alamat_tujuan'] as String,
    noHpPengirim: json['no_hp_pengirim'] as String,
    noHpPenerima: json['no_hp_penerima'] as String,
    deskripsiBarang: json['deskripsi_barang'] as String?,
    berat: (json['berat'] as num).toDouble(),
    jenisLayanan: json['jenis_layanan'] as String,
    ongkosKirim: (json['ongkos_kirim'] as num).toDouble(),
    receiverLat: (json['receiver_lat'] as num?)?.toDouble(),
    receiverLng: (json['receiver_lng'] as num?)?.toDouble(),
    currentStatus: json['current_status'] as String,
    currentWarehouseId: json['current_warehouse_id'] as int,
    currentWarehouseName: json['warehouse_name'] as String?,
    createdAt: DateTime.parse(json['created_at'] as String),
  );
}
