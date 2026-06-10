import 'package:intl/intl.dart';

String formatDate(DateTime dt) {
  final wib = dt.toUtc().add(const Duration(hours: 7));
  return '${DateFormat('d MMM yyyy, HH:mm').format(wib)} WIB';
}

String formatTime(DateTime dt) {
  final wib = dt.toUtc().add(const Duration(hours: 7));
  return '${DateFormat('HH:mm').format(wib)} WIB';
}

String formatDateShort(DateTime dt) {
  final wib = dt.toUtc().add(const Duration(hours: 7));
  return DateFormat('d MMM yyyy').format(wib);
}
