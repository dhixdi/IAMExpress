# Design System — IAMExpress

Panduan visual terpusat untuk Web Admin (React.js) dan Mobile App (Flutter).
Semua keputusan warna, tipografi, spacing, dan komponen mengacu ke dokumen ini.

---

## Filosofi Desain

**IAMExpress** adalah sistem operasional internal — bukan produk konsumer. Desainnya harus:

- **Fungsional tanpa steril** — clean bukan berarti kosong. Setiap elemen punya tujuan.
- **Density yang tepat** — dashboard harus padat informasi tanpa terasa sesak.
- **Hierarki status yang kuat** — status paket adalah jantung sistem; warna dan badge harus langsung terbaca.
- **Konsisten lintas platform** — Web Admin dan Mobile App terasa satu keluarga meski berbeda platform.

Referensi estetika: Linear, Vercel Dashboard, Railway — utility-first, tipografi ketat, warna dengan maksud.

---

## Palet Warna

### Brand Colors

```
Navy (Primary)     #0F2D52   ← Background sidebar, header utama, tombol CTA
Navy Light         #1E3A5F   ← Hover state, card accent
Amber (Accent)     #E8A020   ← Highlight penting, badge aktif, ikon navigasi aktif
Amber Light        #FEF3C7   ← Background badge amber (teks gelap)
```

### Neutral Scale

```
Gray 950     #0A0F1A   ← Teks utama (hampir hitam, bukan murni hitam)
Gray 700     #374151   ← Teks sekunder
Gray 500     #6B7280   ← Placeholder, label disabledh
Gray 300     #D1D5DB   ← Border, divider
Gray 100     #F3F4F6   ← Background row tabel, hover state
Gray 50      #F9FAFB   ← Background halaman
White        #FFFFFF   ← Card background
```

### Status Colors (Package Status)

Ini adalah warna paling kritis di sistem — harus konsisten 100% antara web dan mobile.

```
Created              bg: #F3F4F6   text: #374151   border: #D1D5DB
Received at Warehouse bg: #DBEAFE  text: #1E40AF   border: #93C5FD
Assigned to Linehaul  bg: #EDE9FE  text: #5B21B6   border: #A78BFA
Picked Up             bg: #E0E7FF  text: #3730A3   border: #818CF8
In Transit            bg: #FEF3C7  text: #92400E   border: #FCD34D
Arrived at Warehouse  bg: #CCFBF1  text: #065F46   border: #5EEAD4
Assigned to Courier   bg: #FFEDD5  text: #9A3412   border: #FDBA74
Out For Delivery      bg: #FED7AA  text: #7C2D12   border: #FB923C
Delivered             bg: #DCFCE7  text: #14532D   border: #86EFAC
Failed Delivery       bg: #FEE2E2  text: #7F1D1D   border: #FCA5A5
```

### Semantic Colors

```
Success     #16A34A   ← Operasi berhasil
Warning     #D97706   ← Perlu perhatian
Error       #DC2626   ← Aksi gagal / destruktif
Info        #2563EB   ← Informasi netral
```

---

## Tipografi

### Web (React.js)

Font stack: **Inter** (Google Fonts) untuk semua teks.

```css
/* Import */
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap');

/* Scale */
--font-xs:   0.75rem / 1rem        /* 12px — label, caption */
--font-sm:   0.875rem / 1.25rem    /* 14px — body kecil, tabel */
--font-base: 1rem / 1.5rem         /* 16px — body utama */
--font-lg:   1.125rem / 1.75rem    /* 18px — sub-heading */
--font-xl:   1.25rem / 1.75rem     /* 20px — heading section */
--font-2xl:  1.5rem / 2rem         /* 24px — page title */
--font-3xl:  1.875rem / 2.25rem    /* 30px — dashboard stats */

/* Weight */
--weight-normal:    400
--weight-medium:    500
--weight-semibold:  600
--weight-bold:      700
```

Aturan tipografi:
- Page title: `2xl`, `semibold`, warna `Gray 950`
- Section heading: `lg`, `semibold`, warna `Gray 950`
- Body utama: `base`, `normal`, warna `Gray 700`
- Label form & tabel header: `sm`, `medium`, warna `Gray 700`, `uppercase tracking-wide`
- Caption & timestamp: `xs`, `normal`, warna `Gray 500`
- Badge/status: `xs`, `medium`
- Angka statistik besar: `3xl`, `bold`, warna `Gray 950`

