# Architecture — IAMExpress Web Admin

## Struktur Folder

```
frontend/
├── public/
│   └── favicon.ico
├── src/
│   ├── main.jsx                    ← Entry point React
│   ├── App.jsx                     ← Root component, routing setup
│   │
│   ├── pages/                      ← Halaman utama per fitur
│   │   ├── auth/
│   │   │   └── LoginPage.jsx
│   │   ├── dashboard/
│   │   │   └── DashboardPage.jsx   ← Tampilan beda per role
│   │   ├── users/
│   │   │   ├── UserListPage.jsx
│   │   │   ├── UserDetailPage.jsx
│   │   │   └── UserFormPage.jsx    ← Create & Edit user
│   │   ├── warehouses/
│   │   │   ├── WarehouseListPage.jsx
│   │   │   ├── WarehouseDetailPage.jsx
│   │   │   └── WarehouseFormPage.jsx
│   │   ├── packages/
│   │   │   ├── PackageListPage.jsx
│   │   │   ├── PackageDetailPage.jsx
│   │   │   ├── PackageFormPage.jsx
│   │   │   ├── PackageAssignPage.jsx
│   │   │   └── PackageTrackerPage.jsx
│   │   └── profile/
│   │       └── ProfilePage.jsx
│   │
│   ├── components/                 ← Reusable UI components
│   │   ├── layout/
│   │   │   ├── Sidebar.jsx
│   │   │   ├── Topbar.jsx
│   │   │   └── AppLayout.jsx       ← Wrapper sidebar + topbar + outlet
│   │   ├── common/
│   │   │   ├── DataTable.jsx       ← Generic table dengan pagination
│   │   │   ├── StatusBadge.jsx     ← Badge warna per status paket
│   │   │   ├── ConfirmDialog.jsx   ← Modal konfirmasi delete
│   │   │   ├── PageHeader.jsx      ← Judul halaman + breadcrumb
│   │   │   └── EmptyState.jsx
│   │   ├── dashboard/
│   │   │   ├── StatsCard.jsx
│   │   │   └── PackageStatusChart.jsx
│   │   ├── packages/
│   │   │   ├── PackageCard.jsx
│   │   │   ├── PackageStatusTimeline.jsx
│   │   │   └── AssignModal.jsx
│   │   └── maps/
│   │       ├── WarehouseMap.jsx    ← Peta lokasi semua gudang
│   │       └── PackageMap.jsx      ← Peta tujuan paket
│   │
│   ├── store/                      ← Zustand stores
│   │   ├── authStore.js            ← Token, user data, login/logout
│   │   └── uiStore.js              ← Sidebar state, toast, loading global
│   │
│   ├── services/                   ← Axios API calls per resource
│   │   ├── api.js                  ← Axios instance + interceptors
│   │   ├── authService.js
│   │   ├── userService.js
│   │   ├── warehouseService.js
│   │   ├── packageService.js
│   │   └── dashboardService.js
│   │
│   ├── hooks/                      ← Custom hooks (TanStack Query wrappers)
│   │   ├── useAuth.js
│   │   ├── useUsers.js
│   │   ├── useWarehouses.js
│   │   ├── usePackages.js
│   │   └── useDashboard.js
│   │
│   ├── utils/
│   │   ├── formatCurrency.js       ← Format Rp ongkos kirim
│   │   ├── formatDate.js           ← Format timestamp Indonesia
│   │   └── statusColor.js          ← Mapping status → warna badge
│   │
│   └── constants/
│       ├── roles.js                ← Konstanta role
│       ├── packageStatus.js        ← Daftar status paket
│       └── routes.js               ← Path route
│
├── .env.example
├── .env                            ← Jangan di-commit
├── tailwind.config.js
├── vite.config.js
└── package.json
```

---

## Routing Structure

