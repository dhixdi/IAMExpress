class DashboardModel {
  final int totalDitugaskan;
  final int sedangDikerjakan;
  final int selesaiHariIni;

  const DashboardModel({required this.totalDitugaskan, required this.sedangDikerjakan, required this.selesaiHariIni});

  factory DashboardModel.fromJson(Map<String, dynamic> json) => DashboardModel(
    totalDitugaskan: json['total_ditugaskan'] as int? ?? 0,
    sedangDikerjakan: json['sedang_dikerjakan'] as int? ?? 0,
    selesaiHariIni: json['selesai_hari_ini'] as int? ?? 0,
  );
}
