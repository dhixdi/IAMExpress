import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class ShakeDetector {
  static const double _shakeThreshold = 15.0;
  static const int _shakeTimeLimit = 500;
  DateTime? _lastShakeTime;

  Stream<void> get onShake => accelerometerEventStream().where((event) {
    final magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
    final now = DateTime.now();
    if (magnitude > _shakeThreshold) {
      if (_lastShakeTime == null || now.difference(_lastShakeTime!).inMilliseconds > _shakeTimeLimit) {
        _lastShakeTime = now;
        return true;
      }
    }
    return false;
  }).map((_) {});
}
