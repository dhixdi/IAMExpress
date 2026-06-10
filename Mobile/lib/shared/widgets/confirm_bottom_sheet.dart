import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ConfirmBottomSheet extends StatefulWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final VoidCallback onConfirm;
  final bool isDestructive;
  final bool showNotesField;
  final ValueChanged<String>? onNotesChanged;

  const ConfirmBottomSheet({super.key, required this.title, required this.message, required this.confirmLabel, required this.onConfirm, this.isDestructive = false, this.showNotesField = false, this.onNotesChanged});

  @override
  State<ConfirmBottomSheet> createState() => _ConfirmBottomSheetState();
}

class _ConfirmBottomSheetState extends State<ConfirmBottomSheet> {
  final _notesCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(widget.message, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          if (widget.showNotesField) ...[
            const SizedBox(height: 16),
            TextField(controller: _notesCtrl, decoration: const InputDecoration(hintText: 'Catatan (opsional)'), maxLines: 2, onChanged: widget.onNotesChanged),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Batal'))),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () { Navigator.pop(context); widget.onConfirm(); },
                  style: ElevatedButton.styleFrom(backgroundColor: widget.isDestructive ? AppColors.danger : AppColors.primary),
                  child: Text(widget.confirmLabel),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
