# API Integration — IAMExpress Web Admin

Dokumen ini menjelaskan cara frontend berkomunikasi dengan backend API.

## Setup Axios

Instance Axios terpusat ada di `src/services/api.js`. Semua service file mengimport dari sini.

```javascript
// src/services/api.js
import axios from 'axios';
import { useAuthStore } from '../store/authStore';

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL,  // e.g. http://localhost:3000/api/v1
  headers: { 'Content-Type': 'application/json' },
});

// Inject JWT token ke setiap request
api.interceptors.request.use((config) => {
  const token = useAuthStore.getState().token;
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

// Auto logout jika token expired (401)
api.interceptors.response.use(
  (res) => res,
  (err) => {
    if (err.response?.status === 401) {
      useAuthStore.getState().logout();
      window.location.href = '/login';
    }
    return Promise.reject(err);
  }
);

export default api;
```

---

## Auth Service

```javascript
// src/services/authService.js
import api from './api';

const authService = {
  login: async (email, password) => {
    const res = await api.post('/auth/login', { email, password });
    return res.data.data;   // { token, user }
  },

  me: async () => {
    const res = await api.get('/auth/me');
    return res.data.data;
  },

  logout: async () => {
    await api.post('/auth/logout');
  },
};

export default authService;
```

**Pemakaian di LoginPage:**

```jsx
const handleSubmit = async (e) => {
  e.preventDefault();
  try {
    const { token, user } = await authService.login(email, password);
    authStore.setAuth(token, user);
    navigate('/');
  } catch (err) {
    setError(err.response?.data?.message || 'Login gagal');
  }
};
```

---

## User Service

```javascript
// src/services/userService.js
import api from './api';

const userService = {
  getAll: async (params = {}) => {
    const res = await api.get('/users', { params });
    return res.data;   // { data: { users }, meta }
  },

  getById: async (id) => {
    const res = await api.get(`/users/${id}`);
    return res.data.data;
  },

  create: async (payload) => {
    const res = await api.post('/users', payload);
    return res.data.data;
  },

  update: async (id, payload) => {
    const res = await api.put(`/users/${id}`, payload);
    return res.data.data;
  },

  delete: async (id) => {
    await api.delete(`/users/${id}`);
  },

  updateRole: async (id, role) => {
    const res = await api.patch(`/users/${id}/role`, { role });
    return res.data.data;
  },

  updateMyPhoto: async (photo_url) => {
    const res = await api.patch('/users/me/photo', { photo_url });
    return res.data.data;
  },

  updateMyPassword: async (old_password, new_password) => {
    const res = await api.patch('/users/me/password', { old_password, new_password });
    return res.data.data;
  },
};

export default userService;
```

---

## Warehouse Service

```javascript
// src/services/warehouseService.js
import api from './api';

const warehouseService = {
  getAll: async (params = {}) => {
    const res = await api.get('/warehouses', { params });
    return res.data;
  },

  getById: async (id) => {
    const res = await api.get(`/warehouses/${id}`);
    return res.data.data;
  },

  create: async (payload) => {
    // payload: { nama_gudang, alamat }
    // lat/lng digenerate otomatis oleh backend
    const res = await api.post('/warehouses', payload);
    return res.data.data;
  },

  update: async (id, payload) => {
    const res = await api.put(`/warehouses/${id}`, payload);
    return res.data.data;
  },

  delete: async (id) => {
    await api.delete(`/warehouses/${id}`);
  },
};

export default warehouseService;
```

---

## Package Service

```javascript
// src/services/packageService.js
import api from './api';

const packageService = {
  getAll: async (params = {}) => {
    // params: page, per_page, q, current_status, jenis_layanan, sort_by, order
    const res = await api.get('/packages', { params });
    return res.data;   // { data: { packages }, meta }
  },

  getById: async (id) => {
    const res = await api.get(`/packages/${id}`);
    return res.data.data;
  },

  trackByResi: async (resi) => {
    const res = await api.get(`/packages/track/${resi}`);
    return res.data.data;
  },

  create: async (payload) => {
    // payload: nama_paket, alamat_pengirim, alamat_tujuan, no_hp_*, berat, jenis_layanan
    // resi, ongkos_kirim, koordinat digenerate otomatis backend
    const res = await api.post('/packages', payload);
    return res.data.data;
  },

  update: async (id, payload) => {
    const res = await api.put(`/packages/${id}`, payload);
    return res.data.data;
  },

  delete: async (id) => {
    await api.delete(`/packages/${id}`);
  },

  updateStatus: async (id, status, notes = '') => {
    const res = await api.patch(`/packages/${id}/status`, { status, notes });
    return res.data.data;
  },

  assign: async (id, user_id, type) => {
    // type: 'linehaul' atau 'courier'
    const res = await api.patch(`/packages/${id}/assign`, { user_id, type });
    return res.data.data;
  },

  getTracker: async (id, params = {}) => {
    const res = await api.get(`/packages/${id}/tracker`, { params });
    return res.data;
  },
};

export default packageService;
```

---

## Dashboard Service

```javascript
// src/services/dashboardService.js
import api from './api';

const dashboardService = {
  get: async () => {
    // Response berbeda per role — backend handle otomatis dari JWT
    const res = await api.get('/dashboard');
    return res.data.data;
  },
};

export default dashboardService;
```

---

## Custom Hooks (TanStack Query)

Semua data fetching dibungkus dalam custom hook agar bisa dipakai di banyak component.

