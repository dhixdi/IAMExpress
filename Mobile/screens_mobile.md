# Screens & Widgets — IAMExpress Mobile App

Daftar semua screen, widget reusable, props, dan contoh kode.

---

## Struktur Bottom Navigation (5 Item)

```dart
// lib/shared/widgets/app_bottom_nav.dart
const _navItems = [
  (label: 'Dashboard', icon: Icons.dashboard_outlined,    route: Routes.dashboard),
  (label: 'Paket',     icon: Icons.inventory_2_outlined,  route: Routes.packages),
  (label: 'Peta',      icon: Icons.map_outlined,          route: Routes.peta),
  (label: 'AI Chat',   icon: Icons.smart_toy_outlined,    route: Routes.aiChat),
  (label: 'Profil',    icon: Icons.person_outline,        route: Routes.profile),
];
```

---

## Screens

### 1. `LoginScreen`

**Route:** `/login` | **Akses:** Public

Halaman login dengan form email/password. Jika `biometrics_enabled = true` pada data user yang tersimpan, tampilkan tombol biometrik di bawah form.

```dart
// Biometric login flow
Future<void> _loginWithBiometrics(BuildContext context) async {
  final auth = LocalAuthentication();
  final canCheck = await auth.canCheckBiometrics;
  if (!canCheck) return;

  final didAuth = await auth.authenticate(
    localizedReason: 'Gunakan biometrik untuk masuk ke IAMExpress',
    options: const AuthenticationOptions(biometricOnly: true),
  );
  if (didAuth && context.mounted) {
    await ref.read(authProvider.notifier).restoreSession();
  }
}
```

**Validasi:**
- Email wajib diisi dan format valid
- Password wajib diisi
- Error dari API ditampilkan sebagai teks merah di bawah form

---

### 2. `DashboardScreen`

**Route:** `/` | **Akses:** LINEHAUL, COURIER

Halaman utama setelah login. Menampilkan greeting dan 3 `StatsCard` dengan data dari `GET /dashboard`.

**Layout:**
```
"Selamat pagi, [nama]!"          ← greeting dinamis sesuai jam
[StatsCard] Total Ditugaskan
[StatsCard] Sedang Dikerjakan
[StatsCard] Selesai Hari Ini
[Button]    Lihat Paket Saya →   ← navigate ke /packages
```

---

### 3. `PackageListScreen`

**Route:** `/packages` | **Akses:** LINEHAUL, COURIER

Daftar paket yang di-assign ke user. Mendukung 4 tab, search, infinite scroll, dan **shake to refresh**.

**4 Tab berdasarkan status:**

| Tab | Status Filter | Linehaul | Courier |
|---|---|---|---|
| Semua | — (semua) | ✓ | ✓ |
| Di Gudang | `Assigned to Linehaul` / `Assigned to Courier` | ✓ | ✓ |
| Diantar | `Picked Up`, `In Transit` / `Out For Delivery` | ✓ | ✓ |
| Selesai | `Arrived at Warehouse` / `Delivered`, `Failed Delivery` | ✓ | ✓ |

**Shake to Refresh — integrasi Accelerometer:**

```dart
// lib/features/packages/screens/package_list_screen.dart
class PackageListScreen extends ConsumerStatefulWidget { ... }

class _PackageListScreenState extends ConsumerState<PackageListScreen> {
  late final ShakeDetector _shakeDetector;
  late final StreamSubscription _shakeSub;

  @override
  void initState() {
    super.initState();
    _shakeDetector = ShakeDetector();
    _shakeSub = _shakeDetector.onShake.listen((_) {
      // Refresh tab aktif saat shake terdeteksi
      ref.read(packageListProvider(activeTabFilter).notifier).refresh();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Daftar diperbarui')),
      );
    });
  }

  @override
  void dispose() {
    _shakeSub.cancel();
    super.dispose();
  }
}
```

