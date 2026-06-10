import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../features/packages/domain/package_model.dart';
import '../utils/format_currency.dart';
import 'status_badge.dart';

class PackageCard extends StatelessWidget {
  final PackageModel package;
  final VoidCallback? onTap;
  const PackageCard({super.key, required this.package, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(package.resi, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary))),
                  StatusBadge(status: package.currentStatus),
                ],
              ),
              const SizedBox(height: 4),
              Text(package.namaPaket, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              if (package.destinationWarehouseName != null) ...[
                Text('Rute: ${package.currentWarehouseName ?? "-"} ➔ ${package.destinationWarehouseName}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accent)),
                const SizedBox(height: 2),
              ],
              Text(package.alamatTujuan, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('${package.berat} kg • ${package.jenisLayanan}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  const Spacer(),
                  Text(formatCurrency(package.ongkosKirim), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
