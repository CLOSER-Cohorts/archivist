import React, {  } from 'react';
import { useSelector } from 'react-redux'
import { Navigate } from 'react-router-dom';
import { get } from 'lodash'

const RedirectFromState = () => {
  const redirect = useSelector(state => get(state.common, 'redirect'));

  if(redirect){
    return (
      <Navigate to={redirect} />
    )
  }else{
    return ''
  }
}

export default RedirectFromState;
