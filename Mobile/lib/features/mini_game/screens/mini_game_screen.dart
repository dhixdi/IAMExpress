import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/game_provider.dart';

class MiniGameScreen extends ConsumerStatefulWidget {
  const MiniGameScreen({super.key});

  static const _warehouses = ['Jogja', 'Jakarta', 'Surabaya'];

  @override
  ConsumerState<MiniGameScreen> createState() => _MiniGameScreenState();
}

class _MiniGameScreenState extends ConsumerState<MiniGameScreen> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = GoRouter.of(context);
    _router.routerDelegate.addListener(_onRouteChange);
  }

  void _onRouteChange() {
    final location = _router.routerDelegate.currentConfiguration.uri.toString();
    if (!location.contains('mini-game')) {
      ref.read(gameProvider.notifier).stopGame();
    }
  }

  @override
  void dispose() {
    _router.routerDelegate.removeListener(_onRouteChange);
    ref.read(gameProvider.notifier).stopGame();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final notifier = ref.read(gameProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sortir Paket'),
      ),
      body: game.isGameOver
          ? _GameOverView(game: game, notifier: notifier)
          : game.isPlaying
              ? _GamePlayView(game: game, notifier: notifier)
              : _StartView(game: game, notifier: notifier),
    );
  }
}

class _StartView extends StatelessWidget {
  final GameState game;
  final GameNotifier notifier;
  const _StartView({required this.game, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('📦', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 16),
          const Text('Mini Games', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          
          // Pilih Mode Game
          RadioListTile<int>(
            title: const Text('Sortir (Tap/Sentuh)', style: TextStyle(fontSize: 14)),
            value: 0,
            groupValue: game.gameMode,
            onChanged: (v) => notifier.setGameMode(v!),
            contentPadding: EdgeInsets.zero,
          ),
          RadioListTile<int>(
            title: const Text('Sortir (Gyroscope/Miringkan)', style: TextStyle(fontSize: 14)),
            value: 1,
            groupValue: game.gameMode,
            onChanged: (v) => notifier.setGameMode(v!),
            contentPadding: EdgeInsets.zero,
          ),
          RadioListTile<int>(
            title: const Text('Hujan Paket (Kocok HP)', style: TextStyle(fontSize: 14)),
            value: 2,
            groupValue: game.gameMode,
            onChanged: (v) => notifier.setGameMode(v!),
            contentPadding: EdgeInsets.zero,
          ),

          const SizedBox(height: 16),
          Text('Best Score: ${game.highScore}', style: const TextStyle(fontSize: 16, color: AppColors.accent, fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: notifier.startGame, child: const Text('Mulai Game', style: TextStyle(fontSize: 16)))),
        ]),
      ),
    );
  }
}

class _GamePlayView extends StatefulWidget {
  final GameState game;
  final GameNotifier notifier;
  const _GamePlayView({required this.game, required this.notifier});

  @override
  State<_GamePlayView> createState() => _GamePlayViewState();
}

class _FallingPackage {
  double x;
  double y;
  double speed;
  String emoji;
  _FallingPackage({required this.x, required this.y, required this.speed, required this.emoji});
}

