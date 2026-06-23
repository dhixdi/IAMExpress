class DashboardModel {
  final int totalDitugaskan;
  final int sedangDikerjakan;
  final int selesaiHariIni;
  // Super Admin fields
  final int? totalWarehouse;
  final int? totalUser;
  final int? totalPaketAktif;
  final int? totalDelivered;
  // Warehouse Admin fields
  final int? paketDiWarehouse;
  final int? menungguLinehaul;
  final int? menungguCourier;
  final int? deliveredHariIni;

  const DashboardModel({
    required this.totalDitugaskan,
    required this.sedangDikerjakan,
    required this.selesaiHariIni,
    this.totalWarehouse,
    this.totalUser,
    this.totalPaketAktif,
    this.totalDelivered,
    this.paketDiWarehouse,
    this.menungguLinehaul,
    this.menungguCourier,
    this.deliveredHariIni,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) => DashboardModel(
    totalDitugaskan: json['total_ditugaskan'] as int? ?? json['total_paket_aktif'] as int? ?? json['paket_di_warehouse'] as int? ?? 0,
    sedangDikerjakan: json['sedang_dikerjakan'] as int? ?? json['menunggu_linehaul'] as int? ?? 0,
    selesaiHariIni: json['selesai_hari_ini'] as int? ?? json['delivered_hari_ini'] as int? ?? json['total_delivered'] as int? ?? 0,
    totalWarehouse: json['total_warehouse'] as int?,
    totalUser: json['total_user'] as int?,
    totalPaketAktif: json['total_paket_aktif'] as int?,
    totalDelivered: json['total_delivered'] as int?,
    paketDiWarehouse: json['paket_di_warehouse'] as int?,
    menungguLinehaul: json['menunggu_linehaul'] as int?,
    menungguCourier: json['menunggu_courier'] as int?,
    deliveredHariIni: json['delivered_hari_ini'] as int?,
  );
}