```jsx
// App.jsx
<Routes>
  {/* Public */}
  <Route path="/login" element={<LoginPage />} />

  {/* Protected — semua role yang sudah login */}
  <Route element={<PrivateRoute />}>
    <Route element={<AppLayout />}>
      <Route path="/"           element={<DashboardPage />} />
      <Route path="/profile"    element={<ProfilePage />} />

      {/* Hanya SUPER_ADMIN */}
      <Route element={<RoleRoute roles={['SUPER_ADMIN']} />}>
        <Route path="/users"          element={<UserListPage />} />
        <Route path="/users/new"      element={<UserFormPage />} />
        <Route path="/users/:id"      element={<UserDetailPage />} />
        <Route path="/users/:id/edit" element={<UserFormPage />} />
        <Route path="/warehouses"          element={<WarehouseListPage />} />
        <Route path="/warehouses/new"      element={<WarehouseFormPage />} />
        <Route path="/warehouses/:id"      element={<WarehouseDetailPage />} />
        <Route path="/warehouses/:id/edit" element={<WarehouseFormPage />} />
      </Route>

      {/* SUPER_ADMIN + WAREHOUSE_ADMIN */}
      <Route element={<RoleRoute roles={['SUPER_ADMIN','WAREHOUSE_ADMIN']} />}>
        <Route path="/packages"              element={<PackageListPage />} />
        <Route path="/packages/new"          element={<PackageFormPage />} />
        <Route path="/packages/:id"          element={<PackageDetailPage />} />
        <Route path="/packages/:id/edit"     element={<PackageFormPage />} />
        <Route path="/packages/:id/assign"   element={<PackageAssignPage />} />
        <Route path="/packages/:id/tracker"  element={<PackageTrackerPage />} />
      </Route>
    </Route>
  </Route>

  {/* Fallback */}
  <Route path="*" element={<Navigate to="/" />} />
</Routes>
```

**`PrivateRoute`** — cek apakah ada token di `authStore`. Jika tidak, redirect ke `/login`.

**`RoleRoute`** — cek apakah role user ada di array `roles`. Jika tidak, redirect ke `/` dengan toast error.

---

## Flow Aplikasi

### Login Flow

```
LoginPage
  ↓ submit form
  authService.login(email, password)
  ↓ POST /auth/login
  ← { token, user }
  ↓
  authStore.setAuth(token, user)       ← simpan di Zustand + localStorage
  ↓
  navigate('/')                        ← redirect ke dashboard
  ↓
DashboardPage
  ↓ mount
  dashboardService.getDashboard()
  ↓ GET /dashboard (dengan token)
  ← data sesuai role
  ↓
  Render StatsCard, Chart, dst
```

### Fetch Data Flow (TanStack Query)

```
PackageListPage mount
  ↓
  usePackages({ page: 1, status: filter })  ← custom hook
  ↓
  useQuery({ queryKey: ['packages', params], queryFn: packageService.getAll })
  ↓
  packageService.getAll(params)
  ↓ GET /packages?page=1&current_status=...
  ← { data: { packages: [...] }, meta: {...} }
  ↓
  DataTable render dengan data + pagination
```

### Axios Interceptor

Semua request secara otomatis menyertakan token JWT:

```javascript
// src/services/api.js
import axios from 'axios';
import { useAuthStore } from '../store/authStore';

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL,
});

// Request interceptor — inject token
api.interceptors.request.use((config) => {
  const token = useAuthStore.getState().token;
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Response interceptor — handle 401 (token expired)
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      useAuthStore.getState().logout();
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export default api;
```

---

## State Management

### authStore (Zustand)

```javascript
// src/store/authStore.js
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

export const useAuthStore = create(
  persist(
    (set) => ({
      token: null,
      user: null,
      isAuthenticated: false,

      setAuth: (token, user) => set({ token, user, isAuthenticated: true }),

      logout: () => {
        set({ token: null, user: null, isAuthenticated: false });
        localStorage.removeItem('auth-storage');
      },
    }),
    { name: 'auth-storage' }
  )
);
```

State `token` dan `user` persist ke `localStorage` sehingga tidak hilang saat refresh.

### uiStore (Zustand)

```javascript
// src/store/uiStore.js — untuk sidebar collapse & toast
export const useUIStore = create((set) => ({
  sidebarOpen: true,
  toggleSidebar: () => set((s) => ({ sidebarOpen: !s.sidebarOpen })),
}));
```

---

## Konvensi Kode

- Semua file component menggunakan `.jsx`
- Nama file menggunakan `PascalCase` untuk component, `camelCase` untuk utility
- Custom hook selalu diawali `use` (e.g. `usePackages`, `useWarehouses`)
- Service function mengembalikan data langsung (bukan response Axios mentah): `return response.data.data`
- Error handling di-throw dari service, ditangkap di component atau TanStack Query `onError`
- Hindari logika bisnis di component — taruh di service atau hook
