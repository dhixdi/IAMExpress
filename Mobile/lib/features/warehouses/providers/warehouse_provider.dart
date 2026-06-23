import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/warehouse_service.dart';
import '../domain/warehouse_model.dart';

class WarehouseListState {
  final List<WarehouseModel> warehouses;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;

  const WarehouseListState({
    this.warehouses = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
  });

  WarehouseListState copyWith({
    List<WarehouseModel>? warehouses,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool clearError = false,
  }) {
    return WarehouseListState(
      warehouses: warehouses ?? this.warehouses,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class WarehouseListNotifier extends StateNotifier<WarehouseListState> {
  final WarehouseService _service;
  
  int _currentPage = 1;
  int _totalPages = 1;
  String? _searchQuery;

  WarehouseListNotifier(this._service) : super(const WarehouseListState());

  Future<void> fetchInitial({String? query}) async {
    _searchQuery = query ?? _searchQuery;
    _currentPage = 1;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final res = await _service.getAll(
        page: _currentPage,
        q: _searchQuery,
      );
      _totalPages = res.meta.totalPages;
      state = state.copyWith(warehouses: res.warehouses, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> fetchMore() async {
    if (state.isLoading || state.isLoadingMore || _currentPage >= _totalPages) return;
    
    _currentPage++;
    state = state.copyWith(isLoadingMore: true, clearError: true);
    try {
      final res = await _service.getAll(
        page: _currentPage,
        q: _searchQuery,
      );
      _totalPages = res.meta.totalPages;
      state = state.copyWith(
        warehouses: [...state.warehouses, ...res.warehouses],
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoadingMore: false);
    }
  }

  Future<void> refresh() => fetchInitial();
}

final warehouseListProvider = StateNotifierProvider.autoDispose<WarehouseListNotifier, WarehouseListState>((ref) {
  return WarehouseListNotifier(ref.watch(warehouseServiceProvider));
});

final warehouseDropdownProvider = FutureProvider.autoDispose<List<WarehouseModel>>((ref) {
  return ref.watch(warehouseServiceProvider).getAllSimple();
});
