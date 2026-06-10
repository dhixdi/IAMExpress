import { useState } from 'react';
import { useAuthStore } from '../../store/authStore';
import { useUpdateMyPassword, useUpdateMyPhoto } from '../../hooks/useUsers';
import PageHeader from '../../components/common/PageHeader';
import { User, Camera, Lock } from 'lucide-react';

export default function ProfilePage() {
  const { user } = useAuthStore();
  
  const [photoUrl, setPhotoUrl] = useState('');
  const [passwordForm, setPasswordForm] = useState({ old_password: '', new_password: '', confirm_password: '' });
  const [photoMsg, setPhotoMsg] = useState({ type: '', text: '' });
  const [passMsg, setPassMsg] = useState({ type: '', text: '' });

  const { mutate: updatePhoto, isPending: isUpdatingPhoto } = useUpdateMyPhoto();
  const { mutate: updatePassword, isPending: isUpdatingPass } = useUpdateMyPassword();

  const handleUpdatePhoto = (e) => {
    e.preventDefault();
    setPhotoMsg({ type: '', text: '' });
    updatePhoto(photoUrl, {
      onSuccess: () => {
        setPhotoMsg({ type: 'success', text: 'Foto profil berhasil diperbarui!' });
        setPhotoUrl('');
      },
      onError: (err) => {
        setPhotoMsg({ type: 'error', text: err.response?.data?.message || 'Gagal memperbarui foto profil' });
      }
    });
  };

  const handleUpdatePassword = (e) => {
    e.preventDefault();
    setPassMsg({ type: '', text: '' });
    
    if (passwordForm.new_password !== passwordForm.confirm_password) {
      setPassMsg({ type: 'error', text: 'Konfirmasi password tidak cocok' });
      return;
    }
    
    updatePassword({ 
      old_password: passwordForm.old_password, 
      new_password: passwordForm.new_password 
    }, {
      onSuccess: () => {
        setPassMsg({ type: 'success', text: 'Password berhasil diperbarui!' });
        setPasswordForm({ old_password: '', new_password: '', confirm_password: '' });
      },
      onError: (err) => {
        setPassMsg({ type: 'error', text: err.response?.data?.message || 'Gagal memperbarui password' });
      }
    });
  };

  if (!user) return null;

  return (
    <div className="max-w-4xl mx-auto space-y-6">
      <PageHeader 
        title="Profil Saya" 
        breadcrumb={[{ label: 'Dashboard', href: '/' }, { label: 'Profile' }]}
      />

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="md:col-span-1 space-y-6">
          <div className="bg-white rounded-xl shadow-card border border-gray-200 p-6 text-center">
            <div className="h-32 w-32 rounded-full bg-navy-950 text-white flex items-center justify-center overflow-hidden border-4 border-gray-50 shadow-sm mx-auto mb-4 relative group">
              {user.photo_url ? (
                <img src={user.photo_url} alt="Profile" className="h-full w-full object-cover" />
              ) : (
                <User size={48} />
              )}
            </div>
            <h2 className="text-xl font-bold text-gray-900">{user.nama}</h2>
            <p className="text-gray-500 mb-2">{user.email}</p>
            <span className="inline-flex px-3 py-1 rounded-full text-xs font-medium bg-amber-light text-amber-brand border border-amber-200">
              {user.role}
            </span>
          </div>
        </div>

        <div className="md:col-span-2 space-y-6">
          <div className="bg-white rounded-xl shadow-card border border-gray-200 p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4 flex items-center gap-2">
              <Camera size={20} className="text-gray-500" /> Update Foto Profil
            </h3>
            <form onSubmit={handleUpdatePhoto} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">URL Foto Profil</label>
                <input 
                  type="url" required 
                  value={photoUrl} onChange={e => setPhotoUrl(e.target.value)}
                  placeholder="https://example.com/photo.jpg"
                  className="w-full border border-gray-300 rounded-md p-2 focus:ring-navy-900 focus:border-navy-900"
                />
              </div>
              {photoMsg.text && (
                <div className={`p-3 rounded-md text-sm ${photoMsg.type === 'error' ? 'bg-red-50 text-red-600' : 'bg-green-50 text-green-700'}`}>
                  {photoMsg.text}
                </div>
              )}
              <button 
                type="submit" disabled={isUpdatingPhoto}
                className="px-4 py-2 bg-navy-950 text-white rounded-md hover:bg-navy-900 disabled:opacity-50"
              >
                {isUpdatingPhoto ? 'Menyimpan...' : 'Update Foto'}
              </button>
            </form>
          </div>

          <div className="bg-white rounded-xl shadow-card border border-gray-200 p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4 flex items-center gap-2">
              <Lock size={20} className="text-gray-500" /> Update Password
            </h3>
            <form onSubmit={handleUpdatePassword} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Password Lama</label>
                <input 
                  type="password" required 
                  value={passwordForm.old_password} onChange={e => setPasswordForm({...passwordForm, old_password: e.target.value})}
                  className="w-full border border-gray-300 rounded-md p-2 focus:ring-navy-900 focus:border-navy-900"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Password Baru</label>
                <input 
                  type="password" required minLength={6}
                  value={passwordForm.new_password} onChange={e => setPasswordForm({...passwordForm, new_password: e.target.value})}
                  className="w-full border border-gray-300 rounded-md p-2 focus:ring-navy-900 focus:border-navy-900"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Konfirmasi Password Baru</label>
                <input 
                  type="password" required minLength={6}
                  value={passwordForm.confirm_password} onChange={e => setPasswordForm({...passwordForm, confirm_password: e.target.value})}
                  className="w-full border border-gray-300 rounded-md p-2 focus:ring-navy-900 focus:border-navy-900"
                />
              </div>
              
              {passMsg.text && (
                <div className={`p-3 rounded-md text-sm ${passMsg.type === 'error' ? 'bg-red-50 text-red-600' : 'bg-green-50 text-green-700'}`}>
                  {passMsg.text}
                </div>
              )}
              
              <button 
                type="submit" disabled={isUpdatingPass}
                className="px-4 py-2 bg-navy-950 text-white rounded-md hover:bg-navy-900 disabled:opacity-50"
              >
                {isUpdatingPass ? 'Menyimpan...' : 'Update Password'}
              </button>
            </form>
          </div>
        </div>
      </div>
    </div>
  );
}