**Search bar:**
- Debounce 500ms sebelum trigger fetch
- Reset ke halaman 1 saat query berubah
- Placeholder: "Cari resi atau nama penerima..."

**Infinite scroll:**
- Deteksi scroll mendekati bawah → `packageListProvider.fetchMore()`
- Loading spinner muncul di bawah list saat fetch more

---

### 4. `PackageDetailScreen`

**Route:** `/packages/:id` | **Akses:** LINEHAUL, COURIER

Detail lengkap satu paket beserta tombol update status.

| Parameter | Tipe | Keterangan |
|---|---|---|
| `packageId` | `int` | ID paket dari path parameter |

**Layout:**
```
[Header] Resi: IAM000001 + StatusBadge

[Section] Info Paket
  Nama, Berat, Jenis Layanan, Ongkos Kirim (format Rupiah)

[Section] Pengirim
  Alamat pengirim, No HP

[Section] Penerima
  Alamat tujuan, No HP

[Button]  Lihat Riwayat Tracking →   ← navigate ke /packages/:id/tracker

[Section] Tombol Aksi (muncul sesuai role & status saat ini)
```

**Tombol status berdasarkan role dan `current_status`:**

| Role | `current_status` | Tombol yang Muncul |
|---|---|---|
| LINEHAUL | `Assigned to Linehaul` | [Picked Up] |
| LINEHAUL | `Picked Up` | [In Transit] |
| LINEHAUL | `In Transit` | [Arrived at Warehouse] |
| COURIER | `Assigned to Courier` | [Out For Delivery] |
| COURIER | `Out For Delivery` | **3 tombol:** [🗺 Lihat Peta], [✓ Selesai (Delivered)], [✗ Gagal Antar (Failed Delivery)] |

Tap [Lihat Peta] → langsung navigate ke `/peta` tapi dengan auto-focus ke koordinat `receiver_lat/lng` paket tersebut, SEKALIGUS buka bottom sheet info paket + tombol "Buka di Google Maps" untuk navigasi eksternal.

Tap [Selesai] → `ConfirmBottomSheet` → konfirmasi → update status ke `Delivered` → notifikasi lokal.

Tap [Gagal Antar] → `ConfirmBottomSheet` dengan input notes opsional → konfirmasi → update status ke `Failed Delivery`. Setelah `Failed Delivery`, status paket dapat di-assign ulang ke Courier oleh WAREHOUSE_ADMIN (assign ulang akan mengubah status kembali ke `Assigned to Courier`).

---

### 5. `PackageTrackerScreen`

**Route:** `/packages/:id/tracker` | **Akses:** LINEHAUL, COURIER

Timeline riwayat lengkap perjalanan satu paket dari awal hingga status terkini.

| Parameter | Tipe | Keterangan |
|---|---|---|
| `packageId` | `int` | ID paket dari path parameter |

**Layout:**
```
AppBar: "Riwayat Paket IAM000001"

TrackerTimeline (entry dari terlama ke terbaru):
  ● [status] [nama gudang]
    Oleh: [nama user]
    [timestamp WIB]
    [notes jika ada]
```

---

### 6. `PetaScreen`

**Route:** `/peta` | **Akses:** LINEHAUL, COURIER | **Bottom Nav index: 2**

Peta interaktif yang menampilkan semua pin tujuan paket yang masih aktif (status bukan `Delivered` / `Arrived at Warehouse`). Memenuhi requirement **LBS (Location Based Service)**.