### Mobile (Flutter)

```dart
// Font: Inter via google_fonts
// Scale sama, unit dp
TextStyle displayLarge  = Inter(fontSize: 30, fontWeight: w700)  // stats besar
TextStyle headlineMedium = Inter(fontSize: 20, fontWeight: w600) // section heading
TextStyle titleMedium   = Inter(fontSize: 16, fontWeight: w600)  // card title
TextStyle bodyMedium    = Inter(fontSize: 14, fontWeight: w400)  // body
TextStyle bodySmall     = Inter(fontSize: 12, fontWeight: w400)  // caption
TextStyle labelSmall    = Inter(fontSize: 11, fontWeight: w500)  // badge
```

---

## Spacing & Radius

Ikuti kelipatan 4px.

```
2px   → xs    (gap dalam inline element)
4px   → sm    (padding badge, spacing ikon-teks)
8px   → md    (padding kecil, gap antar item list)
12px  → lg    (padding dalam row tabel)
16px  → xl    (padding card dalam, gap antar komponen)
24px  → 2xl   (padding card luar, section gap)
32px  → 3xl   (gap antar section besar)
48px  → 4xl   (padding halaman, hero section)
```

Border radius:
```
4px   → radius-sm   (badge, chip kecil)
6px   → radius-md   (input, tombol, small card)
8px   → radius-lg   (card standar)
12px  → radius-xl   (modal, bottom sheet, large card)
full  → radius-full (avatar, pill badge)
```

---

## Komponen

### Tombol

```
Primary    bg: #0F2D52  text: white      hover: #1E3A5F   — CTA utama
Secondary  bg: white    text: #0F2D52   border: #D1D5DB  hover: #F9FAFB — aksi sekunder
Danger     bg: #DC2626  text: white      hover: #B91C1C   — hapus, destruktif
Ghost      bg: transparent text: #374151 hover: #F3F4F6  — aksi ringan

Height: 36px (sm) / 40px (default) / 44px (lg, mobile)
Padding: 0 16px (default)
Font: sm, medium
Radius: radius-md
```

### Input & Form

```
Border: 1px solid #D1D5DB
Radius: radius-md
Padding: 10px 12px
Font: base, normal
Focus ring: 2px solid #0F2D52 dengan offset 2px
Error state: border #DC2626 + teks error xs di bawah
Placeholder color: Gray 500
```

### Card

```
Background: white
Border: 1px solid #E5E7EB
Radius: radius-lg
Shadow: 0 1px 3px rgba(0,0,0,0.08), 0 1px 2px rgba(0,0,0,0.04)
Padding: 24px (default) / 16px (compact)
```

### Tabel

```
Header: bg #F9FAFB, border-bottom 2px solid #E5E7EB
        font: sm, medium, uppercase, tracking-wide, Gray 700
Row: border-bottom 1px solid #F3F4F6, padding 12px 16px
Row hover: bg #F9FAFB
Zebra stripe: tidak (gunakan border saja)
```

### Badge / Status

```
Padding: 2px 8px
Radius: radius-sm
Font: xs, medium
Border: 1px solid (sesuai warna status)
— Lihat "Status Colors" di atas untuk nilai per status
```

### Sidebar (Web)

```
Width: 240px (expanded) / 64px (collapsed)
Background: #0F2D52 (Navy)
Text aktif: white, bg rgba(255,255,255,0.12), left border 3px solid #E8A020
Text inaktif: rgba(255,255,255,0.65)
Text hover: rgba(255,255,255,0.9), bg rgba(255,255,255,0.06)
Logo area: 64px height, border-bottom 1px solid rgba(255,255,255,0.1)
```

### Bottom Navigation (Mobile)

```
Background: white
Border-top: 1px solid #E5E7EB
Height: 64px + safe area inset
Icon aktif: #E8A020 (Amber)
Label aktif: #0F2D52, xs, semibold
Icon inaktif: #9CA3AF
Label inaktif: #9CA3AF, xs, normal
```

---

## Ikonografi

Gunakan satu library ikon konsisten:

- **Web**: `lucide-react` — stroke icons, 20px default (24px untuk nav), stroke-width 1.5
- **Mobile**: `Icons.*` dari Material Icons Outlined — pastikan pakai varian `_outlined` untuk konsistensi visual

Aturan:
- Ikon navigasi: 24px
- Ikon dalam tombol: 16px, margin-right 6px
- Ikon standalone (dashboard card): 40px container dengan background tinted

