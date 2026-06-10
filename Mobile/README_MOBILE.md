# IAMExpress Mobile App

Aplikasi mobile Flutter untuk IAMExpress — dipakai oleh **Linehaul** dan **Courier**

## Gambaran Umum

Aplikasi mobile ini dipakai oleh dua role:

| Role | Akses |
|---|---|
| **Linehaul** | Lihat paket yang di-assign, update status transit antar gudang |
| **Courier** | Lihat paket yang di-assign, update status delivery ke penerima akhir |

Aplikasi web (React.js) untuk Super Admin & Warehouse Admin ada di repository terpisah.
Backend REST API (Node.js + Express) dipakai bersama oleh web dan mobile.

---

## Quick Start

```bash
# 1. Clone & masuk ke folder
git clone <repo-url>
cd mobile

# 2. Install dependencies
flutter pub get

# 3. Generate Riverpod code
dart run build_runner build --delete-conflicting-outputs

# 4. Jalankan di emulator (auto-detect 10.0.2.2)
flutter run

# 4b. Jalankan di HP fisik (ganti IP laptop)
flutter run \
  --dart-define=API_BASE_URL=http://<IP_WIFI_LAPTOP>:3000/api/v1
```

> API Base URL otomatis mendeteksi platform:
> - **Web (Edge/Chrome):** `localhost:3000`
> - **Android Emulator:** `10.0.2.2:3000`
> - **HP Fisik:** Wajib pakai `--dart-define` dengan IP WiFi laptop

---

## Login Demo

| Email | Password | Role |
|---|---|---|
| linehaul1@iamexpress.id | user123 | Linehaul |
| kurir1@iamexpress.id | user123 | Courier |

---

## Dokumentasi Lanjutan

| File | Isi |
|---|---|
| [setup_mobile.md](setup_mobile.md) | Install Flutter, `pubspec.yaml` lengkap, Android/iOS config, env |
| [architecture_mobile.md](architecture_mobile.md) | Struktur folder, Riverpod, go_router, tema, konvensi kode |
| [api-integration_mobile.md](api-integration_mobile.md) | Dio HTTP client, interceptor JWT, semua service + model Dart |
| [screens_mobile.md](screens_mobile.md) | Semua screen, widget reusable, props, dan contoh kode |

---

## Tech Stack

| Teknologi | Kegunaan |
|---|---|
| Flutter 3.x (Dart) | UI framework cross-platform (Android & iOS) |
| Riverpod 2.x | State management reaktif |
| Dio | HTTP client (dengan interceptor JWT) |
| go_router | Deklaratif client-side navigation |
| flutter_secure_storage | Simpan JWT token secara aman di device |
| local_auth | Autentikasi biometrik (fingerprint & face ID) |
| shared_preferences | Simpan preferensi ringan |
| google_fonts | Tipografi (font Inter) |
| intl | Format tanggal dan angka (Rupiah, WIB) |
| flutter_map | Peta interaktif berbasis OpenStreetMap |
| latlong2 | Model koordinat latitude/longitude |
| geolocator | Akses GPS device |
| sensors_plus | Accelerometer (Shake to refresh, Hujan Paket) + Gyroscope (Mini game) |
| flutter_local_notifications | Notifikasi lokal saat status paket berubah |
| cached_network_image | Load & cache foto profil |
| image_picker | Ganti foto profil |
| url_launcher | Buka Google Maps eksternal |

---

## Deployment

Aplikasi didistribusikan sebagai **APK internal** (bukan via Play Store).

```
flutter build apk --release \
  --dart-define=API_BASE_URL=https://api.iamexpress.id/api/v1

Output: build/app/outputs/flutter-apk/app-release.apk
```

---

## Struktur Bottom Navigation (5 Menu)

| Index | Label | Route | Ikon |
|---|---|---|---|
| 0 | Dashboard | `/` | `dashboard` |
| 1 | Paket | `/packages` | `inventory_2` |
| 2 | Peta | `/peta` | `map` |
| 3 | AI Chat | `/ai-chat` | `smart_toy` |
| 4 | Profil | `/profile` | `person` |

---

## Fitur Lengkap

**Linehaul & Courier (umum):**
- Login email/password + biometric (fingerprint/face)
- Dashboard personal: total ditugaskan, sedang dikerjakan, selesai hari ini
- List paket dengan 4 tab (Semua, Di Gudang, Diantar, Selesai) + search + infinite scroll
- Shake to refresh (Accelerometer via `sensors_plus`)
- Detail paket: info lengkap, riwayat tracker
- Peta tujuan paket + tombol buka Google Maps
- Update status paket (sesuai role)
- Notifikasi lokal saat status paket berubah
- AI chat assistant (Gemini)
- Profil: foto, nama, role

**Tools TPM (di menu Profil):**
- Konversi mata uang (IDR, USD, EUR, SGD, JPY) — Menggunakan open.er-api.com
- Konversi waktu (WIB, WITA, WIT, London)
- Cuaca lokasi terkini (Open-Meteo) + Reverse Geocoding kota (Nominatim)

**Fitur tambahan:**
- Mini game "Sortir Paket" — 3 Mode: Sortir (Tap), Sortir (Gyroscope), Hujan Paket (Accelerometer)
- Saran & Kesan mata kuliah TPM
- Logout dengan konfirmasi

---

## Alur Status per Role

### Linehaul
```
[Assigned to Linehaul] → [Picked Up] → [In Transit] → [Arrived at Warehouse]
```

### Courier
```
[Assigned to Courier] → [Out For Delivery] → [Delivered] / [Failed Delivery]
```

---

## Catatan Penting

- Hanya role `LINEHAUL` dan `COURIER` yang bisa login di aplikasi mobile ini.
- Token disimpan di `flutter_secure_storage` — lebih aman dari `SharedPreferences`.
- Biometric auth adalah fitur device-side — backend hanya menyimpan flag `biometrics_enabled`.
- Jika token expired (401), app otomatis redirect ke halaman login.
- Notifikasi bersifat lokal (device-side) — dipicu saat user sendiri update status paket.
- CORS tidak berlaku di mobile — Dio tidak terkena CORS policy browser.

## Troubleshooting

| Error | Solusi |
|---|---|
| `flutter pub get` gagal | Jalankan `flutter upgrade`, sesuaikan constraint di pubspec |
| `local_auth` MissingPluginException | Pastikan `MainActivity` extends `FlutterFragmentActivity` |
| `flutter_secure_storage` error emulator | Tambahkan `encryptedSharedPreferences: true` di AndroidOptions |
| Peta flutter_map blank | Cek koneksi internet di emulator |
| GPS tidak berfungsi di emulator | Set lokasi manual: Extended Controls → Location |
| API tidak terhubung dari emulator | Otomatis pakai `10.0.2.2`, untuk HP fisik pakai `--dart-define=API_BASE_URL=http://<IP_LAPTOP>:3000/api/v1` |
| Sensor accelerometer null | Pastikan `sensors_plus` sudah di pubspec dan permission sudah di-request |
| Peta 403 Access Blocked | Pastikan `TileLayer` punya `userAgentPackageName` |
| AI Chat error | Cek `GEMINI_API_KEY` di Backend/.env, pastikan dari Google AI Studio (berawalan `AIzaSy`) |