```dart
// lib/features/peta/screens/peta_screen.dart
class PetaScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packagesAsync = ref.watch(packageListProvider(null));

    return packagesAsync.when(
      loading: () => const LoadingOverlay(),
      error: (e, _) => ErrorView(message: e.toString()),
      data: (packages) {
        // Filter hanya paket yang punya koordinat tujuan
        final activePackages = packages.where((p) =>
          p.receiverLat != null && p.receiverLng != null
        ).toList();

        return FlutterMap(
          options: const MapOptions(
            initialCenter: LatLng(-7.7972, 110.3688), // Yogyakarta
            initialZoom: 10,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            ),
            MarkerLayer(
              markers: activePackages.map((pkg) => Marker(
                point: LatLng(pkg.receiverLat!, pkg.receiverLng!),
                child: GestureDetector(
                  onTap: () => _showPackageInfo(context, pkg),
                  child: const Icon(Icons.location_pin,
                    color: AppColors.accent, size: 36),
                ),
              )).toList(),
            ),
          ],
        );
      },
    );
  }
}
```

**Fitur:**
- Pin berwarna amber untuk setiap paket aktif
- Tap pin → bottom sheet info singkat (resi, nama, alamat tujuan, status)
- Tombol "Buka di Google Maps" → `url_launcher` buka navigasi eksternal
- Lokasi device tampil sebagai pin biru (GPS user)

**Tombol buka Google Maps:**

```dart
Future<void> _openGoogleMaps(double lat, double lng) async {
  final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
  if (await canLaunchUrl(uri)) await launchUrl(uri);
}
```

---

### 7. `AiChatScreen`

**Route:** `/ai-chat` | **Akses:** LINEHAUL, COURIER | **Bottom Nav index: 3**

Chat dengan AI assistant Gemini. Semua logika chat ada di `chatProvider`.

**Layout:**
```
AppBar: "AI Assistant"

[ListView] Bubble chat
  User  → bubble kanan (warna primary)
  AI    → bubble kiri (warna abu)
  Loading → animated dots saat menunggu response

[TextField] + [Tombol Kirim]
```

**Contoh pertanyaan:**
- "Berapa paket saya yang masih aktif?"
- "Paket mana yang harus saya antar dulu?"
- "Cari paket IAM000003"
- "Kondisi cuaca sekarang aman untuk delivery?"

Riwayat chat tersimpan di `chatProvider` selama sesi berlangsung (tidak persist ke server).

---

### 8. `ProfileScreen`

**Route:** `/profile` | **Akses:** LINEHAUL, COURIER | **Bottom Nav index: 4**

Profil user dan semua menu pengaturan termasuk Tools TPM.

**Layout:**
```
[Avatar] Foto profil + nama + role + gudang asal
[Button] Ganti Foto

─── Akun ───────────────────────────
[ListTile] Ganti Password         →  /profile/password
[ListTile] Pengaturan Biometrik   →  /profile/biometrics

─── Tools TPM ──────────────────────
[ListTile] Konversi Mata Uang     →  /profile/currency
[ListTile] Konversi Waktu         →  /profile/timezone
[ListTile] Cuaca                  →  /profile/weather

─── Lainnya ─────────────────────────
[ListTile] Mini Game              →  /profile/mini-game
[ListTile] Saran & Kesan TPM     →  /profile/saran-kesan
[ListTile] Logout                 →  ConfirmBottomSheet → authProvider.logout()
```

---

### 9. `ChangePasswordScreen`

**Route:** `/profile/password`

Form ganti password dengan validasi:

| Field | Validasi |
|---|---|
| Password Lama | Wajib diisi |
| Password Baru | Wajib, minimal 6 karakter |
| Konfirmasi Password | Harus sama dengan Password Baru |

Tap Simpan → `userService.changePassword()` → snackbar sukses → `context.pop()`

---

### 10. `BiometricSettingScreen`

**Route:** `/profile/biometrics`

Toggle biometrik + pilih tipe.

```
Switch "Aktifkan Biometrik"         ← toggle on/off

Jika ON:
  Radio "Sidik Jari" (fingerprint)
  Radio "Wajah" (face)

[Info] "Validasi dilakukan di perangkat Anda. Data biometrik tidak dikirim ke server."

[Button] Simpan → userService.updateBiometrics()
```

---

### 11. `CurrencyScreen` — Tools TPM

