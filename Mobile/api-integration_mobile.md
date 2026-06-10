# API Integration — IAMExpress Mobile App

Dokumen ini menjelaskan cara aplikasi mobile berkomunikasi dengan backend API, termasuk service untuk fitur Tools TPM (cuaca & kurs).

---

## Setup Dio

```dart
// lib/core/network/dio_client.dart
@Riverpod(keepAlive: true)
Dio dioClient(DioClientRef ref) {
  final dio = Dio(BaseOptions(
    baseUrl: AppConstants.apiBaseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {'Content-Type': 'application/json'},
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await ref.read(secureStorageProvider).readToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    },
    onError: (error, handler) async {
      if (error.response?.statusCode == 401) {
        await ref.read(authProvider.notifier).logout();
      }
      handler.next(error);
    },
  ));

  return dio;
}
```

### ApiException

```dart
// lib/core/network/api_exception.dart
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final List<Map<String, String>> errors;

  const ApiException({
    required this.statusCode,
    required this.message,
    this.errors = const [],
  });

  factory ApiException.fromResponse(Response response) {
    final data = response.data as Map<String, dynamic>;
    final rawErrors = (data['errors'] as List? ?? [])
        .cast<Map<String, dynamic>>();
    return ApiException(
      statusCode: response.statusCode ?? 0,
      message: data['message'] as String? ?? 'Terjadi kesalahan',
      errors: rawErrors.map((e) => {
        'field': e['field'] as String? ?? '',
        'message': e['message'] as String? ?? '',
      }).toList(),
    );
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}
```

### SecureStorage

```dart
// lib/core/storage/secure_storage.dart
@Riverpod(keepAlive: true)
SecureStorageService secureStorage(SecureStorageRef ref) =>
    SecureStorageService();

class SecureStorageService {
  static const _tokenKey = 'jwt_token';
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> writeToken(String token) =>
      _storage.write(key: _tokenKey, value: token);
  Future<String?> readToken() => _storage.read(key: _tokenKey);
  Future<void> deleteToken() => _storage.delete(key: _tokenKey);
}
```

---

## Auth Service

```dart
// lib/features/auth/data/auth_service.dart
@riverpod
AuthService authService(AuthServiceRef ref) =>
    AuthService(ref.watch(dioClientProvider));

class AuthService {
  final Dio _dio;
  const AuthService(this._dio);

  Future<({String token, UserModel user})> login(
      String email, String password) async {
    final res = await _dio.post('/auth/login',
        data: {'email': email, 'password': password});
    final data = res.data['data'] as Map<String, dynamic>;
    return (
      token: data['token'] as String,
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
    );
  }

  Future<UserModel> me(String token) async {
    final res = await _dio.get('/auth/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}));
    return UserModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<void> logout() async => _dio.post('/auth/logout');
}
```

### UserModel

```dart
// lib/features/auth/domain/user_model.dart
class UserModel {
  final int userId;
  final String nama;
  final String email;
  final String role;          // 'LINEHAUL' atau 'COURIER'
  final String? photoUrl;
  final int? warehouseId;
  final bool biometricsEnabled;
  final String? biometricsType;  // 'fingerprint' atau 'face'

  const UserModel({
    required this.userId, required this.nama, required this.email,
    required this.role, this.photoUrl, this.warehouseId,
    required this.biometricsEnabled, this.biometricsType,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    userId: json['user_id'] as int,
    nama: json['nama'] as String,
    email: json['email'] as String,
    role: json['role'] as String,
    photoUrl: json['photo_url'] as String?,
    warehouseId: json['warehouse_id'] as int?,
    biometricsEnabled: (json['biometrics_enabled'] as int? ?? 0) == 1,
    biometricsType: json['biometrics_type'] as String?,
  );
}
```

---

## Package Service

