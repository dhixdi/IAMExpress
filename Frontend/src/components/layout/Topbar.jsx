import { useAuthStore } from '../../store/authStore';
import { useUIStore } from '../../store/uiStore';
import { Menu, LogOut, User } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import authService from '../../services/authService';

export default function Topbar() {
  const { user, logout } = useAuthStore();
  const { toggleSidebar } = useUIStore();
  const navigate = useNavigate();

  const handleLogout = async () => {
    try {
      await authService.logout();
    } catch (e) {
      // ignore
    } finally {
      logout();
      navigate('/login');
    }
  };

  return (
    <header className="h-[64px] bg-white border-b border-gray-200 flex items-center justify-between px-6 shrink-0">
      <div className="flex items-center">
        <button
          onClick={toggleSidebar}
          className="text-gray-500 hover:text-gray-700 focus:outline-none p-1 rounded-md hover:bg-gray-100 mr-4"
        >
          <Menu size={24} />
        </button>
      </div>

      <div className="flex items-center gap-4">
        <div className="hidden sm:block text-right">
          <p className="text-sm font-semibold text-gray-900 leading-tight">{user?.nama || 'User'}</p>
          <p className="text-xs text-gray-500 leading-tight">{user?.role}</p>
        </div>
        <div className="h-10 w-10 rounded-full bg-navy-950 text-white flex items-center justify-center overflow-hidden border border-gray-200 shadow-sm">
          {user?.photo_url ? (
            <img src={user.photo_url} alt="Profile" className="h-full w-full object-cover" />
          ) : (
            <User size={20} />
          )}
        </div>
        <div className="w-px h-6 bg-gray-200 mx-1"></div>
        <button
          onClick={handleLogout}
          className="text-gray-500 hover:text-red-600 flex items-center gap-2 text-sm font-medium transition-colors"
          title="Logout"
        >
          <LogOut size={20} />
          <span className="hidden sm:inline">Logout</span>
        </button>
      </div>
    </header>
  );
}
