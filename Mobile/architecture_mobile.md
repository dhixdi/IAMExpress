# Architecture — IAMExpress Mobile App

## Struktur Folder

```
mobile/
├── lib/
│   ├── main.dart                         ← Entry point, init notifikasi
│   ├── app.dart                          ← Root widget, ProviderScope, tema, router
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_constants.dart        ← API URLs, API keys dari dart-define
│   │   │   ├── package_status.dart       ← Semua nilai status + nextStatuses()
│   │   │   └── routes.dart               ← Semua path route sebagai konstanta
│   │   ├── network/
│   │   │   ├── dio_client.dart           ← Instance Dio + interceptor JWT
│   │   │   └── api_exception.dart        ← Model exception dari response API
│   │   ├── storage/
│   │   │   └── secure_storage.dart       ← Wrapper flutter_secure_storage
│   │   ├── notifications/
│   │   │   └── notification_service.dart ← Wrapper flutter_local_notifications
│   │   ├── sensors/
│   │   │   ├── shake_detector.dart       ← Deteksi shake via sensors_plus (Accelerometer)
│   │   │   └── gyroscope_service.dart    ← Baca kemiringan via sensors_plus (Gyroscope), dipakai mini game
│   │   └── theme/
│   │       ├── app_theme.dart
│   │       ├── app_colors.dart
│   │       └── app_text_styles.dart
│   │
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   └── auth_service.dart
│   │   │   ├── domain/
│   │   │   │   └── user_model.dart
│   │   │   ├── providers/
│   │   │   │   └── auth_provider.dart
│   │   │   └── screens/
│   │   │       └── login_screen.dart
│   │   │
│   │   ├── dashboard/
│   │   │   ├── data/
│   │   │   │   └── dashboard_service.dart
│   │   │   ├── domain/
│   │   │   │   └── dashboard_model.dart
│   │   │   ├── providers/
│   │   │   │   └── dashboard_provider.dart
│   │   │   └── screens/
│   │   │       └── dashboard_screen.dart
│   │   │
│   │   ├── packages/
│   │   │   ├── data/
│   │   │   │   └── package_service.dart
│   │   │   ├── domain/
│   │   │   │   ├── package_model.dart
│   │   │   │   └── tracker_model.dart
│   │   │   ├── providers/
│   │   │   │   ├── package_list_provider.dart
│   │   │   │   └── package_detail_provider.dart
│   │   │   └── screens/
│   │   │       ├── package_list_screen.dart
│   │   │       ├── package_detail_screen.dart
│   │   │       └── package_tracker_screen.dart
│   │   │
│   │   ├── peta/                         ← Screen Peta (bottom nav item ke-3)
│   │   │   └── screens/
│   │   │       └── peta_screen.dart
│   │   │
│   │   ├── ai_chat/
│   │   │   ├── data/
│   │   │   │   └── ai_service.dart
│   │   │   ├── domain/
│   │   │   │   └── chat_message_model.dart
│   │   │   ├── providers/
│   │   │   │   └── chat_provider.dart
│   │   │   └── screens/
│   │   │       └── ai_chat_screen.dart
│   │   │
│   │   ├── tools_tpm/                    ← Semua Tools TPM di bawah Profil
│   │   │   ├── currency/
│   │   │   │   ├── data/
│   │   │   │   │   └── currency_service.dart   ← ExchangeRate-API
│   │   │   │   ├── domain/
│   │   │   │   │   └── currency_rate_model.dart
│   │   │   │   ├── providers/
│   │   │   │   │   └── currency_provider.dart
│   │   │   │   └── screens/
│   │   │   │       └── currency_screen.dart
│   │   │   ├── timezone/
│   │   │   │   └── screens/
│   │   │   │       └── timezone_screen.dart    ← Tidak perlu API (kalkulasi lokal)
│   │   │   └── weather/
│   │   │       ├── data/
│   │   │       │   └── weather_service.dart    ← OpenWeatherMap API
│   │   │       ├── domain/
│   │   │       │   └── weather_model.dart
│   │   │       ├── providers/
│   │   │       │   └── weather_provider.dart
│   │   │       └── screens/
│   │   │           └── weather_screen.dart
│   │   │
│   │   ├── mini_game/                    ← Mini game "Sortir Paket"
│   │   │   ├── providers/
│   │   │   │   └── game_provider.dart
│   │   │   └── screens/
│   │   │       └── mini_game_screen.dart
│   │   │
│   │   ├── saran_kesan/                  ← Saran & Kesan TPM
│   │   │   └── screens/
│   │   │       └── saran_kesan_screen.dart
│   │   │
│   │   └── profile/
│   │       ├── data/
│   │       │   └── user_service.dart
│   │       ├── providers/
│   │       │   └── profile_provider.dart
│   │       └── screens/
│   │           ├── profile_screen.dart
│   │           ├── change_password_screen.dart
│   │           └── biometric_setting_screen.dart
│   │
│   └── shared/
│       ├── widgets/
│       │   ├── app_shell.dart            ← Wrapper bottom nav + ShellRoute
│       │   ├── app_bottom_nav.dart       ← 5 item bottom navigation
│       │   ├── status_badge.dart
│       │   ├── package_card.dart
│       │   ├── stats_card.dart
│       │   ├── tracker_timeline.dart
│       │   ├── confirm_bottom_sheet.dart
│       │   ├── loading_overlay.dart
│       │   └── error_view.dart
│       ├── utils/
│       │   ├── format_currency.dart
│       │   ├── format_date.dart
│       │   └── status_color.dart
│       └── models/
│           └── pagination_meta.dart
│
├── assets/
│   ├── images/
│   │   └── logo.png
│   ├── icons/
│   ├── animations/              ← Lottie/JSON animasi untuk mini game & loading
│   └── fonts/
│       ├── Inter-Regular.ttf
│       ├── Inter-Medium.ttf
│       ├── Inter-SemiBold.ttf
│       └── Inter-Bold.ttf
│
├── test/
├── pubspec.yaml
└── run_dev.sh
```