```dart
// lib/features/packages/data/package_service.dart
@riverpod
PackageService packageService(PackageServiceRef ref) =>
    PackageService(ref.watch(dioClientProvider));

class PackageService {
  final Dio _dio;
  const PackageService(this._dio);

  /// GET /packages — difilter otomatis backend sesuai role JWT
  Future<({List<PackageModel> packages, PaginationMeta meta})> getAll({
    int page = 1, int perPage = 10,
    String? currentStatus, String? q,
    String sortBy = 'created_at', String order = 'desc',
  }) async {
    final res = await _dio.get('/packages', queryParameters: {
      'page': page, 'per_page': perPage,
      if (currentStatus != null) 'current_status': currentStatus,
      if (q != null && q.isNotEmpty) 'q': q,
      'sort_by': sortBy, 'order': order,
    });
    final data = res.data['data'] as Map<String, dynamic>;
    return (
      packages: (data['packages'] as List)
          .cast<Map<String, dynamic>>()
          .map(PackageModel.fromJson)
          .toList(),
      meta: PaginationMeta.fromJson(res.data['meta'] as Map<String, dynamic>),
    );
  }

  /// GET /packages/:id
  Future<PackageModel> getById(int id) async {
    final res = await _dio.get('/packages/$id');
    return PackageModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  /// GET /packages/track/:resi
  Future<PackageModel> trackByResi(String resi) async {
    final res = await _dio.get('/packages/track/$resi');
    return PackageModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  /// PATCH /packages/:id/status
  Future<PackageModel> updateStatus(int id, String status, {String? notes}) async {
    final res = await _dio.patch('/packages/$id/status', data: {
      'status': status,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    });
    return PackageModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  /// GET /packages/:id/tracker
  Future<List<TrackerModel>> getTracker(int id) async {
    final res = await _dio.get('/packages/$id/tracker', queryParameters: {
      'sort_by': 'timestamp', 'order': 'asc',
    });
    return ((res.data['data'] as Map)['tracker'] as List)
        .cast<Map<String, dynamic>>()
        .map(TrackerModel.fromJson)
        .toList();
  }
}
```

### PackageModel

```dart
class PackageModel {
  final int packageId;
  final String resi;
  final String namaPaket;
  final String alamatPengirim;
  final String alamatTujuan;
  final String noHpPengirim;
  final String noHpPenerima;
  final String? deskripsiBarang;
  final double berat;
  final String jenisLayanan;
  final double ongkosKirim;
  final double? receiverLat;
  final double? receiverLng;
  final String currentStatus;
  final int currentWarehouseId;
  final DateTime createdAt;

  factory PackageModel.fromJson(Map<String, dynamic> json) => PackageModel(
    packageId: json['package_id'] as int,
    resi: json['resi'] as String,
    namaPaket: json['nama_paket'] as String,
    alamatPengirim: json['alamat_pengirim'] as String,
    alamatTujuan: json['alamat_tujuan'] as String,
    noHpPengirim: json['no_hp_pengirim'] as String,
    noHpPenerima: json['no_hp_penerima'] as String,
    deskripsiBarang: json['deskripsi_barang'] as String?,
    berat: (json['berat'] as num).toDouble(),
    jenisLayanan: json['jenis_layanan'] as String,
    ongkosKirim: (json['ongkos_kirim'] as num).toDouble(),
    receiverLat: (json['receiver_lat'] as num?)?.toDouble(),
    receiverLng: (json['receiver_lng'] as num?)?.toDouble(),
    currentStatus: json['current_status'] as String,
    currentWarehouseId: json['current_warehouse_id'] as int,
    createdAt: DateTime.parse(json['created_at'] as String),
  );
}
```

### TrackerModel

```dart
class TrackerModel {
  final int trackId;
  final String status;
  final String? notes;
  final String? namaGudang;
  final String createdByNama;
  final DateTime timestamp;

  factory TrackerModel.fromJson(Map<String, dynamic> json) => TrackerModel(
    trackId: json['track_id'] as int,
    status: json['status'] as String,
    notes: json['notes'] as String?,
    namaGudang: json['nama_gudang'] as String?,
    createdByNama: json['created_by_nama'] as String? ?? '-',
    timestamp: DateTime.parse(json['timestamp'] as String),
  );
}
```

---

## Dashboard Service