---

## Ilustrasi & Empty State

Hindari ilustrasi blob/undraw yang generic. Gunakan:
- Ikon besar dari lucide/material dengan warna tipis
- Teks informatif + tombol aksi
- Contoh: "Belum ada paket di gudang ini. Tambah paket pertama →"

---

## Layout Web Admin

### Shell

```
┌─────────────────────────────────────┐
│  Topbar (64px)                      │
├──────────┬──────────────────────────┤
│ Sidebar  │  Main Content            │
│ (240px)  │  padding: 32px           │
│          │                          │
│          │  ┌──── PageHeader ────┐  │
│          │  │ Title + Action btn │  │
│          │  └────────────────────┘  │
│          │                          │
│          │  ┌──── Content ───────┐  │
│          │  │                    │  │
└──────────┴──────────────────────────┘
```

### Dashboard Grid

```
┌────────────┬────────────┬────────────┬────────────┐
│ StatsCard  │ StatsCard  │ StatsCard  │ StatsCard  │  ← 4 kolom, gap 16px
└────────────┴────────────┴────────────┴────────────┘
┌──────────────────────────┬────────────────────────┐
│ Tabel paket terbaru      │ Breakdown per status   │  ← 2 kolom, 8:4 ratio
└──────────────────────────┴────────────────────────┘
```

### Content Max Width

```
max-width: 1280px
margin: 0 auto
```

---

## Layout Mobile

### Spacing Halaman

```
horizontal padding: 16px
section gap: 24px
card inner padding: 16px
```

### List Item Package Card

```
┌─────────────────────────────────────┐
│ [Resi bold]          [StatusBadge]  │
│ Nama Paket                          │
│ Tujuan: alamat_tujuan (1 baris)     │
│ [berat + layanan]     [Rp ongkos]   │
└─────────────────────────────────────┘
border-radius: 8px
background: white
shadow: ringan
padding: 16px
margin-bottom: 8px
```

---

## Motion & Animasi

Prinsip: purposeful, bukan dekoratif.

```
Durasi standard: 150ms ease-out  (hover, state change kecil)
Durasi medium:   250ms ease-out  (slide-in panel, modal masuk)
Durasi panjang:  350ms ease-out  (page transition, bottom sheet)

Reduced motion: semua animasi dihormati via @media (prefers-reduced-motion)
```

Gunakan animasi untuk:
- Status badge berubah → flash highlight singkat
- Bottom sheet naik
- Toast notification slide-in
- Loading skeleton pulse

Hindari:
- Animasi latar belakang ambient
- Parallax scroll
- Efek berlebihan pada tabel/list

---

## Komponen Platform-Spesifik

### Web: Toast Notification

```
Position: top-right, 16px dari tepi
Width: 320px
Auto-dismiss: 4 detik
Stack: maks 3 toast (yang lama dismiss)
Variants: success (hijau), error (merah), warning (amber), info (biru)
```

### Mobile: Snackbar

```
Position: bawah layar, di atas bottom nav
Duration: 3 detik
Max width: lebar layar - 32px
```

### Web: Loading State Tabel

Gunakan skeleton rows (bukan spinner penuh halaman):
```
3 baris skeleton, animasi pulse, tinggi sama dengan row normal
```

### Mobile: Loading

```
CircularProgressIndicator warna primary (#0F2D52)
Atau Shimmer effect untuk list items
```

---

## Tailwind Config (Web)

```javascript
// tailwind.config.js
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        navy: {
          950: '#0F2D52',
          900: '#1E3A5F',
          800: '#2A4D7A',
        },
        amber: {
          brand: '#E8A020',
          light: '#FEF3C7',
        },
        status: {
          created:      { bg: '#F3F4F6', text: '#374151', border: '#D1D5DB' },
          received:     { bg: '#DBEAFE', text: '#1E40AF', border: '#93C5FD' },
          linehaul:     { bg: '#EDE9FE', text: '#5B21B6', border: '#A78BFA' },
          pickedup:     { bg: '#E0E7FF', text: '#3730A3', border: '#818CF8' },
          transit:      { bg: '#FEF3C7', text: '#92400E', border: '#FCD34D' },
          arrived:      { bg: '#CCFBF1', text: '#065F46', border: '#5EEAD4' },
          courier:      { bg: '#FFEDD5', text: '#9A3412', border: '#FDBA74' },
          outdelivery:  { bg: '#FED7AA', text: '#7C2D12', border: '#FB923C' },
          delivered:    { bg: '#DCFCE7', text: '#14532D', border: '#86EFAC' },
          failed:       { bg: '#FEE2E2', text: '#7F1D1D', border: '#FCA5A5' },
        },
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
      },
      boxShadow: {
        card: '0 1px 3px rgba(0,0,0,0.08), 0 1px 2px rgba(0,0,0,0.04)',
        'card-hover': '0 4px 12px rgba(0,0,0,0.10), 0 2px 4px rgba(0,0,0,0.06)',
      },
      borderRadius: {
        sm: '4px',
        md: '6px',
        lg: '8px',
        xl: '12px',
      },
    },
  },
  plugins: [],
}
```

