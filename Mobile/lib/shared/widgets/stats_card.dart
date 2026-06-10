import 'package:flutter/material.dart';

class StatsCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final Color color;
  const StatsCard({super.key, required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  const SizedBox(height: 4),
                  Text('$value', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: color)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
