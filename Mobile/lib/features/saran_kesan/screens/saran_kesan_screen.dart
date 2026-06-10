import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';

class SaranKesanScreen extends StatefulWidget {
  const SaranKesanScreen({super.key});
  @override
  State<SaranKesanScreen> createState() => _SaranKesanScreenState();
}

class _SaranKesanScreenState extends State<SaranKesanScreen> {
  final _kesanCtrl = TextEditingController();
  final _saranCtrl = TextEditingController();
  int _rating = 0;
  bool _saved = false;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _kesanCtrl.text = prefs.getString('kesan') ?? '';
      _saranCtrl.text = prefs.getString('saran') ?? '';
      _rating = prefs.getInt('rating') ?? 0;
      _saved = _kesanCtrl.text.isNotEmpty || _saranCtrl.text.isNotEmpty;
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('kesan', _kesanCtrl.text);
    await prefs.setString('saran', _saranCtrl.text);
    await prefs.setInt('rating', _rating);
    setState(() => _saved = true);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Terima kasih atas saran dan kesanmu!'), backgroundColor: AppColors.success));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saran & Kesan TPM')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Mata Kuliah Teknologi Pemrograman Mobile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primary)),
            const Text('Semester Genap 2025/2026', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
          ]))),
          const SizedBox(height: 16),
          const Text('Kesan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(controller: _kesanCtrl, maxLines: 4, decoration: const InputDecoration(hintText: 'Tuliskan kesan kamu selama mengikuti mata kuliah TPM...')),
          const SizedBox(height: 16),
          const Text('Saran', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(controller: _saranCtrl, maxLines: 4, decoration: const InputDecoration(hintText: 'Tuliskan saran kamu untuk pengembangan mata kuliah TPM...')),
          const SizedBox(height: 16),
          const Text('Penilaian', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) => IconButton(
            icon: Icon(i < _rating ? Icons.star : Icons.star_border, size: 36, color: AppColors.accent),
            onPressed: () => setState(() => _rating = i + 1),
          ))),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _save, child: Text(_saved ? 'Perbarui' : 'Simpan')),
        ]),
      ),
    );
  }
}