---

## Navigasi — go_router

```dart
// lib/core/constants/routes.dart
class Routes {
  static const login    = '/login';
  static const dashboard = '/';
  static const packages  = '/packages';
  static const packageDetail  = '/packages/:id';
  static const packageTracker = '/packages/:id/tracker';
  static const peta     = '/peta';
  static const aiChat   = '/ai-chat';
  static const profile  = '/profile';
  static const changePassword    = '/profile/password';
  static const biometricSetting  = '/profile/biometrics';
  static const currency = '/profile/currency';
  static const timezone = '/profile/timezone';
  static const weather  = '/profile/weather';
  static const miniGame = '/profile/mini-game';
  static const saranKesan = '/profile/saran-kesan';
}
```

```dart
// lib/app.dart — routing lengkap
final _router = GoRouter(
  initialLocation: Routes.dashboard,
  redirect: (context, state) {
    final isLoggedIn = ref.read(authProvider).isAuthenticated;
    final onLogin = state.matchedLocation == Routes.login;
    if (!isLoggedIn && !onLogin) return Routes.login;
    if (isLoggedIn && onLogin)  return Routes.dashboard;
    return null;
  },
  routes: [
    GoRoute(path: Routes.login, builder: (_, __) => const LoginScreen()),

    // Shell: semua halaman dengan bottom nav
    ShellRoute(
      builder: (_, __, child) => AppShell(child: child),
      routes: [
        GoRoute(path: Routes.dashboard, builder: (_, __) => const DashboardScreen()),

        GoRoute(
          path: Routes.packages,
          builder: (_, __) => const PackageListScreen(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (_, s) => PackageDetailScreen(
                packageId: int.parse(s.pathParameters['id']!),
              ),
              routes: [
                GoRoute(
                  path: 'tracker',
                  builder: (_, s) => PackageTrackerScreen(
                    packageId: int.parse(s.pathParameters['id']!),
                  ),
                ),
              ],
            ),
          ],
        ),

        GoRoute(path: Routes.peta,    builder: (_, __) => const PetaScreen()),
        GoRoute(path: Routes.aiChat,  builder: (_, __) => const AiChatScreen()),
        GoRoute(path: Routes.profile, builder: (_, __) => const ProfileScreen()),

        // Sub-route Profil
        GoRoute(path: Routes.changePassword,   builder: (_, __) => const ChangePasswordScreen()),
        GoRoute(path: Routes.biometricSetting, builder: (_, __) => const BiometricSettingScreen()),
        GoRoute(path: Routes.currency,  builder: (_, __) => const CurrencyScreen()),
        GoRoute(path: Routes.timezone,  builder: (_, __) => const TimezoneScreen()),
        GoRoute(path: Routes.weather,   builder: (_, __) => const WeatherScreen()),
        GoRoute(path: Routes.miniGame,  builder: (_, __) => const MiniGameScreen()),
        GoRoute(path: Routes.saranKesan, builder: (_, __) => const SaranKesanScreen()),
      ],
    ),
  ],
);
```

---

## State Management — Riverpod

### authProvider

```dart
// lib/features/auth/providers/auth_provider.dart
@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  @override
  AuthState build() => const AuthState();

  Future<void> login(String email, String password) async {
    final result = await ref.read(authServiceProvider).login(email, password);
    await ref.read(secureStorageProvider).writeToken(result.token);
    state = AuthState(token: result.token, user: result.user);
  }

  Future<void> restoreSession() async {
    final token = await ref.read(secureStorageProvider).readToken();
    if (token == null) return;
    final user = await ref.read(authServiceProvider).me(token);
    state = AuthState(token: token, user: user);
  }

  Future<void> logout() async {
    await ref.read(authServiceProvider).logout();
    await ref.read(secureStorageProvider).deleteToken();
    state = const AuthState();
  }
}
```

### packageListProvider — 4 Tab + Infinite Scroll