```javascript
// src/hooks/usePackages.js
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import packageService from '../services/packageService';

// Ambil list paket dengan filter
export const usePackages = (params) => {
  return useQuery({
    queryKey: ['packages', params],
    queryFn: () => packageService.getAll(params),
    keepPreviousData: true,    // halaman tidak flash saat ganti page
  });
};

// Ambil detail paket
export const usePackage = (id) => {
  return useQuery({
    queryKey: ['package', id],
    queryFn: () => packageService.getById(id),
    enabled: !!id,
  });
};

// Ambil tracker paket
export const usePackageTracker = (id) => {
  return useQuery({
    queryKey: ['tracker', id],
    queryFn: () => packageService.getTracker(id, { sort_by: 'timestamp', order: 'asc' }),
    enabled: !!id,
  });
};

// Mutation: buat paket
export const useCreatePackage = () => {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (payload) => packageService.create(payload),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['packages'] }),
  });
};

// Mutation: update status
export const useUpdatePackageStatus = () => {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, status, notes }) => packageService.updateStatus(id, status, notes),
    onSuccess: (_, { id }) => {
      qc.invalidateQueries({ queryKey: ['packages'] });
      qc.invalidateQueries({ queryKey: ['package', id] });
      qc.invalidateQueries({ queryKey: ['tracker', id] });
    },
  });
};

// Mutation: assign linehaul / courier
export const useAssignPackage = () => {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, user_id, type }) => packageService.assign(id, user_id, type),
    onSuccess: (_, { id }) => {
      qc.invalidateQueries({ queryKey: ['packages'] });
      qc.invalidateQueries({ queryKey: ['package', id] });
    },
  });
};
```

```javascript
// src/hooks/useWarehouses.js
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import warehouseService from '../services/warehouseService';

export const useWarehouses = (params) => {
  return useQuery({
    queryKey: ['warehouses', params],
    queryFn: () => warehouseService.getAll(params),
  });
};

export const useCreateWarehouse = () => {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (payload) => warehouseService.create(payload),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['warehouses'] }),
  });
};
```

---

## Pemakaian di Component

```jsx
// PackageListPage.jsx — contoh penggunaan hook
import { useState } from 'react';
import { usePackages } from '../../hooks/usePackages';
import DataTable from '../../components/common/DataTable';
import StatusBadge from '../../components/common/StatusBadge';

export default function PackageListPage() {
  const [page, setPage] = useState(1);
  const [statusFilter, setStatusFilter] = useState('');
  const [search, setSearch] = useState('');

  const { data, isLoading, isError } = usePackages({
    page,
    per_page: 10,
    current_status: statusFilter || undefined,
    q: search || undefined,
  });

  if (isLoading) return <div>Loading...</div>;
  if (isError)   return <div>Gagal memuat data</div>;

  const { packages } = data.data;
  const { total_pages } = data.meta;

  return (
    <div>
      {/* Filter & Search */}
      <input
        value={search}
        onChange={(e) => { setSearch(e.target.value); setPage(1); }}
        placeholder="Cari resi atau nama paket..."
      />

      {/* Tabel */}
      <DataTable
        data={packages}
        columns={[
          { header: 'Resi', accessor: 'resi' },
          { header: 'Nama Paket', accessor: 'nama_paket' },
          { header: 'Status', render: (row) => <StatusBadge status={row.current_status} /> },
          { header: 'Layanan', accessor: 'jenis_layanan' },
        ]}
      />

      {/* Pagination */}
      <div>
        <button disabled={page === 1} onClick={() => setPage(p => p - 1)}>Prev</button>
        <span>{page} / {total_pages}</span>
        <button disabled={page === total_pages} onClick={() => setPage(p => p + 1)}>Next</button>
      </div>
    </div>
  );
}
```

---

## Error Handling

Semua error dari API mengikuti format:

```json
{
  "success": false,
  "message": "Pesan error",
  "errors": [{ "field": "email", "message": "Email sudah digunakan" }]
}
```

Cara handle di component:

```jsx
const { mutate: createPackage } = useCreatePackage();

const handleSubmit = (formData) => {
  createPackage(formData, {
    onSuccess: () => {
      toast.success('Paket berhasil dibuat');
      navigate('/packages');
    },
    onError: (err) => {
      const msg = err.response?.data?.message || 'Terjadi kesalahan';
      toast.error(msg);
    },
  });
};
```

---

## Endpoint Summary

| Service | Method | Endpoint |
|---|---|---|
| `authService.login` | POST | `/auth/login` |
| `authService.me` | GET | `/auth/me` |
| `authService.logout` | POST | `/auth/logout` |
| `userService.getAll` | GET | `/users` |
| `userService.create` | POST | `/users` |
| `userService.update` | PUT | `/users/:id` |
| `userService.delete` | DELETE | `/users/:id` |
| `userService.updateRole` | PATCH | `/users/:id/role` |
| `warehouseService.getAll` | GET | `/warehouses` |
| `warehouseService.create` | POST | `/warehouses` |
| `warehouseService.update` | PUT | `/warehouses/:id` |
| `warehouseService.delete` | DELETE | `/warehouses/:id` |
| `packageService.getAll` | GET | `/packages` |
| `packageService.getById` | GET | `/packages/:id` |
| `packageService.trackByResi` | GET | `/packages/track/:resi` |
| `packageService.create` | POST | `/packages` |
| `packageService.update` | PUT | `/packages/:id` |
| `packageService.delete` | DELETE | `/packages/:id` |
| `packageService.updateStatus` | PATCH | `/packages/:id/status` |
| `packageService.assign` | PATCH | `/packages/:id/assign` |
| `packageService.getTracker` | GET | `/packages/:id/tracker` |
| `dashboardService.get` | GET | `/dashboard` |