**Route:** `/profile/currency`

Konversi mata uang terintegrasi dengan konsep ongkos kirim paket.

**Mata uang yang didukung:** IDR, USD, EUR, SGD, JPY

```dart
// lib/features/tools_tpm/currency/screens/currency_screen.dart
// UI utama:
// [Dropdown] Dari: IDR ▼
// [TextField] Nominal: 37.500
// [Dropdown] Ke: USD ▼
// [Result]   = $ 2.33
//
// Tombol swap ⇄ untuk balik arah konversi
//
// [Section] Kurs Hari Ini (dari ExchangeRate-API)
//   1 IDR = 0.000062 USD
//   1 IDR = 0.000057 EUR
//   1 IDR = 0.000083 SGD
//   1 IDR = 0.0091 JPY
//
// [Section] Konversi Ongkos Kirim Paket Aktif
//   "Ongkos kirim rata-rata paketmu: Rp 45.000"
//   "= $ 2.79 | € 2.57 | S$ 3.74 | ¥ 410"
//
// [Footer] "Diperbarui: [waktu update kurs]"
```

**Data kurs:** Di-fetch dari ExchangeRate-API saat screen dibuka. Di-cache oleh Riverpod selama sesi.

---

### 12. `TimezoneScreen` — Tools TPM

**Route:** `/profile/timezone`

Konversi waktu 4 zona (WIB, WITA, WIT, London) terintegrasi dengan timestamp paket.

```dart
// UI:
// [Jam digital berjalan real-time]
//   WIB    : 14:30:25
//   WITA   : 15:30:25
//   WIT    : 16:30:25
//   London : 07:30:25
//
// Jam diupdate setiap detik via Timer.periodic()
//
// [Section] Konversi Manual
//   [TimePicker] Pilih waktu input
//   [Dropdown]   Dari zona: WIB ▼
//   [Result]     WITA: 15:30 | WIT: 16:30 | London: 07:30
//
// [Section] Timestamp Paket Terakhir Diupdate
//   "Status terakhir diupdate: 12:45 WIB"
//   WIB    : 12:45
//   WITA   : 13:45
//   WIT    : 14:45
//   London : 05:45
```

Kalkulasi murni lokal — tidak membutuhkan API eksternal.

---

### 13. `WeatherScreen` — Tools TPM

**Route:** `/profile/weather`

Cuaca lokasi terkini menggunakan GPS device + **Open-Meteo API** (gratis, tanpa API key).

```dart
// UI (setelah izin lokasi diberikan):
//
// [Koordinat]  -7.4797° S, 110.2177° E
// [Ikon cuaca] + [Deskripsi] "Berawan sebagian"
// [Suhu] 28°C
// [Kelembaban] 75%
// [Angin] 12 km/h
//
// [Banner kontekstual]
// Jika hujan   → "🌧 Hujan — Hati-hati saat delivery, paket rentan basah"
// Jika panas   → "☀ Cuaca cerah — Kondisi ideal untuk pengiriman"
// Jika angin   → "💨 Angin kencang — Waspada saat berkendara"
// Jika badai   → "⛈ Badai — Pertimbangkan menunda pengiriman"
//
// [Footer] "Sumber: Open-Meteo | Diperbarui: [waktu]"
```

```dart
// lib/features/tools_tpm/weather/screens/weather_screen.dart
// Request permission GPS sebelum fetch:
Future<void> _requestAndFetch() async {
  final permission = await Geolocator.requestPermission();
  if (permission == LocationPermission.denied) {
    // Tampilkan pesan "Izin lokasi diperlukan"
    return;
  }
  ref.invalidate(weatherProvider);
}
```

---

### 14. `MiniGameScreen` — Mini Game "Sortir Paket"

**Route:** `/profile/mini-game`

Game sederhana bertema ekspedisi. Player menyortir paket yang jatuh menggunakan **kemiringan device (Gyroscope)** untuk menggeser paket, ditambah tap gudang sebagai fallback.

