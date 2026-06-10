import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Truck } from 'lucide-react';
import { useLogin } from '../../hooks/useAuth';
import { useAuthStore } from '../../store/authStore';

export default function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [errorMsg, setErrorMsg] = useState('');
  
  const navigate = useNavigate();
  const { isAuthenticated, setAuth } = useAuthStore();
  const { mutate: login, isPending } = useLogin();

  useEffect(() => {
    if (isAuthenticated) {
      navigate('/');
    }
  }, [isAuthenticated, navigate]);

  const handleSubmit = (e) => {
    e.preventDefault();
    setErrorMsg('');
    
    login(
      { email, password },
      {
        onSuccess: (data) => {
          setAuth(data.token, data.user);
          navigate('/');
        },
        onError: (err) => {
          setErrorMsg(err.response?.data?.message || 'Login gagal');
        },
      }
    );
  };

  return (
    <div className="min-h-screen bg-navy-950 flex flex-col justify-center py-12 sm:px-6 lg:px-8">
      <div className="sm:mx-auto sm:w-full sm:max-w-md">
        <div className="flex justify-center">
          <div className="bg-white p-3 rounded-full shadow-lg">
            <Truck size={48} className="text-amber-brand" />
          </div>
        </div>
        <h2 className="mt-6 text-center text-3xl font-extrabold text-white">
          IAMExpress Admin
        </h2>
        <p className="mt-2 text-center text-sm text-gray-300">
          Sign in to access your operational dashboard
        </p>
      </div>

      <div className="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
        <div className="bg-white py-8 px-4 shadow-card sm:rounded-xl sm:px-10">
          <form className="space-y-6" onSubmit={handleSubmit}>
            <div>
              <label className="block text-sm font-medium text-gray-700">Email Address</label>
              <div className="mt-1">
                <input
                  type="email"
                  required
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  className="w-full border border-gray-300 rounded-md shadow-sm p-2.5 focus:ring-navy-900 focus:border-navy-900"
                  placeholder="admin@iamexpress.id"
                />
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700">Password</label>
              <div className="mt-1">
                <input
                  type="password"
                  required
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="w-full border border-gray-300 rounded-md shadow-sm p-2.5 focus:ring-navy-900 focus:border-navy-900"
                  placeholder="••••••••"
                />
              </div>
            </div>

            {errorMsg && (
              <div className="p-3 rounded-md bg-red-50 border border-red-200">
                <p className="text-sm text-red-600">{errorMsg}</p>
              </div>
            )}

            <div>
              <button
                type="submit"
                disabled={isPending}
                className="w-full flex justify-center py-2.5 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-navy-950 hover:bg-navy-900 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-navy-950 disabled:opacity-70 disabled:cursor-not-allowed transition-colors"
              >
                {isPending ? 'Signing in...' : 'Sign in'}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
}
