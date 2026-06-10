import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import packageService from '../services/packageService';

export const usePackages = (params) => {
  return useQuery({
    queryKey: ['packages', params],
    queryFn: () => packageService.getAll(params),
  });
};

export const usePackage = (id) => {
  return useQuery({
    queryKey: ['package', id],
    queryFn: () => packageService.getById(id),
    enabled: !!id,
  });
};

export const usePackageTracker = (id) => {
  return useQuery({
    queryKey: ['tracker', id],
    queryFn: () => packageService.getTracker(id, { sort_by: 'timestamp', order: 'asc' }),
    enabled: !!id,
  });
};

export const useTrackByResi = (resi) => {
  return useQuery({
    queryKey: ['track', resi],
    queryFn: () => packageService.trackByResi(resi),
    enabled: !!resi,
    retry: false,
  });
};

export const useCreatePackage = () => {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (payload) => packageService.create(payload),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['packages'] }),
  });
};

export const useUpdatePackage = () => {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, payload }) => packageService.update(id, payload),
    onSuccess: (_, { id }) => {
      qc.invalidateQueries({ queryKey: ['packages'] });
      qc.invalidateQueries({ queryKey: ['package', id] });
    },
  });
};

export const useDeletePackage = () => {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id) => packageService.delete(id),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['packages'] }),
  });
};

export const useUpdatePackageStatus = () => {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, status, notes }) => packageService.updateStatus(id, status, notes),
    onSuccess: (_, { id }) => {
      qc.invalidateQueries({ queryKey: ['packages'] });
      qc.invalidateQueries({ queryKey: ['package', id] });
      qc.invalidateQueries({ queryKey: ['tracker', id] });
    },
  });
};

export const useAssignPackage = () => {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, user_id, type }) => packageService.assign(id, user_id, type),
    onSuccess: (_, { id }) => {
      qc.invalidateQueries({ queryKey: ['packages'] });
      qc.invalidateQueries({ queryKey: ['package', id] });
    },
  });
};
