import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../features/packages/domain/tracker_model.dart';
import '../utils/format_date.dart';
import '../utils/status_color.dart';

class TrackerTimeline extends StatelessWidget {
  final List<TrackerModel> entries;
  const TrackerTimeline({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      itemBuilder: (_, i) {
        final e = entries[i];
        final colors = getStatusColors(e.status);
        final isLast = i == entries.length - 1;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 32,
                child: Column(
                  children: [
                    Container(width: 14, height: 14, decoration: BoxDecoration(color: colors.bg, shape: BoxShape.circle, border: Border.all(color: colors.border, width: 2))),
                    if (!isLast) Expanded(child: Container(width: 2, color: AppColors.border)),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24, left: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.status, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: colors.text)),
                      if (e.warehouseName != null) Text(e.warehouseName!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      Text('Oleh: ${e.changedByName}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      Text(formatDate(e.timestamp), style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      if (e.notes != null && e.notes!.isNotEmpty) Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(e.notes!, style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textSecondary)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
