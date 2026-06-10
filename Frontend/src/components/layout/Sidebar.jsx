import { NavLink } from 'react-router-dom';
import { useAuthStore } from '../../store/authStore';
import { useUIStore } from '../../store/uiStore';
import { LayoutDashboard, Users, Warehouse, Package, UserCircle, Truck } from 'lucide-react';
import { ROLES } from '../../constants/roles';

export default function Sidebar() {
  const { user } = useAuthStore();
  const { sidebarOpen } = useUIStore();

  const navItems = [
    { label: 'Dashboard', path: '/', icon: <LayoutDashboard size={20} />, roles: [ROLES.SUPER_ADMIN, ROLES.WAREHOUSE_ADMIN] },
    { label: 'Users', path: '/users', icon: <Users size={20} />, roles: [ROLES.SUPER_ADMIN] },
    { label: 'Warehouses', path: '/warehouses', icon: <Warehouse size={20} />, roles: [ROLES.SUPER_ADMIN] },
    { label: 'Packages', path: '/packages', icon: <Package size={20} />, roles: [ROLES.SUPER_ADMIN, ROLES.WAREHOUSE_ADMIN] },
    { label: 'Profile', path: '/profile', icon: <UserCircle size={20} />, roles: [ROLES.SUPER_ADMIN, ROLES.WAREHOUSE_ADMIN] },
  ];

  const filteredNav = navItems.filter(item => item.roles.includes(user?.role));

  if (!sidebarOpen) {
    return (
      <aside className="w-16 bg-navy-950 min-h-screen text-white flex flex-col items-center py-4 border-r border-navy-900 transition-all">
        <div className="h-16 flex items-center justify-center border-b border-white/10 w-full mb-4">
          <Truck className="text-amber-brand" size={28} />
        </div>
        <nav className="flex-1 w-full px-2 space-y-2">
          {filteredNav.map((item) => (
            <NavLink
              key={item.path}
              to={item.path}
              className={({ isActive }) =>
                `flex justify-center p-3 rounded-md transition-colors ${
                  isActive ? 'bg-white/10 text-white' : 'text-white/60 hover:text-white/90 hover:bg-white/5'
                }`
              }
              title={item.label}
            >
              {item.icon}
            </NavLink>
          ))}
        </nav>
      </aside>
    );
  }

  return (
    <aside className="w-60 bg-navy-950 min-h-screen text-white flex flex-col border-r border-navy-900 transition-all flex-shrink-0">
      <div className="h-[64px] flex items-center px-6 border-b border-white/10">
        <Truck className="text-amber-brand mr-3" size={28} />
        <span className="text-xl font-bold tracking-tight">IAMExpress</span>
      </div>
      <nav className="flex-1 px-4 py-6 space-y-1 overflow-y-auto">
        {filteredNav.map((item) => (
          <NavLink
            key={item.path}
            to={item.path}
            className={({ isActive }) =>
              `flex items-center gap-3 px-3 py-2.5 rounded-md transition-colors text-sm font-medium ${
                isActive
                  ? 'bg-white/10 text-white border-l-4 border-amber-brand -ml-[4px] pl-[15px]'
                  : 'text-white/65 hover:text-white/90 hover:bg-white/5 border-l-4 border-transparent -ml-[4px] pl-[15px]'
              }`
            }
          >
            {item.icon}
            {item.label}
          </NavLink>
        ))}
      </nav>
    </aside>
  );
}
