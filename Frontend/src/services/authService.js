import api from './api';

const authService = {
  login: async (email, password) => {
    const res = await api.post('/auth/login', { email, password });
    return res.data.data;
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
