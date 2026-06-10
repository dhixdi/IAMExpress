import 'package:sensors_plus/sensors_plus.dart';

class GyroscopeService {
  Stream<double> get tiltY => gyroscopeEventStream().map((event) => event.y);
  Stream<GyroscopeEvent> get rawEvents => gyroscopeEventStream();
}
