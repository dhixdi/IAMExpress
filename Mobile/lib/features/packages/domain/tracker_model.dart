class TrackerModel {
  final int trackId;
  final String status;
  final String? notes;
  final String? warehouseName;
  final String changedByName;
  final DateTime timestamp;

  const TrackerModel({required this.trackId, required this.status, this.notes, this.warehouseName, required this.changedByName, required this.timestamp});

  factory TrackerModel.fromJson(Map<String, dynamic> json) => TrackerModel(
    trackId: json['track_id'] as int,
    status: json['status'] as String,
    notes: json['notes'] as String?,
    warehouseName: json['nama_gudang'] as String? ?? json['warehouse_name'] as String?,
    changedByName: json['changed_by_name'] as String? ?? '-',
    timestamp: DateTime.parse(json['timestamp'] as String),
  );
}