```dart
// lib/features/dashboard/data/dashboard_service.dart
@riverpod
DashboardService dashboardService(DashboardServiceRef ref) =>
    DashboardService(ref.watch(dioClientProvider));

class DashboardService {
  final Dio _dio;
  const DashboardService(this._dio);

  Future<DashboardModel> get() async {
    final res = await _dio.get('/dashboard');
    return DashboardModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }
}

class DashboardModel {
  final int totalDitugaskan;
  final int sedangDikerjakan;
  final int selesaiHariIni;

  factory DashboardModel.fromJson(Map<String, dynamic> json) => DashboardModel(
    totalDitugaskan: json['total_ditugaskan'] as int? ?? 0,
    sedangDikerjakan: json['sedang_dikerjakan'] as int? ?? 0,
    selesaiHariIni: json['selesai_hari_ini'] as int? ?? 0,
  );
}
```

---

## User / Profile Service

```dart
// lib/features/profile/data/user_service.dart
@riverpod
UserService userService(UserServiceRef ref) =>
    UserService(ref.watch(dioClientProvider));

class UserService {
  final Dio _dio;
  const UserService(this._dio);

  Future<void> changePassword(String oldPassword, String newPassword) async {
    await _dio.patch('/users/me/password', data: {
      'old_password': oldPassword,
      'new_password': newPassword,
    });
  }

  Future<UserModel> updatePhoto(String photoUrl) async {
    final res = await _dio.patch('/users/me/photo', data: {'photo_url': photoUrl});
    return UserModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<void> updateBiometrics({
    required bool biometricsEnabled,
    String? biometricsType,
  }) async {
    await _dio.patch('/users/me/biometrics', data: {
      'biometrics_enabled': biometricsEnabled,
      if (biometricsType != null) 'biometrics_type': biometricsType,
    });
  }
}
```

---

## AI Chat Service

```dart
// lib/features/ai_chat/data/ai_service.dart
@riverpod
AiService aiService(AiServiceRef ref) =>
    AiService(ref.watch(dioClientProvider));

class AiService {
  final Dio _dio;
  const AiService(this._dio);

  Future<String> chat(String message) async {
    final res = await _dio.post('/ai/chat', data: {'message': message});
    return res.data['data']['reply'] as String;
  }
}
```

---

## Currency Service (Tools TPM)

Menggunakan **ExchangeRate-API** (free tier). Base currency IDR, konversi ke USD, EUR, SGD, JPY.

```dart
// lib/features/tools_tpm/currency/data/currency_service.dart
@riverpod
CurrencyService currencyService(CurrencyServiceRef ref) {
  final dio = Dio(BaseOptions(
    baseUrl: AppConstants.exchangeRateBaseUrl,
    connectTimeout: const Duration(seconds: 10),
  ));
  return CurrencyService(dio);
}

class CurrencyService {
  final Dio _dio;
  const CurrencyService(this._dio);

  /// GET /v6/{API_KEY}/latest/IDR
  /// Ambil kurs IDR terhadap semua mata uang
  Future<CurrencyRateModel> getRates() async {
    final res = await _dio.get(
      '/${AppConstants.exchangeRateApiKey}/latest/IDR',
    );
    return CurrencyRateModel.fromJson(res.data as Map<String, dynamic>);
  }
}
```

### CurrencyRateModel

```dart
// lib/features/tools_tpm/currency/domain/currency_rate_model.dart

// Mata uang yang didukung
const supportedCurrencies = ['IDR', 'USD', 'EUR', 'SGD', 'JPY'];

const currencyNames = {
  'IDR': 'Rupiah Indonesia',
  'USD': 'Dolar Amerika',
  'EUR': 'Euro',
  'SGD': 'Dolar Singapura',
  'JPY': 'Yen Jepang',
};

class CurrencyRateModel {
  final String baseCode;              // 'IDR'
  final Map<String, double> rates;    // {'USD': 0.000062, 'EUR': 0.000057, ...}
  final DateTime lastUpdate;

  factory CurrencyRateModel.fromJson(Map<String, dynamic> json) {
    final rawRates = json['conversion_rates'] as Map<String, dynamic>;
    return CurrencyRateModel(
      baseCode: json['base_code'] as String,
      rates: rawRates.map((k, v) => MapEntry(k, (v as num).toDouble())),
      lastUpdate: DateTime.parse(json['time_last_update_utc'] as String),
    );
  }

  // Konversi amount dari fromCurrency ke toCurrency
  double convert({
    required double amount,
    required String from,
    required String to,
  }) {
    if (from == 'IDR') return amount * rates[to]!;
    // Konversi ke IDR dulu, lalu ke target
    final toIdr = amount / rates[from]!;
    if (to == 'IDR') return toIdr;
    return toIdr * rates[to]!;
  }
}
```

