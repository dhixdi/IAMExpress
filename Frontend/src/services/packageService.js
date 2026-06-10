import api from './api';

const packageService = {
  getAll: async (params = {}) => {
    const res = await api.get('/packages', { params });
    return res.data;
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
    const res = await api.patch(`/packages/${id}/assign`, { user_id, type });
    return res.data.data;
  },

  getTracker: async (id, params = {}) => {
    const res = await api.get(`/packages/${id}/tracker`, { params });
    return res.data;
  },
};

export default packageService;
