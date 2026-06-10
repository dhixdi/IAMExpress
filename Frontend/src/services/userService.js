import api from './api';

const userService = {
  getAll: async (params = {}) => {
    const res = await api.get('/users', { params });
    return res.data;
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
