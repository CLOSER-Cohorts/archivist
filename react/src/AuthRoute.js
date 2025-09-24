import React from 'react';
import { useSelector } from "react-redux";
import { Navigate } from "react-router-dom";
import { reverse as url } from 'named-urls';
import { get } from 'lodash';
import routes from './routes';

const AuthRoute = ({ children, type }) => {
  const isAuthUser = useSelector(state => state.auth.isAuthUser);
  const user = useSelector(state => get(state.auth, 'user'));

  // Redirect logic
  if (type === "admin" && isAuthUser && user && user.role !== 'admin') {
    return <Navigate to={url(routes.instruments.all)} />;
  }

  if (type === "editor" && isAuthUser && user && user.role !== 'admin' && user.role !== 'editor') {
    return <Navigate to={url(routes.instruments.all)} />;
  }

  if (type === "guest" && isAuthUser) {
    return <Navigate to={url(routes.instruments.all)} />;
  }

  if ((type !== "guest") && !isAuthUser) {
    return <Navigate to={url(routes.login)} />;
  }

  // Render children if access is allowed
  return children;
};

export default AuthRoute;