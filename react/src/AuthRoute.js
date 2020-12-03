import React, { useEffect } from 'react';
import { useDispatch, useSelector } from "react-redux";
import { Redirect, Route } from "react-router-dom";
import { reverse as url } from 'named-urls'
import { isEmpty } from 'lodash'

import routes from './routes'

const AuthRoute = props => {

  const dispatch = useDispatch()
  const isAuthUser = useSelector(state => state.auth.isAuthUser);

  const { type } = props;

  if (type === "guest" && isAuthUser) {
    return <Redirect to={url(routes.instruments.all)} />
  }else if (type === "private" && !isAuthUser){
    return <Redirect to={url(routes.login)} />
  };

  return <Route {...props} />;
};

export default AuthRoute;