**Sensor yang digunakan:**
- `sensors_plus` → `gyroscopeEventStream()` — baca sumbu Y (kiri/kanan) untuk gerakkan paket
- Accelerometer tetap dipakai di PackageListScreen (shake to refresh) — keduanya aktif di app

**Konsep Game:**
- Paket jatuh perlahan dari atas layar satu per satu
- Setiap paket punya label kota tujuan (Jogja, Jakarta, Surabaya)
- Di bawah layar ada 3 kotak gudang
- **Miringkan device ke kiri/kanan** → paket bergeser mengikuti kemiringan (gyroscope)
- Paket masuk ke gudang saat menyentuh salah satu kotak di bawah
- Tap kotak gudang sebagai alternatif kontrol (untuk emulator)
- Benar → +10 poin | Salah → -5 poin | Lewat tanpa ditangkap → -2 poin
- Kecepatan jatuh bertambah setiap 15 detik (semakin susah)
- Waktu 60 detik, skor ditampilkan di akhir

```dart
// lib/features/mini_game/providers/game_provider.dart
class GameState {
  final int score;
  final int timeLeft;           // detik, hitung mundur dari 60
  final bool isPlaying;
  final bool isGameOver;
  final String? currentPackageCity;   // label paket yang sedang jatuh
  final double packageX;        // posisi horizontal paket (0.0 = kiri, 1.0 = kanan)
  final double packageY;        // posisi vertikal paket (0.0 = atas, 1.0 = bawah)
  final double fallSpeed;       // kecepatan jatuh, naik seiring waktu
  final int controlMode;        // 0 = gyroscope, 1 = tap (untuk emulator)

  const GameState({
    this.score = 0,
    this.timeLeft = 60,
    this.isPlaying = false,
    this.isGameOver = false,
    this.currentPackageCity,
    this.packageX = 0.5,
    this.packageY = 0.0,
    this.fallSpeed = 0.008,
    this.controlMode = 0,
  });

  GameState copyWith({...});
}

@riverpod
class Game extends _$Game {
  Timer? _timer;
  Timer? _physicsTimer;
  StreamSubscription? _gyroSub;

  @override
  GameState build() => const GameState();

  void startGame({int controlMode = 0}) {
    state = GameState(isPlaying: true, controlMode: controlMode);
    _startCountdown();
    _startPhysics();
    if (controlMode == 0) _startGyroscope();
    _spawnPackage();
  }

  // Gyroscope: baca kemiringan sumbu Y → geser paket
  void _startGyroscope() {
    _gyroSub = gyroscopeEventStream().listen((event) {
      if (!state.isPlaying) return;
      // event.y positif = miring kanan, negatif = miring kiri
      // sensitivity: 0.02 per event (~60fps)
      final newX = (state.packageX + event.y * 0.02).clamp(0.05, 0.95);
      state = state.copyWith(packageX: newX);
    });
  }

  // Physics loop: jalankan paket jatuh setiap frame
  void _startPhysics() {
    _physicsTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!state.isPlaying) return;
      final newY = state.packageY + state.fallSpeed;

      if (newY >= 1.0) {
        // Paket sampai bawah tanpa ditangkap → -2 poin
        state = state.copyWith(
          score: state.score - 2,
          packageY: 0.0,
          packageX: 0.5,
        );
        _spawnPackage();
        return;
      }
      state = state.copyWith(packageY: newY);
    });
  }

  // Tap/drop ke gudang tertentu (fallback untuk emulator)
  void dropToWarehouse(String targetCity) {
    if (!state.isPlaying) return;
    final correct = targetCity == state.currentPackageCity;
    state = state.copyWith(
      score: state.score + (correct ? 10 : -5),
      packageY: 0.0,
      packageX: 0.5,
    );
    _spawnPackage();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.timeLeft <= 1) {
        _endGame();
      } else {
        // Tingkatkan kecepatan setiap 15 detik
        final elapsed = 60 - state.timeLeft + 1;
        final newSpeed = 0.008 + (elapsed ~/ 15) * 0.003;
        state = state.copyWith(
          timeLeft: state.timeLeft - 1,
          fallSpeed: newSpeed,
        );
      }
    });
  }

  void _endGame() {
    state = state.copyWith(isPlaying: false, isGameOver: true, timeLeft: 0);
    _timer?.cancel();
    _physicsTimer?.cancel();
    _gyroSub?.cancel();
  }

  void _spawnPackage() {
    const cities = ['Jogja', 'Jakarta', 'Surabaya', 'Bali', 'Medan'];
    final city = cities[Random().nextInt(cities.length)];
    state = state.copyWith(currentPackageCity: city, packageY: 0.0);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _physicsTimer?.cancel();
    _gyroSub?.cancel();
    super.dispose();
  }
}
```

