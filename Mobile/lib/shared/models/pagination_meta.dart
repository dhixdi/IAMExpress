class PaginationMeta {
  final int page;
  final int perPage;
  final int total;
  final int totalPages;

  const PaginationMeta({required this.page, required this.perPage, required this.total, required this.totalPages});

  factory PaginationMeta.fromJson(Map<String, dynamic> json) => PaginationMeta(
    page: json['page'] as int,
    perPage: json['per_page'] as int,
    total: json['total'] as int,
    totalPages: json['total_pages'] as int,
  );
}
