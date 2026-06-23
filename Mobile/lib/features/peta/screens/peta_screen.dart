import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../packages/domain/package_model.dart';
import '../../packages/providers/package_list_provider.dart';
import '../../auth/providers/auth_provider.dart';

class PetaScreen extends ConsumerStatefulWidget {
  const PetaScreen({super.key});
  @override
  ConsumerState<PetaScreen> createState() => _PetaScreenState();
}

class _PetaScreenState extends ConsumerState<PetaScreen> {
  Position? _userPos;

  @override
  void initState() {
    super.initState();
    _getLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = ref.read(packageListProvider(null));
      if (s.packages.isEmpty) ref.read(packageListProvider(null).notifier).fetchInitial();
    });
  }

  Future<void> _getLocation() async {
    try {
      final perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) return;
      final pos = await Geolocator.getCurrentPosition();
      if (mounted) setState(() => _userPos = pos);
    } catch (_) {}
  }

  void _showPackageInfo(PackageModel pkg, String role) {
    final isLinehaul = role == 'LINEHAUL';
    final targetLat = isLinehaul ? pkg.destinationWarehouseLat : pkg.receiverLat;
    final targetLng = isLinehaul ? pkg.destinationWarehouseLng : pkg.receiverLng;

    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(pkg.resi, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(pkg.namaPaket, style: const TextStyle(fontSize: 14)),
          if (isLinehaul && pkg.destinationWarehouseName != null)
            Text('Tujuan: Gudang ${pkg.destinationWarehouseName}', style: const TextStyle(fontSize: 13, color: AppColors.textMuted))
          else
            Text(pkg.alamatTujuan, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
          Text('Status: ${pkg.currentStatus}', style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (targetLat != null && targetLng != null) {
                  _openGoogleMaps(targetLat, targetLng);
                }
              },
              icon: const Icon(Icons.directions),
              label: const Text('Buka di Google Maps'),
            ),
          ),
        ]),
      ),
    );
  }

  Future<void> _openGoogleMaps(double lat, double lng) async {
    final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(packageListProvider(null));
    final userRole = ref.watch(authProvider).user?.role ?? '';
    final isLinehaul = userRole == 'LINEHAUL';

    final activePackages = state.packages.where((p) {
      if (isLinehaul) {
        final validStatus = p.currentStatus == 'Picked Up' || p.currentStatus == 'In Transit';
        return validStatus && p.destinationWarehouseLat != null && p.destinationWarehouseLng != null;
      }
      if (userRole == 'COURIER') {
        return p.currentStatus == 'Out For Delivery' && p.receiverLat != null && p.receiverLng != null;
      }
      // Admin roles: show all packages with coordinates
      return p.receiverLat != null && p.receiverLng != null;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Peta Paket')),
      body: FlutterMap(
        options: MapOptions(initialCenter: _userPos != null ? LatLng(_userPos!.latitude, _userPos!.longitude) : const LatLng(-7.7972, 110.3688), initialZoom: 11),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.tugas_akhir',
          ),
          MarkerLayer(markers: [
            if (_userPos != null) Marker(point: LatLng(_userPos!.latitude, _userPos!.longitude), child: const Icon(Icons.my_location, color: AppColors.info, size: 32)),
            ...activePackages.map((pkg) {
              final lat = isLinehaul ? pkg.destinationWarehouseLat! : pkg.receiverLat!;
              final lng = isLinehaul ? pkg.destinationWarehouseLng! : pkg.receiverLng!;
              return Marker(
                point: LatLng(lat, lng),
                child: GestureDetector(onTap: () => _showPackageInfo(pkg, userRole), child: const Icon(Icons.location_pin, color: AppColors.accent, size: 36)),
              );
            }),
          ]),
        ],
      ),
    );
  }
}