### CurrencyProvider

```dart
// lib/features/tools_tpm/currency/providers/currency_provider.dart
@riverpod
Future<CurrencyRateModel> currencyRates(CurrencyRatesRef ref) {
  return ref.watch(currencyServiceProvider).getRates();
}
```

**Integrasi dengan konsep:** Di halaman Currency, tampilkan juga konversi ongkos kirim paket aktif user ke mata uang lain sehingga relevan dengan tema ekspedisi.

---

## Weather Service (Tools TPM)

Menggunakan **Open-Meteo API** (gratis, tanpa API key). Ambil cuaca berdasarkan koordinat GPS user.

```dart
// lib/features/tools_tpm/weather/data/weather_service.dart
@riverpod
WeatherService weatherService(WeatherServiceRef ref) {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://api.open-meteo.com/v1',
    connectTimeout: const Duration(seconds: 10),
  ));
  return WeatherService(dio);
}

class WeatherService {
  final Dio _dio;
  const WeatherService(this._dio);

  /// GET /forecast?latitude=xx&longitude=xx&current=temperature_2m,...&timezone=Asia/Jakarta
  Future<WeatherModel> getByCoords(double lat, double lon) async {
    final res = await _dio.get('/forecast', queryParameters: {
      'latitude': lat,
      'longitude': lon,
      'current': 'temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m',
      'timezone': 'Asia/Jakarta',
    });
    return WeatherModel.fromJson(res.data as Map<String, dynamic>, lat, lon);
  }
}
```

### WeatherModel (Open-Meteo)

```dart
// lib/features/tools_tpm/weather/domain/weather_model.dart

// WMO Weather Code → deskripsi & ikon
String wmoDescription(int code) {
  if (code == 0) return 'Cerah';
  if (code <= 3) return 'Berawan sebagian';
  if (code <= 48) return 'Berkabut';
  if (code <= 67) return 'Hujan';
  if (code <= 77) return 'Salju';
  if (code <= 82) return 'Hujan deras';
  if (code <= 99) return 'Badai petir';
  return 'Tidak diketahui';
}

String wmoIcon(int code) {
  if (code == 0) return '☀';
  if (code <= 3) return '⛅';
  if (code <= 48) return '🌫';
  if (code <= 67) return '🌧';
  if (code <= 77) return '❄';
  if (code <= 82) return '🌧';
  if (code <= 99) return '⛈';
  return '🌡';
}

class WeatherModel {
  final double tempCelsius;
  final String description;
  final String icon;
  final int humidity;
  final double windSpeed;   // km/h
  final double lat;
  final double lon;

  factory WeatherModel.fromJson(Map<String, dynamic> json, double lat, double lon) {
    final current = json['current'] as Map<String, dynamic>;
    final code = current['weather_code'] as int;
    return WeatherModel(
      tempCelsius: (current['temperature_2m'] as num).toDouble(),
      description: wmoDescription(code),
      icon: wmoIcon(code),
      humidity: (current['relative_humidity_2m'] as num).toInt(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      lat: lat,
      lon: lon,
    );
  }
}
```

### WeatherProvider

```dart
// lib/features/tools_tpm/weather/providers/weather_provider.dart
@riverpod
Future<WeatherModel> weather(WeatherRef ref) async {
  final position = await Geolocator.getCurrentPosition();
  return ref.watch(weatherServiceProvider).getByCoords(
    position.latitude,
    position.longitude,
  );
}
```

> **API:** Open-Meteo tidak membutuhkan API key. Tidak perlu `OPENWEATHER_API_KEY` di `--dart-define`.

