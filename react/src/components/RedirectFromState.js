import React, {  } from 'react';
import { useSelector } from 'react-redux'
import { Redirect } from 'react-router-dom';
import { get } from 'lodash'

const RedirectFromState = () => {
  const redirect = useSelector(state => get(state.common, 'redirect'));

  if(redirect){
    return (
      <Redirect to={redirect} />
    )
  }else{
    return ''
  }
}

export default RedirectFromState;
