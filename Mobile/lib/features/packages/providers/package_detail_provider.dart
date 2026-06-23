import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/notifications/notification_service.dart';
import '../data/package_service.dart';
import '../domain/package_model.dart';
import '../domain/tracker_model.dart';

final packageDetailProvider = FutureProvider.family.autoDispose<PackageModel, int>((ref, id) {
  return ref.watch(packageServiceProvider).getById(id);
});

final packageTrackerProvider = FutureProvider.family.autoDispose<List<TrackerModel>, int>((ref, id) {
  return ref.watch(packageServiceProvider).getTracker(id);
});

Future<PackageModel> updatePackageStatus(WidgetRef ref, int id, String status, {String? notes}) async {
  final updated = await ref.read(packageServiceProvider).updateStatus(id, status, notes: notes);
  await NotificationService.showStatusUpdate(resi: updated.resi, newStatus: status);
  ref.invalidate(packageDetailProvider(id));
  ref.invalidate(packageTrackerProvider(id));
  return updated;
}

Future<PackageModel> updatePackageStatusWithPhoto(WidgetRef ref, int id, String status, File photo, {String? notes}) async {
  final updated = await ref.read(packageServiceProvider).updateStatusWithPhoto(id, status, photo, notes: notes);
  await NotificationService.showStatusUpdate(resi: updated.resi, newStatus: status);
  ref.invalidate(packageDetailProvider(id));
  ref.invalidate(packageTrackerProvider(id));
  return updated;
}
