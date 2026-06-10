import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';

const _timezones = {'WIB': 7, 'WITA': 8, 'WIT': 9, 'London': 0};
const _tzNames = {'WIB': 'Waktu Indonesia Barat', 'WITA': 'Waktu Indonesia Tengah', 'WIT': 'Waktu Indonesia Timur', 'London': 'London (GMT)'};

class TimezoneScreen extends StatefulWidget {
  const TimezoneScreen({super.key});
  @override
  State<TimezoneScreen> createState() => _TimezoneScreenState();
}

class _TimezoneScreenState extends State<TimezoneScreen> {
  late Timer _timer;
  DateTime _now = DateTime.now().toUtc();
  String _fromZone = 'WIB';
  TimeOfDay _inputTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() => _now = DateTime.now().toUtc()));
  }

  @override
  void dispose() { _timer.cancel(); super.dispose(); }

  String _formatForZone(DateTime utc, int offset) {
    final local = utc.add(Duration(hours: offset));
    return DateFormat('HH:mm:ss').format(local);
  }

  String _convertManual(String zone) {
    final fromOffset = _timezones[_fromZone]!;
    final toOffset = _timezones[zone]!;
    final base = DateTime(2026, 1, 1, _inputTime.hour, _inputTime.minute);
    final converted = base.add(Duration(hours: toOffset - fromOffset));
    return DateFormat('HH:mm').format(converted);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Konversi Waktu')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Jam Real-time', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ..._timezones.entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                SizedBox(width: 64, child: Text(e.key, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary))),
                Text(_formatForZone(_now, e.value), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, fontFamily: 'monospace')),
              ]),
            )),
          ]))),
          const SizedBox(height: 16),
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Konversi Manual', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final t = await showTimePicker(context: context, initialTime: _inputTime);
                    if (t != null) setState(() => _inputTime = t);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(6)),
                    child: Text('${_inputTime.hour.toString().padLeft(2, '0')}:${_inputTime.minute.toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: DropdownButtonFormField<String>(value: _fromZone, decoration: const InputDecoration(labelText: 'Dari'), items: _timezones.keys.map((z) => DropdownMenuItem(value: z, child: Text(z))).toList(), onChanged: (v) => setState(() => _fromZone = v!))),
            ]),
            const SizedBox(height: 16),
            ..._timezones.keys.where((z) => z != _fromZone).map((z) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(children: [
                SizedBox(width: 64, child: Text(z, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary))),
                Text(_convertManual(z), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                Text(_tzNames[z]!, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ]),
            )),
          ]))),
        ]),
      ),
    );
  }
}
