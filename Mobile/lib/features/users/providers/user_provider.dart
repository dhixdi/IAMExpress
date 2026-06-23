import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/user_service.dart';
import '../domain/user_model.dart';

class UserListState {
  final List<UserModel> users;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;

  const UserListState({
    this.users = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
  });

  UserListState copyWith({
    List<UserModel>? users,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool clearError = false,
  }) {
    return UserListState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class UserListNotifier extends StateNotifier<UserListState> {
  final UserService _service;
  final String? _roleFilter;
  
  int _currentPage = 1;
  int _totalPages = 1;
  String? _searchQuery;

  UserListNotifier(this._service, this._roleFilter) : super(const UserListState());

  Future<void> fetchInitial({String? query}) async {
    _searchQuery = query ?? _searchQuery;
    _currentPage = 1;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final res = await _service.getAll(
        page: _currentPage,
        q: _searchQuery,
        role: _roleFilter,
      );
      _totalPages = res.meta.totalPages;
      state = state.copyWith(users: res.users, isLoading: false);
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
        role: _roleFilter,
      );
      _totalPages = res.meta.totalPages;
      state = state.copyWith(
        users: [...state.users, ...res.users],
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoadingMore: false);
    }
  }

  Future<void> refresh() => fetchInitial();
}

final userListProvider = StateNotifierProvider.family.autoDispose<UserListNotifier, UserListState, String?>((ref, roleFilter) {
  return UserListNotifier(ref.watch(userServiceProvider), roleFilter);
});
