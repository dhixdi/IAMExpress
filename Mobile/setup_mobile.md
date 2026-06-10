# Setup Guide — IAMExpress Mobile App

## Prasyarat

| Tool | Versi Minimum | Cek |
|---|---|---|
| Flutter SDK | 3.10.x | `flutter --version` |
| Dart SDK | 3.0.x (bundled) | `dart --version` |
| Android Studio | Hedgehog (2023.1) | — |
| Xcode (iOS, Mac only) | 15.x | — |
| Git | Terbaru | `git --version` |

Jalankan `flutter doctor` untuk memastikan semua tool terpasang.
Backend IAMExpress harus sudah berjalan sebelum menjalankan aplikasi.

---

## 1. Install Dependencies

```bash
flutter pub get
```

---

## 2. pubspec.yaml — Dependency Lengkap

```yaml
name: iamexpress_mobile
description: IAMExpress Mobile — Linehaul & Courier App
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: '>=3.10.0'

dependencies:
  flutter:
    sdk: flutter

  # State management
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3

  # HTTP client
  dio: ^5.4.0

  # Storage aman untuk token JWT
  flutter_secure_storage: ^9.0.0

  # Biometrik (fingerprint & face)
  local_auth: ^2.1.8

  # Navigasi deklaratif
  go_router: ^13.2.0

  # Preferensi ringan (tema, bahasa)
  shared_preferences: ^2.2.2

  # Format tanggal, angka, dan mata uang
  intl: ^0.19.0

  # Font
  google_fonts: ^6.1.0

  # Peta interaktif (OpenStreetMap)
  flutter_map: ^6.1.0
  latlong2: ^0.9.0

  # GPS
  geolocator: ^11.0.0
  permission_handler: ^11.3.0

  # Buka Google Maps eksternal
  url_launcher: ^6.2.5

  # Sensor accelerometer (shake to refresh)
  sensors_plus: ^4.0.2

  # Notifikasi lokal
  flutter_local_notifications: ^17.1.2

  # Load & cache foto profil dari URL
  cached_network_image: ^3.3.1

  # Ganti foto profil (kamera & galeri)
  image_picker: ^1.0.7

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  build_runner: ^2.4.8
  riverpod_generator: ^2.3.9

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/
    - assets/animations/
  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
        - asset: assets/fonts/Inter-Medium.ttf
          weight: 500
        - asset: assets/fonts/Inter-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Inter-Bold.ttf
          weight: 700
```

---

## 3. Konfigurasi Environment

Aplikasi menggunakan `--dart-define` untuk inject environment variable. Buat file `run_dev.sh`:

```bash
# run_dev.sh — jangan di-commit ke Git
flutter run \
  --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1 \
  --dart-define=EXCHANGERATE_API_KEY=isi_api_key_kamu
```

> - `10.0.2.2` = alias localhost untuk Android emulator
> - Untuk device fisik gunakan IP lokal, misal `192.168.1.100:3000`
> - ExchangeRate API Key: daftar gratis di https://www.exchangerate-api.com
> - Cuaca menggunakan **Open-Meteo** — tidak perlu API key

Konstanta dibaca di `lib/core/constants/app_constants.dart`:

```dart
class AppConstants {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api/v1',
  );

  static const String exchangeRateApiKey = String.fromEnvironment(
    'EXCHANGERATE_API_KEY',
    defaultValue: '',
  );

  static const String appName = 'IAMExpress';

  // Open-Meteo (cuaca) — tidak perlu API key
  static const String weatherBaseUrl =
      'https://api.open-meteo.com/v1';

  // ExchangeRate-API base URL
  static const String exchangeRateBaseUrl =
      'https://v6.exchangerate-api.com/v6';
}
```

---

## 4. Setup Android

### `android/app/src/main/AndroidManifest.xml`

