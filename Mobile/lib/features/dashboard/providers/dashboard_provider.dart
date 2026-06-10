import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dashboard_service.dart';
import '../domain/dashboard_model.dart';

final dashboardProvider = FutureProvider.autoDispose<DashboardModel>((ref) {
  return ref.watch(dashboardServiceProvider).get();
});
