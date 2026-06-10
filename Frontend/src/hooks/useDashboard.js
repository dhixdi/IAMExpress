import { useQuery } from '@tanstack/react-query';
import dashboardService from '../services/dashboardService';

export const useDashboard = () => {
  return useQuery({
    queryKey: ['dashboard'],
    queryFn: dashboardService.get,
  });
};
