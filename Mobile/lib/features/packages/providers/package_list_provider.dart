import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/package_service.dart';
import '../domain/package_model.dart';

class PackageListState {
  final List<PackageModel> packages;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final int page;

  const PackageListState({this.packages = const [], this.isLoading = false, this.isLoadingMore = false, this.hasMore = true, this.error, this.page = 1});

  PackageListState copyWith({List<PackageModel>? packages, bool? isLoading, bool? isLoadingMore, bool? hasMore, String? error, int? page}) =>
    PackageListState(packages: packages ?? this.packages, isLoading: isLoading ?? this.isLoading, isLoadingMore: isLoadingMore ?? this.isLoadingMore, hasMore: hasMore ?? this.hasMore, error: error, page: page ?? this.page);
}

class PackageListNotifier extends StateNotifier<PackageListState> {
  final PackageService _service;
  final String? statusFilter;
  String? _query;

  PackageListNotifier(this._service, this.statusFilter) : super(const PackageListState());

  Future<void> fetchInitial({String? query}) async {
    _query = query;
    state = state.copyWith(isLoading: true, error: null, page: 1, hasMore: true, packages: []);
    try {
      final result = await _service.getAll(page: 1, perPage: 10, currentStatus: statusFilter, q: _query);
      state = state.copyWith(packages: result.packages, isLoading: false, hasMore: 1 < result.meta.totalPages, page: 1);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchMore() async {
    if (!state.hasMore || state.isLoadingMore || state.isLoading) return;
    final nextPage = state.page + 1;
    state = state.copyWith(isLoadingMore: true);
    try {
      final result = await _service.getAll(page: nextPage, perPage: 10, currentStatus: statusFilter, q: _query);
      state = state.copyWith(packages: [...state.packages, ...result.packages], isLoadingMore: false, hasMore: nextPage < result.meta.totalPages, page: nextPage);
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> refresh() => fetchInitial(query: _query);
}

final packageListProvider = StateNotifierProvider.family<PackageListNotifier, PackageListState, String?>((ref, statusFilter) {
  return PackageListNotifier(ref.watch(packageServiceProvider), statusFilter);
});
