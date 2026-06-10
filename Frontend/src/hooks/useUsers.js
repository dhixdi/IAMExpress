import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import userService from '../services/userService';

export const useUsers = (params) => {
  return useQuery({
    queryKey: ['users', params],
    queryFn: () => userService.getAll(params),
  });
};

export const useUser = (id) => {
  return useQuery({
    queryKey: ['user', id],
    queryFn: () => userService.getById(id),
    enabled: !!id,
  });
};

export const useCreateUser = () => {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (payload) => userService.create(payload),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['users'] }),
  });
};

export const useUpdateUser = () => {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, payload }) => userService.update(id, payload),
    onSuccess: (_, { id }) => {
      qc.invalidateQueries({ queryKey: ['users'] });
      qc.invalidateQueries({ queryKey: ['user', id] });
    },
  });
};

export const useDeleteUser = () => {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id) => userService.delete(id),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['users'] }),
  });
};

export const useUpdateUserRole = () => {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, role }) => userService.updateRole(id, role),
    onSuccess: (_, { id }) => {
      qc.invalidateQueries({ queryKey: ['users'] });
      qc.invalidateQueries({ queryKey: ['user', id] });
    },
  });
};

export const useUpdateMyPassword = () => {
  return useMutation({
    mutationFn: ({ old_password, new_password }) => userService.updateMyPassword(old_password, new_password),
  });
};

export const useUpdateMyPhoto = () => {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (photo_url) => userService.updateMyPhoto(photo_url),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['me'] }),
  });
};
