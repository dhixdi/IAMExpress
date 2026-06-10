import { useMutation, useQuery } from '@tanstack/react-query';
import authService from '../services/authService';

export const useMe = (enabled = true) => {
  return useQuery({
    queryKey: ['me'],
    queryFn: authService.me,
    enabled,
    retry: false,
  });
};

export const useLogin = () => {
  return useMutation({
    mutationFn: ({ email, password }) => authService.login(email, password),
  });
};

export const useLogout = () => {
  return useMutation({
    mutationFn: authService.logout,
  });
};
