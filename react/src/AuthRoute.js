import React from 'react';
import { useSelector } from "react-redux";
import { Redirect, Route } from "react-router-dom";
import { reverse as url } from 'named-urls'
import { get } from 'lodash'

import routes from './routes'

const AuthRoute = props => {

  const isAuthUser = useSelector(state => state.auth.isAuthUser);
  const user = useSelector(state => get(state.auth, 'user'));

  const { type } = props;

  if (type === "admin" && isAuthUser && user && user.role !== 'admin') {
    return <Redirect to={url(routes.instruments.all)} />
  }

  if (type === "editor" && isAuthUser && user && user.role !== 'admin' && user.role !== 'editor') {
    return <Redirect to={url(routes.instruments.all)} />
  }

  if (type === "guest" && isAuthUser) {
    return <Redirect to={url(routes.instruments.all)} />
  }else if ((type !== "guest") && !isAuthUser){
    return <Redirect to={url(routes.login)} />
  };

  return <Route {...props} />;
};

export default AuthRoute;
