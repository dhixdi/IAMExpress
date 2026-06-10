# Setup Guide — IAMExpress Web Admin

## Prasyarat

| Tool | Versi Minimum | Cek |
|---|---|---|
| Node.js | 18.x LTS | `node --version` |
| npm | 9.x | `npm --version` |
| Git | Terbaru | `git --version` |

Backend IAMExpress harus sudah berjalan sebelum menjalankan frontend.

---

## 1. Install Dependencies

```bash
npm install
```

Dependencies utama yang akan terinstall:

```
react                   ← UI framework
react-dom               ← DOM rendering
react-router-dom        ← Client-side routing
axios                   ← HTTP client
zustand                 ← Lightweight state management
@tanstack/react-query   ← Server state & caching
recharts                ← Chart library
leaflet                 ← Peta interaktif
react-leaflet           ← React binding untuk Leaflet
tailwindcss             ← CSS utility
shadcn/ui (Radix UI)    ← Component library
lucide-react            ← Icon set
```

---

## 2. Konfigurasi Environment

Salin `.env.example` ke `.env`:

```bash
cp .env.example .env
```

Isi file `.env`:

```env
# URL backend API (wajib diisi)
VITE_API_URL=http://localhost:3000/api/v1

# Nama aplikasi (opsional, tampil di tab browser)
VITE_APP_NAME=IAMExpress Admin

# Mode geocoding untuk peta (leaflet pakai OpenStreetMap secara default)
VITE_MAP_TILE_URL=https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png
```

> **Aturan Vite:** Environment variable yang dipakai di frontend **wajib diawali** `VITE_`. Variable tanpa prefix ini tidak akan terbaca di browser.

File `.env.example`:

```env
VITE_API_URL=
VITE_APP_NAME=IAMExpress Admin
VITE_MAP_TILE_URL=https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png
```

> **Jangan commit `.env` ke Git.** Pastikan `.env` ada di `.gitignore`.

---

## 3. Setup Tailwind CSS

Tailwind sudah terkonfigurasi via `tailwind.config.js`. Tidak perlu setup manual. Pastikan file ini ada di root project:

```javascript
// tailwind.config.js
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        primary: '#1E3A5F',    // Navy biru — warna utama IAMExpress
        accent:  '#F59E0B',    // Amber — aksen
      }
    }
  },
  plugins: [],
}
```

---

## 4. Setup shadcn/ui (opsional, jika belum ada)

Jika shadcn/ui belum tersedia di project:

```bash
npx shadcn-ui@latest init
```

Pilih:
- Style: Default
- Base color: Slate
- CSS variables: Yes

Install component yang dibutuhkan satu per satu:

```bash
npx shadcn-ui@latest add button
npx shadcn-ui@latest add card
npx shadcn-ui@latest add table
npx shadcn-ui@latest add dialog
npx shadcn-ui@latest add input
npx shadcn-ui@latest add select
npx shadcn-ui@latest add badge
npx shadcn-ui@latest add toast
npx shadcn-ui@latest add dropdown-menu
```

---

## 5. Menjalankan Development Server

```bash
npm run dev
```

Aplikasi berjalan di `http://localhost:5173`

Hot reload aktif otomatis saat file berubah.

---

## 6. Script yang Tersedia

| Script | Perintah | Keterangan |
|---|---|---|
| Dev server | `npm run dev` | Development dengan HMR |
| Build | `npm run build` | Build production ke folder `dist/` |
| Preview | `npm run preview` | Preview hasil build secara lokal |
| Lint | `npm run lint` | Cek kode dengan ESLint |

---

## 7. Verifikasi Setup

Setelah `npm run dev` berhasil:

1. Buka `http://localhost:5173` → tampil halaman login
2. Login dengan `superadmin@iamexpress.id` / `admin123`
3. Dashboard Super Admin harus tampil dengan data dari backend
4. Cek Network tab di DevTools — request ke `http://localhost:3000/api/v1` harus sukses (bukan CORS error)

Jika ada CORS error, tambahkan `http://localhost:5173` ke `ALLOWED_ORIGINS` di `.env` backend.

---

## 8. Troubleshooting Setup

**Error: `VITE_API_URL is undefined`**
→ Pastikan nama variable diawali `VITE_`. Restart dev server setelah ubah `.env`.

**CORS error di browser**
→ Backend belum mengizinkan origin frontend. Tambah `http://localhost:5173` ke `ALLOWED_ORIGINS` di backend `.env`.

**Peta tidak muncul (blank)**
→ Pastikan import CSS Leaflet ada di `main.jsx`: `import 'leaflet/dist/leaflet.css'`

**Login berhasil tapi redirect ke login lagi**
→ Token tidak tersimpan. Cek `authStore` di Zustand apakah `localStorage.setItem('token', ...)` dipanggil dengan benar.

**shadcn component tidak ketemu**
→ Jalankan `npx shadcn-ui@latest add <nama-component>` untuk component yang belum diinstall.