```dart
// lib/features/packages/providers/package_list_provider.dart

// Provider per tab — masing-masing tab punya state sendiri
@riverpod
class PackageList extends _$PackageList {
  int _page = 1;
  bool _hasMore = true;
  final List<PackageModel> _packages = [];

  @override
  AsyncValue<List<PackageModel>> build(String? statusFilter) =>
      const AsyncData([]);

  Future<void> fetchInitial({String? query}) async {
    _page = 1;
    _hasMore = true;
    _packages.clear();
    state = const AsyncLoading();
    await _fetch(query: query);
  }

  Future<void> fetchMore({String? query}) async {
    if (!_hasMore || state is AsyncLoading) return;
    _page++;
    await _fetch(query: query);
  }

  // Dipanggil saat shake terdeteksi
  Future<void> refresh({String? query}) => fetchInitial(query: query);

  Future<void> _fetch({String? query}) async {
    final result = await ref.read(packageServiceProvider).getAll(
      page: _page,
      perPage: 10,
      currentStatus: statusFilter,
      q: query,
    );
    _hasMore = _page < result.meta.totalPages;
    _packages.addAll(result.packages);
    state = AsyncData(List.unmodifiable(_packages));
  }
}
```

### ShakeDetector

```dart
// lib/core/sensors/shake_detector.dart
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class ShakeDetector {
  static const double _shakeThreshold = 15.0;
  static const int _shakeTimeLimit = 500; // ms

  DateTime? _lastShakeTime;

  Stream<void> get onShake => accelerometerEventStream().where((event) {
    final magnitude = sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );
    final now = DateTime.now();
    if (magnitude > _shakeThreshold) {
      if (_lastShakeTime == null ||
          now.difference(_lastShakeTime!).inMilliseconds > _shakeTimeLimit) {
        _lastShakeTime = now;
        return true;
      }
    }
    return false;
  }).map((_) {});
}
```

### GyroscopeService

```dart
// lib/core/sensors/gyroscope_service.dart
// Digunakan oleh mini game "Sortir Paket" untuk kontrol tilt
import 'package:sensors_plus/sensors_plus.dart';

class GyroscopeService {
  /// Stream nilai sumbu Y gyroscope (rotasi kiri/kanan)
  /// Positif = miring ke kanan, negatif = miring ke kiri
  Stream<double> get tiltY =>
      gyroscopeEventStream().map((event) => event.y);

  /// Stream raw event jika game butuh semua sumbu
  Stream<GyroscopeEvent> get rawEvents => gyroscopeEventStream();
}
```

**Sensor Summary:**

| Sensor | Package | Dipakai di | Kegunaan |
|---|---|---|---|
| Accelerometer | `sensors_plus` | `PackageListScreen` | Shake to refresh daftar paket |
| Gyroscope | `sensors_plus` | `MiniGameScreen` | Tilt kiri/kanan untuk gerakkan paket |

### NotificationService

```dart
// lib/core/notifications/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../main.dart';   // instance plugin

class NotificationService {
  static Future<void> showStatusUpdate({
    required String resi,
    required String newStatus,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'status_channel',
      'Status Paket',
      channelDescription: 'Notifikasi perubahan status paket',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      resi.hashCode,
      'Status Paket Diperbarui',
      'Paket $resi → $newStatus',
      details,
    );
  }
}
```

---

## Flow Restore Session

```
main.dart
  ↓ runApp()
  authProvider.restoreSession()
  ↓ baca token dari secureStorage
  ↓ GET /auth/me
  ← user data (atau error 401)
  ↓
  go_router: isAuthenticated → '/' | tidak → '/login'
```

## Flow Update Status + Notifikasi

```
PackageDetailScreen
  ↓ tap tombol status
  ConfirmBottomSheet
  ↓ konfirmasi
  packageDetailProvider.updateStatus(id, status, notes)
  ↓ PATCH /packages/:id/status
  ← package data terbaru
  ↓
  NotificationService.showStatusUpdate(resi, newStatus)  ← notifikasi lokal
  invalidate packageListProvider   ← list refresh
  invalidate trackerProvider       ← tracker refresh
  ↓
  SnackBar sukses
```

---

## Theme

```dart
// lib/core/theme/app_colors.dart
class AppColors {
  static const primary   = Color(0xFF1E3A5F);   // Navy biru
  static const accent    = Color(0xFFF59E0B);   // Amber
  static const success   = Color(0xFF10B981);   // Hijau
  static const danger    = Color(0xFFEF4444);   // Merah
  static const warning   = Color(0xFFF59E0B);   // Kuning
  static const surface   = Color(0xFFF8FAFC);   // Abu muda
  static const textPrimary   = Color(0xFF1E293B);
  static const textSecondary = Color(0xFF64748B);
}
```

---

## Konvensi Kode

- Nama file `snake_case`, nama class `PascalCase`, variabel `camelCase`.
- Provider di-annotate `@riverpod` atau `@Riverpod(keepAlive: true)`.
- Model punya `fromJson` factory dan opsional `toJson`.
- Service hanya berisi API call, tidak ada logika bisnis.
- Logika bisnis ada di provider.
- Error di-throw sebagai `ApiException`, ditangkap di provider, diexpose via `AsyncError`.
- Widget screen yang besar dipecah menjadi sub-widget private di file yang sama.