### Flutter Theme Config

```dart
// lib/core/theme/app_theme.dart
ThemeData get lightTheme => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.light(
    primary: Color(0xFF0F2D52),
    secondary: Color(0xFFE8A020),
    surface: Color(0xFFFFFFFF),
    background: Color(0xFFF9FAFB),
    error: Color(0xFFDC2626),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Color(0xFF0A0F1A),
  ),
  textTheme: GoogleFonts.interTextTheme(),
  cardTheme: CardTheme(
    elevation: 0,
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: BorderSide(color: Color(0xFFE5E7EB)),
    ),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFF0F2D52),
    foregroundColor: Colors.white,
    elevation: 0,
    titleTextStyle: GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: Colors.white,
    indicatorColor: Color(0xFFFEF3C7),
    iconTheme: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return IconThemeData(color: Color(0xFFE8A020));
      }
      return IconThemeData(color: Color(0xFF9CA3AF));
    }),
    labelTextStyle: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return GoogleFonts.inter(
          fontSize: 11, fontWeight: FontWeight.w600,
          color: Color(0xFF0F2D52),
        );
      }
      return GoogleFonts.inter(
        fontSize: 11, fontWeight: FontWeight.w400,
        color: Color(0xFF9CA3AF),
      );
    }),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(color: Color(0xFFD1D5DB)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(color: Color(0xFF0F2D52), width: 2),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    hintStyle: TextStyle(color: Color(0xFF6B7280)),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF0F2D52),
      foregroundColor: Colors.white,
      minimumSize: Size(0, 44),
      padding: EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
    ),
  ),
);
```

---

## AppColors (Flutter)

```dart
// lib/core/theme/app_colors.dart
class AppColors {
  // Brand
  static const primary      = Color(0xFF0F2D52);
  static const primaryLight = Color(0xFF1E3A5F);
  static const accent       = Color(0xFFE8A020);
  static const accentLight  = Color(0xFFFEF3C7);

  // Neutral
  static const textPrimary   = Color(0xFF0A0F1A);
  static const textSecondary = Color(0xFF374151);
  static const textMuted     = Color(0xFF6B7280);
  static const border        = Color(0xFFD1D5DB);
  static const borderLight   = Color(0xFFE5E7EB);
  static const surface       = Color(0xFFFFFFFF);
  static const background    = Color(0xFFF9FAFB);

  // Semantic
  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFD97706);
  static const danger  = Color(0xFFDC2626);
  static const info    = Color(0xFF2563EB);

  // Status badge backgrounds
  static const statusCreatedBg     = Color(0xFFF3F4F6);
  static const statusReceivedBg    = Color(0xFFDBEAFE);
  static const statusLinehaulBg    = Color(0xFFEDE9FE);
  static const statusPickedUpBg    = Color(0xFFE0E7FF);
  static const statusTransitBg     = Color(0xFFFEF3C7);
  static const statusArrivedBg     = Color(0xFFCCFBF1);
  static const statusCourierBg     = Color(0xFFFFEDD5);
  static const statusOutDelivBg    = Color(0xFFFED7AA);
  static const statusDeliveredBg   = Color(0xFFDCFCE7);
  static const statusFailedBg      = Color(0xFFFEE2E2);

  // Status badge text colors (matching pairs)
  static const statusCreatedText    = Color(0xFF374151);
  static const statusReceivedText   = Color(0xFF1E40AF);
  static const statusLinehaulText   = Color(0xFF5B21B6);
  static const statusPickedUpText   = Color(0xFF3730A3);
  static const statusTransitText    = Color(0xFF92400E);
  static const statusArrivedText    = Color(0xFF065F46);
  static const statusCourierText    = Color(0xFF9A3412);
  static const statusOutDelivText   = Color(0xFF7C2D12);
  static const statusDeliveredText  = Color(0xFF14532D);
  static const statusFailedText     = Color(0xFF7F1D1D);
}
```

