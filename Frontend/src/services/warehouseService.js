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
