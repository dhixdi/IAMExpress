import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameState {
  final int score;
  final int timeLeft;
  final bool isPlaying;
  final bool isGameOver;
  final String? currentPackageCity;
  final double packageX;
  final double packageY;
  final double fallSpeed;
  final int highScore;
  final int gameMode; // 0 = Sortir (Tap), 1 = Sortir (Gyro), 2 = Hujan Paket

  const GameState({this.score = 0, this.timeLeft = 60, this.isPlaying = false, this.isGameOver = false, this.currentPackageCity, this.packageX = 0.5, this.packageY = 0.0, this.fallSpeed = 0.008, this.highScore = 0, this.gameMode = 0});

  GameState copyWith({int? score, int? timeLeft, bool? isPlaying, bool? isGameOver, String? currentPackageCity, double? packageX, double? packageY, double? fallSpeed, int? highScore, int? gameMode}) =>
    GameState(score: score ?? this.score, timeLeft: timeLeft ?? this.timeLeft, isPlaying: isPlaying ?? this.isPlaying, isGameOver: isGameOver ?? this.isGameOver, currentPackageCity: currentPackageCity ?? this.currentPackageCity, packageX: packageX ?? this.packageX, packageY: packageY ?? this.packageY, fallSpeed: fallSpeed ?? this.fallSpeed, highScore: highScore ?? this.highScore, gameMode: gameMode ?? this.gameMode);
}

class GameNotifier extends StateNotifier<GameState> {
  Timer? _timer;
  Timer? _physicsTimer;
  StreamSubscription? _gyroSub;
  StreamSubscription? _accelSub;
  static const _cities = ['Jogja', 'Jakarta', 'Surabaya'];

  GameNotifier() : super(const GameState()) { _loadPrefs(); }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    state = state.copyWith(highScore: prefs.getInt('game_high_score') ?? 0, gameMode: prefs.getInt('game_mode_pref') ?? 0);
  }

  Future<void> _saveHighScore() async {
    if (state.score > state.highScore) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('game_high_score', state.score);
      state = state.copyWith(highScore: state.score);
    }
  }

  void setGameMode(int mode) async {
    state = state.copyWith(gameMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('game_mode_pref', mode);
  }

  void startGame() {
    state = GameState(isPlaying: true, gameMode: state.gameMode, highScore: state.highScore, timeLeft: state.gameMode == 2 ? 15 : 60);
    _startCountdown();
    if (state.gameMode != 2) {
      _spawnPackage();
      _startPhysics();
      if (state.gameMode == 1) _startGyroscope();
      _startAccelerometer();
    } else {
      _startAccelerometer();
    }
  }

  void _startGyroscope() {
    _gyroSub = gyroscopeEventStream().listen((event) {
      if (!state.isPlaying) return;
      final newX = (state.packageX + event.y * 0.02).clamp(0.05, 0.95);
      state = state.copyWith(packageX: newX);
    });
  }

  void _startAccelerometer() {
    _accelSub = userAccelerometerEventStream().listen((event) {
      if (!state.isPlaying) return;
      final magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      if (magnitude > 15) {
        if (state.gameMode == 2) {
          // Mode Hujan Paket: tambah skor saat diguncang
          state = state.copyWith(score: state.score + 1);
        } else {
          // Mode Sortir: Rem paket
          state = state.copyWith(fallSpeed: 0.002);
        }
      }
    });
  }

  void _startPhysics() {
    _physicsTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!state.isPlaying) return;
      final newY = state.packageY + state.fallSpeed;
      if (newY >= 1.0) {
        if (state.gameMode == 1) {
          // Gyroscope Mode: detect collision box based on X
          int idx = (state.packageX * _cities.length).floor().clamp(0, _cities.length - 1);
          String targetCity = _cities[idx];
          bool correct = targetCity == state.currentPackageCity;
          state = state.copyWith(score: state.score + (correct ? 10 : -2), packageY: 0.0, packageX: 0.5);
        } else {
          // Tap mode: missed it
          state = state.copyWith(score: state.score - 2, packageY: 0.0, packageX: 0.5);
        }
        _spawnPackage();
        return;
      }
      state = state.copyWith(packageY: newY);
    });
  }

  void dropToWarehouse(String targetCity) {
    if (!state.isPlaying) return;
    final correct = targetCity == state.currentPackageCity;
    state = state.copyWith(score: state.score + (correct ? 10 : -5), packageY: 0.0, packageX: 0.5);
    _spawnPackage();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.timeLeft <= 1) { _endGame(); return; }
      final elapsed = 60 - state.timeLeft + 1;
      final newSpeed = 0.008 + (elapsed ~/ 15) * 0.003;
      state = state.copyWith(timeLeft: state.timeLeft - 1, fallSpeed: newSpeed);
    });
  }

  void _endGame() {
    state = state.copyWith(isPlaying: false, isGameOver: true, timeLeft: 0);
    _timer?.cancel(); _physicsTimer?.cancel(); _gyroSub?.cancel(); _accelSub?.cancel();
    _saveHighScore();
  }

  void _spawnPackage() {
    final city = _cities[Random().nextInt(_cities.length)];
    state = state.copyWith(currentPackageCity: city, packageY: 0.0);
  }

  @override
  void dispose() { _timer?.cancel(); _physicsTimer?.cancel(); _gyroSub?.cancel(); _accelSub?.cancel(); super.dispose(); }
}

final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) => GameNotifier());