```xml
<manifest ...>
  <!-- Internet (wajib untuk API, peta, cuaca, kurs) -->
  <uses-permission android:name="android.permission.INTERNET" />

  <!-- GPS (LBS, peta paket) -->
  <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
  <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

  <!-- Biometrik -->
  <uses-permission android:name="android.permission.USE_BIOMETRIC" />
  <uses-permission android:name="android.permission.USE_FINGERPRINT" />

  <!-- Kamera & galeri (ganti foto profil) -->
  <uses-permission android:name="android.permission.CAMERA" />
  <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
      android:maxSdkVersion="32" />
  <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />

  <!-- Notifikasi lokal (Android 13+) -->
  <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

  <!-- Sensor accelerometer (tidak perlu permission eksplisit di Android) -->

  <application
      android:label="IAMExpress"
      android:icon="@mipmap/ic_launcher"
      ...>

    <!-- flutter_local_notifications: channel -->
    <meta-data
        android:name="flutterLocalNotificationsKeepAlive"
        android:value="true" />

    <activity ...>
      ...
    </activity>
  </application>
</manifest>
```

### `android/app/build.gradle`

```gradle
android {
  defaultConfig {
    minSdkVersion 23     // wajib untuk local_auth & flutter_secure_storage
    targetSdkVersion 34
    compileSdkVersion 34
  }
}
```

### `android/app/src/main/kotlin/.../MainActivity.kt`

```kotlin
import io.flutter.embedding.android.FlutterFragmentActivity

// FlutterFragmentActivity wajib untuk local_auth
class MainActivity: FlutterFragmentActivity()
```

---

## 5. Setup iOS (opsional)

### `ios/Runner/Info.plist`

```xml
<!-- GPS -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>IAMExpress butuh lokasi untuk fitur peta paket.</string>

<!-- Biometrik -->
<key>NSFaceIDUsageDescription</key>
<string>IAMExpress menggunakan Face ID untuk login yang lebih cepat.</string>

<!-- Kamera -->
<key>NSCameraUsageDescription</key>
<string>IAMExpress butuh kamera untuk mengambil foto profil.</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>IAMExpress butuh akses galeri untuk memilih foto profil.</string>
```

---

## 6. Inisialisasi Notifikasi & Sensor di main.dart

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi notifikasi lokal
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosInit = DarwinInitializationSettings();
  const initSettings = InitializationSettings(
    android: androidInit,
    iOS: iosInit,
  );
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  runApp(const ProviderScope(child: App()));
}
```

---

## 7. Menjalankan Development

```bash
# Pakai script run_dev.sh
chmod +x run_dev.sh
./run_dev.sh

# Atau langsung
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1 \
            --dart-define=OPENWEATHER_API_KEY=xxx \
            --dart-define=EXCHANGERATE_API_KEY=xxx
```

---

## 8. Script yang Tersedia

| Perintah | Keterangan |
|---|---|
| `flutter run` | Jalankan mode debug |
| `flutter build apk --release` | Build APK release |
| `flutter build appbundle` | Build AAB |
| `flutter test` | Jalankan unit test |
| `flutter analyze` | Linter |
| `dart run build_runner build --delete-conflicting-outputs` | Generate kode Riverpod |
| `dart run build_runner watch --delete-conflicting-outputs` | Watch mode |

---

## 9. Verifikasi Setup

1. `flutter run` berhasil → halaman login muncul
2. Login dengan `kurir1@iamexpress.id` / `user123`
3. Dashboard tampil dengan data dari backend
4. Coba shake device/emulator → PackageListScreen refresh
5. Masuk ke Profil → Tools TPM → Konversi Mata Uang → pastikan data kurs muncul
6. Profil → Tools TPM → Cuaca → pastikan cuaca muncul (perlu GPS aktif)

---

## 10. Troubleshooting

| Error | Solusi |
|---|---|
| `sensors_plus` tidak baca data | Cek emulator mendukung sensor; pakai device fisik untuk akurasi |
| Gyroscope tidak respons di emulator | Normal — emulator biasanya tidak support gyroscope. Gunakan Toggle ke "Tap Mode" di pojok kanan atas game |
| Notifikasi tidak muncul Android 13+ | Request `POST_NOTIFICATIONS` permission di runtime |
| `flutter_local_notifications` crash | Pastikan inisialisasi dipanggil sebelum `runApp()` di main.dart |
| Kurs tidak muncul | Cek `EXCHANGERATE_API_KEY` di `--dart-define` sudah diisi |
| Cuaca tidak muncul | Cek GPS/location permission aktif (Open-Meteo tidak perlu API key) |
| `url_launcher` tidak buka Google Maps | Tambahkan `<queries>` intent di AndroidManifest untuk Android 11+ |