**UI:**
```
[Score] Skor: 120          [Timer] ⏱ 45s

[Mode] 📱 Miring device untuk geser paket
       atau [Toggle] Tap Mode (untuk emulator)

┌─────────────────────────────┐
│                             │
│          📦 Jakarta         │  ← paket bergerak ikut kemiringan
│                             │
│                             │
│  [Jogja]  [Jakarta]  [Surabaya]  ← tap sebagai fallback
└─────────────────────────────┘

── Game Over ─────────────────
Skor Kamu: 230
⭐ Best: 310
[Button] Main Lagi
```

**Toggle Kontrol:**
Di pojok kanan atas ada tombol kecil ikon gyroscope / tap. Saat di emulator (gyroscope null/0 terus), user bisa switch ke tap mode. Toggle ini tersimpan di `SharedPreferences` agar tidak perlu set ulang setiap buka game.

---

### 15. `SaranKesanScreen` — Saran & Kesan TPM

**Route:** `/profile/saran-kesan`

Form saran dan kesan untuk mata kuliah Teknologi Pemrograman Mobile (TPM).

```dart
// UI:
// AppBar: "Saran & Kesan TPM"
//
// [Header] Mata Kuliah Teknologi Pemrograman Mobile
//          Semester Genap 2025/2026
//
// [Section] Kesan
//   [TextField multiline] "Tuliskan kesan kamu selama mengikuti mata kuliah TPM..."
//
// [Section] Saran
//   [TextField multiline] "Tuliskan saran kamu untuk pengembangan mata kuliah TPM..."
//
// [Rating] Beri penilaian: ★★★★☆
//
// [Button] Simpan
//   → simpan ke SharedPreferences (lokal, tidak dikirim ke server)
//   → tampilkan snackbar "Terima kasih atas saran dan kesanmu!"
//
// [Tampilan] Jika sudah pernah mengisi, tampilkan jawaban yang tersimpan
//            + tombol "Edit"
```

```dart
// lib/features/saran_kesan/screens/saran_kesan_screen.dart
// Simpan ke SharedPreferences:
Future<void> _save() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('saran', _saranController.text);
  await prefs.setString('kesan', _kesanController.text);
  await prefs.setInt('rating', _rating);
}

Future<void> _load() async {
  final prefs = await SharedPreferences.getInstance();
  _saranController.text = prefs.getString('saran') ?? '';
  _kesanController.text = prefs.getString('kesan') ?? '';
  _rating = prefs.getInt('rating') ?? 0;
}
```

---

## Shared Widgets

### `AppBottomNav`

```dart
AppBottomNav(currentIndex: 0)
// Dipakai otomatis oleh AppShell — tidak perlu dipanggil manual
```

| Index | Label | Route |
|---|---|---|
| 0 | Dashboard | `/` |
| 1 | Paket | `/packages` |
| 2 | Peta | `/peta` |
| 3 | AI Chat | `/ai-chat` |
| 4 | Profil | `/profile` |

