import { useSelector } from 'react-redux';
import { get } from 'lodash';

export const useHasPermission = (requiredType) => {
  const isAuthUser = useSelector(state => state.auth.isAuthUser);
  const userRole = useSelector(state => get(state.auth, 'user.role'));

  if (!isAuthUser) return false;

  const rolePermissions = {
    guest: ['guest'],
    reader: ['reader', 'editor', 'admin'],
    editor: ['editor', 'admin'],
    admin: ['admin'],
  };

  return rolePermissions[requiredType].includes(userRole);
};
