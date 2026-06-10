import 'package:flutter/material.dart';
import '../utils/status_color.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = getStatusColors(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: colors.border),
      ),
      child: Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: colors.text)),
    );
  }
}
