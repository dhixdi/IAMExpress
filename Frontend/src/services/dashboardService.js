import api from './api';

const dashboardService = {
  get: async () => {
    const res = await api.get('/dashboard');
    return res.data.data;
  },
};

export default dashboardService;
