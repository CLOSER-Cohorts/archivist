import React from 'react';
import { useSelector } from "react-redux";
import { get } from 'lodash'
import Button from '@material-ui/core/Button';
import { Link } from 'react-router-dom';

export const AuthButton = (props)  => {

  const isAuthUser = useSelector(state => state.auth.isAuthUser);
  const user = useSelector(state => get(state.auth, 'user'));

  const { type, to, label } = props;

  if (type === "admin" && isAuthUser && user && user.role !== 'admin') {
    return ''
  }

  if (type === "editor" && isAuthUser && user && user.role !== 'admin' && user.role !== 'editor') {
    return ''
  }

  if (type === "guest" && isAuthUser) {
    return ''
  }else if ((type === "editor" || type === "reader") && !isAuthUser){
    return ''
  };

  return (
    <Button variant='outlined'>
      <Link to={to}>{label}</Link>
    </Button>    
  );
};