import React, { useEffect } from 'react';
import { useSelector, useDispatch } from 'react-redux';
import { Navigate } from 'react-router-dom';
import { get } from 'lodash';

const RedirectFromState = () => {
  const dispatch = useDispatch();
  const redirect = useSelector(state => get(state.common, 'redirect'));

  useEffect(() => {
    if (redirect) {
      dispatch({ type: 'REDIRECT_CLEAR' });
    }
  }, [redirect, dispatch]);
  
  if (redirect) {
    return <Navigate to={redirect} />;
  }
  
  return null;
};

export default RedirectFromState;