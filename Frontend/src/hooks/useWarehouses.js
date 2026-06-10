import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import warehouseService from '../services/warehouseService';

export const useWarehouses = (params) => {
  return useQuery({
    queryKey: ['warehouses', params],
    queryFn: () => warehouseService.getAll(params),
  });
};

export const useWarehouse = (id) => {
  return useQuery({
    queryKey: ['warehouse', id],
    queryFn: () => warehouseService.getById(id),
    enabled: !!id,
  });
};

export const useCreateWarehouse = () => {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (payload) => warehouseService.create(payload),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['warehouses'] }),
  });
};

export const useUpdateWarehouse = () => {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, payload }) => warehouseService.update(id, payload),
    onSuccess: (_, { id }) => {
      qc.invalidateQueries({ queryKey: ['warehouses'] });
      qc.invalidateQueries({ queryKey: ['warehouse', id] });
    },
  });
};

export const useDeleteWarehouse = () => {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id) => warehouseService.delete(id),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['warehouses'] }),
  });
};