**Integrasi dengan konsep:** Cuaca lokasi kurir relevan karena kondisi cuaca mempengaruhi proses delivery. Tampilkan info seperti "🌧 Hujan — Hati-hati saat pengiriman, paket rentan basah."

---

## Konversi Waktu (Tools TPM) — Tanpa API

Konversi waktu menggunakan kalkulasi lokal dengan package `intl`. Tidak perlu API.

```dart
// lib/features/tools_tpm/timezone/timezone_utils.dart

// Offset dari UTC dalam jam
const timezones = {
  'WIB':    7,   // Waktu Indonesia Barat  (UTC+7)
  'WITA':   8,   // Waktu Indonesia Tengah (UTC+8)
  'WIT':    9,   // Waktu Indonesia Timur  (UTC+9)
  'London': 0,   // GMT (UTC+0), tanpa daylight saving untuk simplisitas
};

// Nama lengkap zona waktu
const timezoneNames = {
  'WIB':    'Waktu Indonesia Barat',
  'WITA':   'Waktu Indonesia Tengah',
  'WIT':    'Waktu Indonesia Timur',
  'London': 'London (GMT)',
};

/// Konversi DateTime dari satu zona ke zona lain
DateTime convertTimezone(DateTime source, String fromZone, String toZone) {
  final fromOffset = timezones[fromZone]!;
  final toOffset = timezones[toZone]!;
  return source.add(Duration(hours: toOffset - fromOffset));
}

/// Format DateTime ke string HH:mm:ss dd MMM yyyy
String formatForZone(DateTime dt) {
  return DateFormat('HH:mm:ss, dd MMM yyyy').format(dt);
}
```

**Integrasi dengan konsep:** Di halaman Timezone, tampilkan timestamp paket terakhir yang diupdate user dalam semua zona waktu, sehingga relevan dengan tema ekspedisi lintas zona.

---

## Error Handling di Provider

```dart
// Contoh: update status paket
Future<void> updateStatus(int id, String status, String? notes) async {
  state = const AsyncLoading();
  state = await AsyncValue.guard(() async {
    final updated = await ref.read(packageServiceProvider)
        .updateStatus(id, status, notes: notes);
    // Notifikasi lokal setelah update berhasil
    await NotificationService.showStatusUpdate(
      resi: updated.resi,
      newStatus: status,
    );
    ref.invalidate(packageListProvider);
    ref.invalidate(packageTrackerProvider(id));
    return updated;
  });
}
```

```dart
// Error handling di screen
ref.listen(packageDetailProvider(packageId), (_, next) {
  next.whenOrNull(
    error: (err, _) {
      final msg = err is ApiException ? err.message : 'Terjadi kesalahan';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AppColors.danger),
      );
    },
  );
});
```

---

## Endpoint Summary

| Service | Method | Endpoint | Keterangan |
|---|---|---|---|
| `authService.login` | POST | `/auth/login` | — |
| `authService.me` | GET | `/auth/me` | — |
| `authService.logout` | POST | `/auth/logout` | — |
| `packageService.getAll` | GET | `/packages` | Role-filtered otomatis |
| `packageService.getById` | GET | `/packages/:id` | — |
| `packageService.trackByResi` | GET | `/packages/track/:resi` | — |
| `packageService.updateStatus` | PATCH | `/packages/:id/status` | + trigger notifikasi lokal |
| `packageService.getTracker` | GET | `/packages/:id/tracker` | — |
| `dashboardService.get` | GET | `/dashboard` | Personal stats |
| `userService.changePassword` | PATCH | `/users/me/password` | — |
| `userService.updatePhoto` | PATCH | `/users/me/photo` | — |
| `userService.updateBiometrics` | PATCH | `/users/me/biometrics` | — |
| `aiService.chat` | POST | `/ai/chat` | — |
| `currencyService.getRates` | GET | ExchangeRate-API (eksternal) | Bukan backend IAMExpress |
| `weatherService.getByCoords` | GET | OpenWeatherMap (eksternal) | Bukan backend IAMExpress |