class _GamePlayViewState extends State<_GamePlayView> with SingleTickerProviderStateMixin {
  final List<_FallingPackage> _packages = [];
  late final Ticker _ticker;
  int _lastScore = 0;
  final _random = Random();
  static const _emojis = ['📦', '📫', '📪', '🎁', '📬'];

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;
    setState(() {
      for (final p in _packages) {
        p.y += p.speed;
      }
      _packages.removeWhere((p) => p.y > 1.2);
    });
  }

  @override
  void didUpdateWidget(covariant _GamePlayView old) {
    super.didUpdateWidget(old);
    if (widget.game.gameMode == 2 && widget.game.score > _lastScore) {
      final diff = widget.game.score - _lastScore;
      for (int i = 0; i < diff; i++) {
        _packages.add(_FallingPackage(
          x: _random.nextDouble() * 0.85 + 0.05,
          y: -0.05 - _random.nextDouble() * 0.15,
          speed: 0.008 + _random.nextDouble() * 0.008,
          emoji: _emojis[_random.nextInt(_emojis.length)],
        ));
      }
    }
    _lastScore = widget.game.score;
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final notifier = widget.notifier;

    if (game.gameMode == 2) {
      // Hujan Paket UI
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Paket Jatuh: ${game.score}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              Text('⏱ ${game.timeLeft}s', style: const TextStyle(fontSize: 18, color: AppColors.danger, fontWeight: FontWeight.w700)),
            ]),
          ),
          Expanded(
            child: LayoutBuilder(builder: (_, constraints) {
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;
              return Stack(
                children: [
                  // Background
                  Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.background, AppColors.primary.withValues(alpha: 0.05)]))),
                  // Falling packages
                  ..._packages.map((p) => Positioned(
                    left: p.x * w - 16,
                    top: p.y * h,
                    child: Text(p.emoji, style: const TextStyle(fontSize: 32)),
                  )),
                  // Truck at bottom
                  Positioned(
                    bottom: 8,
                    left: 0,
                    right: 0,
                    child: Center(child: Text('🚛', style: const TextStyle(fontSize: 80))),
                  ),
                  // Center text
                  Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Text('📳', style: TextStyle(fontSize: 60)),
                      const SizedBox(height: 8),
                      const Text('Kocok HP Terus!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.primary)),
                      const SizedBox(height: 4),
                      const Text('Semakin cepat dikocok,\nsemakin banyak paket!', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                    ]),
                  ),
                ],
              );
            }),
          ),
        ],
      );
    }

    // Mode Sortir UI
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Skor: ${game.score}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: game.timeLeft <= 10 ? AppColors.danger.withValues(alpha: 0.1) : AppColors.accentLight, borderRadius: BorderRadius.circular(16)),
            child: Text('⏱ ${game.timeLeft}s', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: game.timeLeft <= 10 ? AppColors.danger : AppColors.primary))),
        ]),
      ),
      Expanded(
        child: LayoutBuilder(builder: (_, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          return Stack(children: [
            Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.background, AppColors.border.withValues(alpha: 0.3)]))),
            Positioned(
              left: game.packageX * w - 28,
              top: game.packageY * h - 10,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('📦', style: TextStyle(fontSize: 40)),
                Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4)),
                  child: Text(game.currentPackageCity ?? '', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600))),
              ]),
            ),
          ]);
        }),
      ),
      Container(
        color: AppColors.primary.withValues(alpha: 0.05),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Row(children: MiniGameScreen._warehouses.map((city) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              onPressed: game.gameMode == 1 ? null : () => notifier.dropToWarehouse(city),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryLight, padding: const EdgeInsets.symmetric(vertical: 16)),
              child: Column(mainAxisSize: MainAxisSize.min, children: [const Text('🏢', style: TextStyle(fontSize: 24)), Text(city, style: const TextStyle(fontSize: 11, color: Colors.white))]),
            ),
          ),
        )).toList()),
      ),
    ]);
  }
}

class _GameOverView extends StatelessWidget {
  final GameState game;
  final GameNotifier notifier;
  const _GameOverView({required this.game, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('🏁', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 12),
          const Text('Game Over', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Text('Skor: ${game.score}', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w700, color: AppColors.primary)),
          const SizedBox(height: 8),
          Text('⭐ Best: ${game.highScore}', style: const TextStyle(fontSize: 18, color: AppColors.accent, fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: notifier.startGame, child: const Text('Main Lagi'))),
          const SizedBox(height: 8),
          SizedBox(width: double.infinity, child: OutlinedButton(onPressed: notifier.resetToMenu, child: const Text('Ganti Mode'))),
        ]),
      ),
    );
  }
}