---

### `StatusBadge`

```dart
StatusBadge(status: 'In Transit')
StatusBadge(status: 'Delivered')
StatusBadge(status: 'Failed Delivery')
```

| Status | Warna |
|---|---|
| Created | Abu-abu |
| Received at Warehouse | Biru muda |
| Assigned to Linehaul | Biru |
| Picked Up | Indigo |
| In Transit | Kuning |
| Arrived at Warehouse | Teal |
| Assigned to Courier | Oranye |
| Out For Delivery | Oranye tua |
| Delivered | Hijau |
| Failed Delivery | Merah |

---

### `PackageCard`

```dart
PackageCard(
  package: packageModel,
  onTap: () => context.go('/packages/${pkg.packageId}'),
)
```

Konten: resi (bold), nama paket, `StatusBadge`, alamat tujuan (1 baris), berat & jenis layanan.

---

### `StatsCard`

```dart
StatsCard(
  title: 'Total Ditugaskan',
  value: 10,
  icon: Icons.inventory_2_outlined,
  color: AppColors.primary,
)
```

---

### `TrackerTimeline`

```dart
TrackerTimeline(entries: trackerList)
// entries: List<TrackerModel> terurut ASC by timestamp
```

---

### `ConfirmBottomSheet`

```dart
showModalBottomSheet(
  context: context,
  builder: (_) => ConfirmBottomSheet(
    title: 'Update Status',
    message: 'Ubah status paket menjadi "In Transit"?',
    confirmLabel: 'Ya, Update',
    onConfirm: () { Navigator.pop(context); updateStatus(); },
    isDestructive: false,
  ),
);
```

---

## Konstanta Status Paket

```dart
// lib/core/constants/package_status.dart
class PackageStatus {
  static const assignedToLinehaul  = 'Assigned to Linehaul';
  static const pickedUp            = 'Picked Up';
  static const inTransit           = 'In Transit';
  static const arrivedAtWarehouse  = 'Arrived at Warehouse';
  static const assignedToCourier   = 'Assigned to Courier';
  static const outForDelivery      = 'Out For Delivery';
  static const delivered           = 'Delivered';
  static const failedDelivery      = 'Failed Delivery';

  // Tab filter helper
  static const linehaulTabDiGudang = [assignedToLinehaul];
  static const linehaulTabDiantar  = [pickedUp, inTransit];
  static const linehaulTabSelesai  = [arrivedAtWarehouse];

  static const courierTabDiGudang  = [assignedToCourier];
  static const courierTabDiantar   = [outForDelivery];
  static const courierTabSelesai   = [delivered, failedDelivery];

  /// Status berikutnya yang bisa dipilih sesuai role dan status saat ini
  static List<String> nextStatuses(String currentStatus, String role) {
    if (role == 'LINEHAUL') {
      return switch (currentStatus) {
        assignedToLinehaul => [pickedUp],
        pickedUp           => [inTransit],
        inTransit          => [arrivedAtWarehouse],
        _ => [],
      };
    }
    if (role == 'COURIER') {
      return switch (currentStatus) {
        assignedToCourier => [outForDelivery],
        outForDelivery    => [delivered, failedDelivery],
        // Catatan: setelah failedDelivery, WAREHOUSE_ADMIN harus assign ulang
        // (via endpoint /assign) untuk kembali ke assignedToCourier
        _ => [],
      };
    }
    return [];
  }
}
```

---

## Utility Functions

```dart
// format_currency.dart
formatCurrency(37500)   // → "Rp 37.500"

// format_date.dart
formatDate(DateTime.parse('2026-06-01T08:00:00Z'))
// → "1 Jun 2026, 15:00 WIB"

// status_color.dart
statusColor('Delivered')       // → Color(0xFF10B981)
statusColor('Failed Delivery') // → Color(0xFFEF4444)
statusColor('In Transit')      // → Color(0xFFF59E0B)
```
