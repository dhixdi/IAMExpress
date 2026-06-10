import { BrowserRouter, Routes, Route, Navigate, Outlet } from 'react-router-dom';
import { useAuthStore } from './store/authStore';
import { ROUTES } from './constants/routes';

import AppLayout from './components/layout/AppLayout';
import LoginPage from './pages/auth/LoginPage';
import DashboardPage from './pages/dashboard/DashboardPage';
import UserListPage from './pages/users/UserListPage';
import UserFormPage from './pages/users/UserFormPage';
import UserDetailPage from './pages/users/UserDetailPage';
import WarehouseListPage from './pages/warehouses/WarehouseListPage';
import WarehouseFormPage from './pages/warehouses/WarehouseFormPage';
import WarehouseDetailPage from './pages/warehouses/WarehouseDetailPage';
import PackageListPage from './pages/packages/PackageListPage';
import PackageFormPage from './pages/packages/PackageFormPage';
import PackageDetailPage from './pages/packages/PackageDetailPage';
import PackageAssignPage from './pages/packages/PackageAssignPage';
import PackageTrackerPage from './pages/packages/PackageTrackerPage';
import ProfilePage from './pages/profile/ProfilePage';
import { ROLES } from './constants/roles';

function PrivateRoute() {
  const { isAuthenticated } = useAuthStore();
  if (!isAuthenticated) return <Navigate to={ROUTES.LOGIN} replace />;
  return <Outlet />;
}

function RoleRoute({ roles }) {
  const { user } = useAuthStore();
  if (!roles.includes(user?.role)) {
    return <Navigate to={ROUTES.DASHBOARD} replace />;
  }
  return <Outlet />;
}

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path={ROUTES.LOGIN} element={<LoginPage />} />

        <Route element={<PrivateRoute />}>
          <Route element={<AppLayout />}>
            <Route path={ROUTES.DASHBOARD} element={<DashboardPage />} />
            <Route path={ROUTES.PROFILE} element={<ProfilePage />} />

            {/* SUPER_ADMIN Only */}
            <Route element={<RoleRoute roles={[ROLES.SUPER_ADMIN]} />}>
              <Route path={ROUTES.USERS} element={<UserListPage />} />
              <Route path={`${ROUTES.USERS}/new`} element={<UserFormPage />} />
              <Route path={`${ROUTES.USERS}/:id`} element={<UserDetailPage />} />
              <Route path={`${ROUTES.USERS}/:id/edit`} element={<UserFormPage />} />

              <Route path={ROUTES.WAREHOUSES} element={<WarehouseListPage />} />
              <Route path={`${ROUTES.WAREHOUSES}/new`} element={<WarehouseFormPage />} />
              <Route path={`${ROUTES.WAREHOUSES}/:id`} element={<WarehouseDetailPage />} />
              <Route path={`${ROUTES.WAREHOUSES}/:id/edit`} element={<WarehouseFormPage />} />
            </Route>

            {/* SUPER_ADMIN + WAREHOUSE_ADMIN */}
            <Route element={<RoleRoute roles={[ROLES.SUPER_ADMIN, ROLES.WAREHOUSE_ADMIN]} />}>
              <Route path={ROUTES.PACKAGES} element={<PackageListPage />} />
              <Route path={`${ROUTES.PACKAGES}/new`} element={<PackageFormPage />} />
              <Route path={`${ROUTES.PACKAGES}/:id`} element={<PackageDetailPage />} />
              <Route path={`${ROUTES.PACKAGES}/:id/edit`} element={<PackageFormPage />} />
              <Route path={`${ROUTES.PACKAGES}/:id/assign`} element={<PackageAssignPage />} />
              <Route path={`${ROUTES.PACKAGES}/:id/tracker`} element={<PackageTrackerPage />} />
            </Route>
          </Route>
        </Route>

        <Route path="*" element={<Navigate to={ROUTES.DASHBOARD} replace />} />
      </Routes>
    </BrowserRouter>
  );
}