---

## CSS Variables (Web — global)

```css
/* src/index.css */
:root {
  --color-primary:       #0F2D52;
  --color-primary-light: #1E3A5F;
  --color-accent:        #E8A020;
  --color-accent-light:  #FEF3C7;

  --color-text-primary:   #0A0F1A;
  --color-text-secondary: #374151;
  --color-text-muted:     #6B7280;
  --color-border:         #D1D5DB;
  --color-border-light:   #E5E7EB;
  --color-surface:        #FFFFFF;
  --color-background:     #F9FAFB;

  --color-success: #16A34A;
  --color-warning: #D97706;
  --color-error:   #DC2626;
  --color-info:    #2563EB;

  --radius-sm:   4px;
  --radius-md:   6px;
  --radius-lg:   8px;
  --radius-xl:   12px;
  --radius-full: 9999px;

  --shadow-card:       0 1px 3px rgba(0,0,0,0.08), 0 1px 2px rgba(0,0,0,0.04);
  --shadow-card-hover: 0 4px 12px rgba(0,0,0,0.10), 0 2px 4px rgba(0,0,0,0.06);
  --shadow-modal:      0 20px 60px rgba(0,0,0,0.15);

  --font-sans: 'Inter', system-ui, sans-serif;

  --sidebar-width: 240px;
  --topbar-height: 64px;
}
```

---

## Do & Don't

### Do
- Gunakan padding dan margin dari skala spacing (kelipatan 4px)
- Badge status selalu pakai warna yang sudah ditentukan — jangan improvisasi
- Tabel selalu punya header yang jelas dengan font uppercase kecil
- Tombol destruktif selalu merah, tombol utama selalu navy
- Form error selalu di bawah field, bukan di atas form
- Empty state selalu ada tombol CTA yang relevan

### Don't
- Jangan campur gaya ikon (outlined vs filled dalam satu halaman)
- Jangan gunakan warna di luar palet kecuali untuk status yang sudah didefinisikan
- Jangan animasikan elemen yang tidak perlu (loading spinner cukup, tidak perlu bounce)
- Jangan gunakan shadow besar pada elemen kecil
- Jangan gunakan font weight < 400 atau > 700
- Jangan ubah warna status paket — konsistensi visual di sini sangat penting untuk operasional

---

## API Third-Party yang Digunakan

| Kegunaan | Provider | Free Tier | Docs |
|---|---|---|---|
| LLM / AI Chat | Google Gemini API | ✅ Ya (Gemini Flash) | ai.google.dev |
| Geocoding (alamat → koordinat) | OpenStreetMap Nominatim | ✅ Ya (rate limit 1 req/s) | nominatim.org |
| Peta tile | OpenStreetMap / Leaflet (web) + flutter_map (mobile) | ✅ Ya | openstreetmap.org |
| Cuaca | Open-Meteo | ✅ Ya (no key needed) | open-meteo.com |
| Kurs mata uang | ExchangeRate-API | ✅ Ya (1500 req/bulan) | exchangerate-api.com |

### Catatan Open-Meteo (Cuaca)

Open-Meteo tidak membutuhkan API key. Endpoint:

```
GET https://api.open-meteo.com/v1/forecast
  ?latitude={lat}
  &longitude={lng}
  &current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m
  &timezone=Asia%2FJakarta
```

Field `weather_code` mengikuti standar WMO — map ke deskripsi lokal sendiri.

Update `WeatherService` di Flutter dan web untuk pakai URL ini (tanpa API key).

---

## Changelog Keputusan Desain

| Tanggal | Keputusan |
|---|---|
| 2026 | SUPER_ADMIN **bisa** hapus paket |
| 2026 | Dashboard SUPER_ADMIN **tidak** ada grafik tren harian — fokus pada angka agregat |
| 2026 | PackageDetail mobile: saat `Out For Delivery` tampil 3 tombol: [Peta], [Selesai], [Gagal Antar] |
| 2026 | Status `Created` di-set otomatis saat paket dibuat — bukan via PATCH endpoint |
| 2026 | Fitur ETA paket dihilangkan dari scope |
| 2026 | Cuaca menggunakan Open-Meteo (tanpa API key) |
| 2026 | Platform web: React.js (bukan Flutter Web) |
