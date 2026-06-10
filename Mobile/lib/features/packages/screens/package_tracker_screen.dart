import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/tracker_timeline.dart';
import '../providers/package_detail_provider.dart';

class PackageTrackerScreen extends ConsumerWidget {
  final int packageId;
  const PackageTrackerScreen({super.key, required this.packageId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackerAsync = ref.watch(packageTrackerProvider(packageId));
    final pkgAsync = ref.watch(packageDetailProvider(packageId));

    return Scaffold(
      appBar: AppBar(title: Text(pkgAsync.valueOrNull != null ? 'Riwayat ${pkgAsync.value!.resi}' : 'Riwayat Paket')),
      body: trackerAsync.when(
        loading: () => const LoadingOverlay(),
        error: (e, _) => ErrorView(message: e.toString(), onRetry: () => ref.invalidate(packageTrackerProvider(packageId))),
        data: (entries) {
          if (entries.isEmpty) return const Center(child: Text('Belum ada riwayat'));
          return SingleChildScrollView(padding: const EdgeInsets.all(16), child: TrackerTimeline(entries: entries));
        },
      ),
    );
  }
}
